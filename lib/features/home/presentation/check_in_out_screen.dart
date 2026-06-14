import 'dart:async';
import 'dart:typed_data';

import 'package:bk_absen/features/home/presentation/widgets/early_reason_dialog.dart';
import 'package:bk_absen/features/home/presentation/widgets/late_reason_dialog.dart';
import 'package:bk_absen/features/home/presentation/widgets/panel_right.dart';
import 'package:bk_absen/features/home/presentation/widgets/clock.dart';
import 'package:bk_absen/features/home/presentation/widgets/map_marker.dart';
import 'package:bk_absen/features/home/presentation/widgets/panel_left.dart';
import 'package:bk_absen/features/home/provider/attendance_provider.dart';
import 'package:bk_absen/model/check_in_out_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class CheckInOutScreen extends ConsumerStatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  ConsumerState<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends ConsumerState<CheckInOutScreen> {
  bool _isSubmitLoading = false;

  Uint8List? _imageBytes;

  final MapController _mapController = MapController();
  double? _distance;
  String _locationStatus = "-";

  LatLng? userLatLng;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cekLokasi();
    });
  }

  /// ================= LOCATION =================
  Future<void> cekLokasi() async {
    setState(() => isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showGpsDialog();
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();

      final user = ref.read(attendanceProvider).user;
      final officeLat = user?.officeLatitude;
      final officeLng = user?.officeLongitude;
      final radius = user?.officeRadius ?? 20;

      if (officeLat == null || officeLng == null) return;

      final newUser = LatLng(pos.latitude, pos.longitude);

      final distance = Geolocator.distanceBetween(
        officeLat,
        officeLng,
        pos.latitude,
        pos.longitude,
      );

      setState(() {
        userLatLng = LatLng(pos.latitude, pos.longitude);
        _distance = distance;
        _locationStatus = distance <= radius
            ? "Dalam Jangkauan"
            : "Luar Jangkauan";
        isLoadingLocation = false;
      });

      final point = _mapController.camera.project(newUser);
      final shiftedPoint = point + const Point<double>(0, 180);
      final shiftedLatLng = _mapController.camera.unproject(shiftedPoint);
      _mapController.move(shiftedLatLng, 18);
      // _mapController.move(newUser, 18);
    } catch (e) {
      setState(() {
        _locationStatus = "Error lokasi";
        isLoadingLocation = false;
      });
    }
  }

  void _showGpsDialog() {
    CustomDialog.show(
      context: context,
      icon: Icons.location_off,
      iconColor: AppColors.primary,
      title: "GPS Tidak Aktif",
      message: "Aktifkan GPS",
      confirmText: "OK",
    );
  }

  void _showPermissionDialog() {
    CustomDialog.show(
      context: context,
      icon: Icons.location_on,
      iconColor: AppColors.primary,
      title: "Izin lokasi",
      message: "Butuh izin lokasi",
      confirmText: "OK",
    );
  }

  /// ================= CAMERA =================
  Future<void> _openCamera() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  bool canSubmit(CheckInOutModel? data) {
    if (data?.isOff == true) return false;

    final isCheckedIn = data?.checkIn?.isNotEmpty == true;
    final isCheckedOut = data?.checkOut?.isNotEmpty == true;

    return _imageBytes != null &&
        userLatLng != null &&
        _distance != null &&
        !_isSubmitLoading &&
        !(isCheckedIn && isCheckedOut);
  }

  Future<void> _handleSubmit(bool isCheckedIn, int employeeId) async {
    if (_isSubmitLoading) return;

    final notifier = ref.read(attendanceProvider.notifier);

    if (!isCheckedIn && notifier.isLate()) {
      final result = await showDialog(
        context: context,
        builder: (_) => LateReasonDialog(),
      );

      if (result == null) return;

      setState(() => _isSubmitLoading = true);

      try {
        await notifier.checkIn(
          employeeId: employeeId,
          imageBytes: _imageBytes!,
          lat: userLatLng!.latitude,
          lng: userLatLng!.longitude,
          distance: _distance!,
          locationStatus: _locationStatus,
          lateReason: result['reason'],
          lateProofBytes: result['file'],
        );

        if (!mounted) return;

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      } finally {
        if (mounted) {
          setState(() => _isSubmitLoading = false);
        }
      }

      return;
    }

    setState(() => _isSubmitLoading = true);

    try {
      final notifier = ref.read(attendanceProvider.notifier);

      // if (isCheckedIn) {
      //   await notifier.checkOut(
      //     employeeId: employeeId,
      //     imageBytes: _imageBytes!,
      //     lat: userLatLng!.latitude,
      //     lng: userLatLng!.longitude,
      //     distance: _distance!,
      //     locationStatus: _locationStatus,
      //   );
      // }
      if (isCheckedIn) {
        if (notifier.isBeforeCheckoutTime()) {
          final reason = await showDialog<String>(
            context: context,
            builder: (_) => const EarlyReasonDialog(),
          );

          if (reason == null) {
            setState(() => _isSubmitLoading = false);
            return;
          }

          await notifier.checkOut(
            employeeId: employeeId,
            imageBytes: _imageBytes!,
            lat: userLatLng!.latitude,
            lng: userLatLng!.longitude,
            distance: _distance!,
            locationStatus: _locationStatus,
            earlyReason: reason,
          );
        } else {
          await notifier.checkOut(
            employeeId: employeeId,
            imageBytes: _imageBytes!,
            lat: userLatLng!.latitude,
            lng: userLatLng!.longitude,
            distance: _distance!,
            locationStatus: _locationStatus,
          );
        }
      } else {
        await notifier.checkIn(
          employeeId: employeeId,
          imageBytes: _imageBytes!,
          lat: userLatLng!.latitude,
          lng: userLatLng!.longitude,
          distance: _distance!,
          locationStatus: _locationStatus,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) {
        setState(() => _isSubmitLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final user = state.user!;
    final data = state.attendance;

    final officeLatLng = LatLng(user.officeLatitude!, user.officeLongitude!);
    return PopScope(
      canPop: !_isSubmitLoading,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  // onPressed: () {
                  //   Navigator.pop(context);
                  // },
                  onPressed: _isSubmitLoading
                      ? null
                      : () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            AbsorbPointer(
              absorbing: _isSubmitLoading,
              child: Stack(
                children: [
                  /// ================= MAP =================
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: officeLatLng,
                        initialZoom: 18,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        ),

                        /// Radius kantor
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: officeLatLng,
                              radius: user.officeRadius ?? 20,
                              useRadiusInMeter: true,
                              color: AppColors.primary.withValues(alpha: 0.25),
                              borderStrokeWidth: 2,
                              borderColor: AppColors.primary,
                            ),
                          ],
                        ),

                        /// Marker
                        MarkerLayer(
                          markers: buildMarkers(
                            office: officeLatLng,
                            user: userLatLng,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ================= JAM =================
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Clock(),
                      ),
                    ),
                  ),

                  /// ================= REFRESH LOKASI =================
                  Positioned(
                    right: 16,
                    top: MediaQuery.of(context).size.height / 2 - 28,
                    child: FloatingActionButton(
                      backgroundColor: AppColors.primary,
                      onPressed: isLoadingLocation ? null : cekLokasi,
                      child: isLoadingLocation
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),

                  /// ================= PANEL BAWAH =================
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              /// PANEL KIRI (FOTO)
                              PanelLeft(
                                imageBytes: _imageBytes,
                                onOpenCamera: _openCamera,
                              ),

                              const SizedBox(width: 20),

                              /// PANEL KANAN (ACTION)
                              PanelRight(
                                data: data,
                                distance: _distance,
                                locationStatus: _locationStatus,
                                canSubmit: canSubmit(data),
                                isCheckedIn: data?.checkIn?.isNotEmpty == true,
                                isCheckedOut:
                                    data?.checkOut?.isNotEmpty == true,
                                isSubmitLoading: _isSubmitLoading,
                                onSubmit: () {
                                  _handleSubmit(
                                    data?.checkIn?.isNotEmpty == true,
                                    user.employeeId,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isSubmitLoading)
              Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:async';
// import 'dart:typed_data';

// import 'package:bk_absen/features/home/presentation/widgets/panel_right.dart';
// import 'package:bk_absen/features/home/presentation/widgets/clock.dart';
// import 'package:bk_absen/features/home/presentation/widgets/map_marker.dart';
// import 'package:bk_absen/features/home/presentation/widgets/panel_left.dart';
// import 'package:bk_absen/features/home/provider/attendance_provider.dart';
// import 'package:bk_absen/model/check_in_out_model.dart';
// import 'package:bk_absen/utils/app_colors.dart';
// import 'package:bk_absen/utils/custom_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';

// class CheckInOutScreen extends ConsumerStatefulWidget {
//   const CheckInOutScreen({super.key});

//   @override
//   ConsumerState<CheckInOutScreen> createState() => _CheckInOutScreenState();
// }

// class _CheckInOutScreenState extends ConsumerState<CheckInOutScreen> {
//   bool _isSubmitLoading = false;

//   Uint8List? _imageBytes;

//   final MapController _mapController = MapController();
//   double? _distance;
//   String _locationStatus = "-";

//   LatLng? userLatLng;
//   bool isLoadingLocation = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       cekLokasi();
//     });
//   }

//   /// ================= LOCATION =================
//   Future<void> cekLokasi() async {
//     setState(() => isLoadingLocation = true);

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showGpsDialog();
//         return;
//       }

//       LocationPermission permission = await Geolocator.requestPermission();

//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         _showPermissionDialog();
//         return;
//       }

//       Position pos = await Geolocator.getCurrentPosition();

//       final user = ref.read(attendanceProvider).user;
//       final officeLat = user?.officeLatitude;
//       final officeLng = user?.officeLongitude;
//       final radius = user?.officeRadius ?? 20;

//       if (officeLat == null || officeLng == null) return;

//       final officeLatLng = LatLng(officeLat, officeLng);

//       final distance = Geolocator.distanceBetween(
//         officeLat,
//         officeLng,
//         pos.latitude,
//         pos.longitude,
//       );

//       setState(() {
//         userLatLng = LatLng(pos.latitude, pos.longitude);
//         _distance = distance;
//         _locationStatus = distance <= radius
//             ? "Dalam Jangkauan"
//             : "Luar Jangkauan";
//         isLoadingLocation = false;
//       });

//       _mapController.move(officeLatLng, 18);
//     } catch (e) {
//       setState(() {
//         _locationStatus = "Error lokasi";
//         isLoadingLocation = false;
//       });
//     }
//   }

//   void _showGpsDialog() {
//     CustomDialog.show(
//       context: context,
//       icon: Icons.location_off,
//       iconColor: AppColors.primary,
//       title: "GPS Tidak Aktif",
//       message: "Aktifkan GPS",
//       confirmText: "OK",
//     );
//   }

//   void _showPermissionDialog() {
//     CustomDialog.show(
//       context: context,
//       icon: Icons.location_on,
//       iconColor: AppColors.primary,
//       title: "Izin lokasi",
//       message: "Butuh izin lokasi",
//       confirmText: "OK",
//     );
//   }

//   /// ================= CAMERA =================
//   Future<void> _openCamera() async {
//     final picker = ImagePicker();

//     final image = await picker.pickImage(source: ImageSource.camera);

//     if (image != null) {
//       final bytes = await image.readAsBytes();
//       setState(() => _imageBytes = bytes);
//     }
//   }

//   bool canSubmit(CheckInOutModel? data) {
//     if (data?.isOff == true) return false;

//     final isCheckedIn = data?.checkIn?.isNotEmpty == true;
//     final isCheckedOut = data?.checkOut?.isNotEmpty == true;

//     return _imageBytes != null &&
//         userLatLng != null &&
//         _distance != null &&
//         !_isSubmitLoading &&
//         !(isCheckedIn && isCheckedOut);
//   }

//   Future<void> _handleSubmit(bool isCheckedIn, int employeeId) async {
//     if (_isSubmitLoading) return;

//     setState(() => _isSubmitLoading = true);

//     try {
//       final notifier = ref.read(attendanceProvider.notifier);

//       if (isCheckedIn) {
//         await notifier.checkOut(
//           employeeId: employeeId,
//           imageBytes: _imageBytes!,
//           lat: userLatLng!.latitude,
//           lng: userLatLng!.longitude,
//           distance: _distance!,
//           locationStatus: _locationStatus,
//         );
//       } else {
//         await notifier.checkIn(
//           employeeId: employeeId,
//           imageBytes: _imageBytes!,
//           lat: userLatLng!.latitude,
//           lng: userLatLng!.longitude,
//           distance: _distance!,
//           locationStatus: _locationStatus,
//         );
//       }
//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(attendanceProvider);
//     final user = state.user!;
//     final data = state.attendance;

//     final officeLatLng = LatLng(user.officeLatitude!, user.officeLongitude!);
//     return Scaffold(
//       body: Stack(
//         children: [
//           /// ================= MAP =================
//           Positioned.fill(
//             child: FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(initialCenter: officeLatLng, initialZoom: 18),
//               children: [
//                 TileLayer(
//                   urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 ),

//                 /// Radius kantor
//                 CircleLayer(
//                   circles: [
//                     CircleMarker(
//                       point: officeLatLng,
//                       radius: user.officeRadius ?? 20,
//                       useRadiusInMeter: true,
//                       color: AppColors.primary.withOpacity(0.25),
//                       borderStrokeWidth: 2,
//                       borderColor: AppColors.primary,
//                     ),
//                   ],
//                 ),

//                 /// Marker
//                 MarkerLayer(
//                   markers: buildMarkers(office: officeLatLng, user: userLatLng),
//                 ),
//               ],
//             ),
//           ),

//           /// ================= JAM =================
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 20,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 child: const Clock(),
//               ),
//             ),
//           ),

//           /// ================= REFRESH LOKASI =================
//           Positioned(
//             right: 16,
//             top: MediaQuery.of(context).size.height / 2 - 28,
//             child: FloatingActionButton(
//               backgroundColor: AppColors.primary,
//               onPressed: isLoadingLocation ? null : cekLokasi,
//               child: isLoadingLocation
//                   ? const SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Icon(Icons.my_location, color: Colors.white),
//             ),
//           ),

//           /// ================= PANEL BAWAH =================
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 20,
//                     offset: Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 top: false,
//                 child: IntrinsicHeight(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       /// PANEL KIRI (FOTO)
//                       PanelLeft(
//                         imageBytes: _imageBytes,
//                         onOpenCamera: _openCamera,
//                       ),

//                       const SizedBox(width: 20),

//                       /// PANEL KANAN (ACTION)
//                       PanelRight(
//                         data: data,
//                         distance: _distance,
//                         locationStatus: _locationStatus,
//                         canSubmit: canSubmit(data),
//                         isCheckedIn: data?.checkIn?.isNotEmpty == true,
//                         isCheckedOut: data?.checkOut?.isNotEmpty == true,
//                         isSubmitLoading: _isSubmitLoading,
//                         onSubmit: () {
//                           _handleSubmit(
//                             data?.checkIn?.isNotEmpty == true,
//                             user.employeeId,
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
