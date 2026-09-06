 
import 'dart:typed_data';

import 'package:bk_absen/core/storage/cache_service.dart';
import 'package:bk_absen/features/home/data/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bk_absen/model/user_model.dart';
import 'package:bk_absen/model/check_in_out_model.dart';

final attendanceRepositoryProvider =
    Provider((ref) => AttendanceRepository());

class AttendanceState {
  final UserModel? user;
  final CheckInOutModel? attendance;
  final bool isLoading;

  AttendanceState({
    this.user,
    this.attendance,
    this.isLoading = false,
  });

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
  (ref) => AttendanceNotifier(
    ref.read(attendanceRepositoryProvider),
  ),
);

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository repo;

  AttendanceNotifier(this.repo) : super(AttendanceState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
    );

    final user = await repo.getUser();
    final attendance = await repo.getToday();

    state = state.copyWith(
      user: user ?? state.user,
      attendance: attendance,
      isLoading: false,
    );
  }


  void updateAttendanceLocal(
    CheckInOutModel attendance,
  ) {
    state = state.copyWith(
      attendance: attendance,
    );
  }

  Future<void> clearOfflineAttendance() async {
    await repo.offlineRepo.clear();

    await CacheService.delete(
      "attendance_today",
    );

    state = state.copyWith(
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
    try {

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

      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');

      final today =
          "${now.year.toString().padLeft(4, '0')}-"
          "${two(now.month)}-"
          "${two(now.day)}";

      final checkInTime =
          "${two(now.hour)}:"
          "${two(now.minute)}:"
          "${two(now.second)}";

      final current = state.attendance;

      final attendance = CheckInOutModel(
        tanggal: today,
        checkIn: checkInTime,
        checkOut: null,
        totalWaktu: current?.totalWaktu,
        isOff: current?.isOff ?? false,
        hasShift: current?.hasShift ?? true,
        limitLate: current?.limitLate,
      );

      await CacheService.write(
        "attendance_today",
        {
          "tanggal": attendance.tanggal,
          "check_in": attendance.checkIn,
          "check_out": attendance.checkOut,
          "total_waktu": attendance.totalWaktu,
          "is_off": attendance.isOff,
          "has_shift": attendance.hasShift,
          "limit_late": attendance.limitLate,
        },
      );

      state = state.copyWith(attendance: attendance);
    } catch (e) {

      await repo.saveOfflineCheckIn(
        employeeId: employeeId,
        imageBytes: imageBytes,
        lat: lat,
        lng: lng,
        distance: distance,
        locationStatus: locationStatus,
        lateReason: lateReason,
        lateProofBytes: lateProofBytes,
      );

      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');

      final today =
          "${now.year.toString().padLeft(4, '0')}-"
          "${two(now.month)}-"
          "${two(now.day)}";

      final checkInTime =
          "${two(now.hour)}:"
          "${two(now.minute)}:"
          "${two(now.second)}";

      final current = state.attendance;

      final attendance = CheckInOutModel(
        tanggal: today,
        checkIn: checkInTime,
        checkOut: null,
        totalWaktu: null,
        isOff: current?.isOff ?? false,
        hasShift: current?.hasShift ?? true,
        limitLate: current?.limitLate,
      );

      await CacheService.write(
        "attendance_today",
        {
          "tanggal": attendance.tanggal,
          "check_in": attendance.checkIn,
          "check_out": attendance.checkOut,
          "total_waktu": attendance.totalWaktu,
          "is_off": attendance.isOff,
          "has_shift": attendance.hasShift,
          "limit_late": attendance.limitLate,
        },
      );

      state = state.copyWith(attendance: attendance);
    }
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
      throw Exception(
        "Sudah checkout hari ini",
      );
    }

    try {
      await repo.checkOut(
        employeeId: employeeId,
        imageBytes: imageBytes,
        lat: lat,
        lng: lng,
        distance: distance,
        locationStatus: locationStatus,
        earlyReason: earlyReason,
      );

      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');

      final today =
          "${now.year.toString().padLeft(4, '0')}-"
          "${two(now.month)}-"
          "${two(now.day)}";

      final checkoutTime =
          "${two(now.hour)}:"
          "${two(now.minute)}:"
          "${two(now.second)}";

      CheckInOutModel? current = state.attendance;

      if (current == null) {
        final cache = CacheService.read(
          "attendance_today",
        );

        if (cache != null) {
          current = CheckInOutModel.fromJson(
            Map<String, dynamic>.from(cache),
          );
        }
      }

      if (current != null) {
        final currentTanggal = current.tanggal.toString().split(' ').first;

        if (currentTanggal != today) {
          current = null;
        }
      }

      final attendance = CheckInOutModel(
        tanggal: current?.tanggal ?? today,
        checkIn: current?.checkIn,
        checkOut: checkoutTime,
        totalWaktu: current?.totalWaktu,
        isOff: current?.isOff ?? false,
        hasShift: current?.hasShift ?? true,
        limitLate: current?.limitLate,
      );

      await CacheService.write(
        "attendance_today",
        {
          "tanggal": attendance.tanggal,
          "check_in": attendance.checkIn,
          "check_out": attendance.checkOut,
          "total_waktu": attendance.totalWaktu,
          "is_off": attendance.isOff,
          "has_shift": attendance.hasShift,
          "limit_late": attendance.limitLate,
        },
      );

      state = state.copyWith(
        attendance: attendance,
      );
    } catch (e) {

      await repo.saveOfflineCheckOut(
        employeeId: employeeId,
        imageBytes: imageBytes,
        lat: lat,
        lng: lng,
        distance: distance,
        locationStatus: locationStatus,
        earlyReason: earlyReason,
      );

      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');

      final today =
          "${now.year.toString().padLeft(4, '0')}-"
          "${two(now.month)}-"
          "${two(now.day)}";

      final checkoutTime =
          "${two(now.hour)}:"
          "${two(now.minute)}:"
          "${two(now.second)}";

      CheckInOutModel? current = state.attendance;

      if (current == null) {
        final cache = CacheService.read(
          "attendance_today",
        );

        if (cache != null) {
          current = CheckInOutModel.fromJson(
            Map<String, dynamic>.from(cache),
          );
        }
      }

      if (current != null) {
        final currentTanggal = current.tanggal.toString().split(' ').first;

        if (currentTanggal != today) {
          current = null;
        }
      }

      final attendance = CheckInOutModel(
        tanggal: current?.tanggal ?? today,
        checkIn: current?.checkIn,
        checkOut: checkoutTime,
        totalWaktu: current?.totalWaktu,
        isOff: current?.isOff ?? false,
        hasShift: current?.hasShift ?? true,
        limitLate: current?.limitLate,
      );

      await CacheService.write(
        "attendance_today",
        {
          "tanggal": attendance.tanggal,
          "check_in": attendance.checkIn,
          "check_out": attendance.checkOut,
          "total_waktu": attendance.totalWaktu,
          "is_off": attendance.isOff,
          "has_shift": attendance.hasShift,
          "limit_late": attendance.limitLate,
        },
      );

      state = state.copyWith(
        attendance: attendance,
      );
    }
  }


  bool isDoneToday() {
    final data = state.attendance;

    if (data == null) {
      return false;
    }

    final now = DateTime.now();

    final today =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";

    if (data.tanggal != today) {
      return false;
    }

    final checkIn = data.checkIn;
    final checkOut = data.checkOut;

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

    if (data?.hasShift == false) {
      return "Tidak Ada Shift";
    }

    final checkIn = data?.checkIn;
    final checkOut = data?.checkOut;

    if (checkIn == null || checkIn.isEmpty) {
      return user?.checkInTime ?? "Tidak ada shift";
    }

    if (checkOut == null || checkOut.isEmpty) {
      return user?.checkOutTime ?? "Tidak ada shift";
    }

    return "Jumpa Lagi Besok 👋";
  }

  String getButton() {
    final data = state.attendance;

    if (data == null) {
      return "Check In";
    }

    final now = DateTime.now();

    final today =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";

    if (data.tanggal != today) {
      return "Check In";
    }

    if (data.isOff == true) {
      return "Libur";
    }

    if (data.checkIn == null || data.checkIn!.isEmpty) {
      return "Check In";
    }

    if (data.checkOut == null || data.checkOut!.isEmpty) {
      return "Check Out";
    }

    return "Done";
  }

  bool isLate() {
    final data = state.attendance;

    if (data?.limitLate == null) {
      return false;
    }

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
  }

  bool isBeforeCheckoutTime() {
    final user = state.user;

    if (user?.checkOutTime == null) {
      return false;
    }

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

