import 'dart:typed_data';

import 'package:bk_absen/features/home/data/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bk_absen/model/user_model.dart';
import 'package:bk_absen/model/check_in_out_model.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

class AttendanceState {
  final UserModel? user;
  final CheckInOutModel? attendance;
  final bool isLoading;

  AttendanceState({this.user, this.attendance, this.isLoading = false});

  AttendanceState copyWith({
    UserModel? user,
    CheckInOutModel? attendance,
    bool? isLoading,
  }) {
    return AttendanceState(
      user: user ?? this.user,
      attendance: attendance ?? this.attendance,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>(
      (ref) => AttendanceNotifier(ref.read(attendanceRepositoryProvider)),
    );

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository repo;

  AttendanceNotifier(this.repo) : super(AttendanceState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    final user = await repo.getUser();
    final attendance = await repo.getToday();

    state = state.copyWith(
      user: user,
      attendance: attendance,
      isLoading: false,
    );
  }

  Future<void> checkIn({
    required int employeeId,
    required Uint8List imageBytes,
    required double lat,
    required double lng,
    required double distance,
    required String locationStatus,

    String? lateReason,
    Uint8List? lateProofBytes,
  }) async {
    await repo.checkIn(
      employeeId: employeeId,
      imageBytes: imageBytes,
      lat: lat,
      lng: lng,
      distance: distance,
      locationStatus: locationStatus,

      lateReason: lateReason,
      lateProofBytes: lateProofBytes,
    );

    await load();
  }

  Future<void> checkOut({
    required int employeeId,
    required Uint8List imageBytes,
    required double lat,
    required double lng,
    required double distance,
    required String locationStatus,
    String? earlyReason,
  }) async {
    if (isDoneToday()) {
      throw Exception("Sudah checkout hari ini");
    }
    await repo.checkOut(
      employeeId: employeeId,
      imageBytes: imageBytes,
      lat: lat,
      lng: lng,
      distance: distance,
      locationStatus: locationStatus,
      earlyReason: earlyReason,
    );

    await load(); // refresh global state
  }

  bool isDoneToday() {
    final data = state.attendance;

    final checkIn = data?.checkIn;
    final checkOut = data?.checkOut;

    return checkIn != null &&
        checkIn.isNotEmpty &&
        checkOut != null &&
        checkOut.isNotEmpty;
  }

  String getShiftTime() {
    final user = state.user;
    final data = state.attendance;

    if (data?.isOff == true) {
      return "Hari ini libur";
    }
     if (data?.hasShift == false) return "Tidak Ada Shift";

    final checkIn = data?.checkIn;
    final checkOut = data?.checkOut;

    // belum checkin
    if (checkIn == null || checkIn.isEmpty) {
      return user?.checkInTime ?? "Tidak ada shift";
    }

    // sudah checkin, belum checkout
    if (checkOut == null || checkOut.isEmpty) {
      return user?.checkOutTime ?? "Tidak ada shift";
    }

    return "Jumpa Lagi Besok 👋";
  }

  String getButton() {
    final data = state.attendance;

    //tambahan
    if (data?.isOff == true) {
      return "Libur";
    }
    //tambahan

    if (data?.checkIn == null || data!.checkIn!.isEmpty) {
      return "Check In";
    } else if (data.checkOut == null || data.checkOut!.isEmpty) {
      return "Check Out";
    } else {
      return "Done";
    }
  }

  bool isLate() {
    final data = state.attendance;
    if (data?.limitLate == null) return false;

    final now = DateTime.now();
    final parts = data!.limitLate!.split(":");

    final limit = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    return now.isAfter(limit);
  } //tambahan

  bool isBeforeCheckoutTime() {
    final user = state.user;
    if (user?.checkOutTime == null) return false;

    final now = DateTime.now();
    final parts = user!.checkOutTime!.split(":");

    final checkoutTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    return now.isBefore(checkoutTime);
  }
}
