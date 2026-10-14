import 'dart:typed_data';

import 'package:bk_absen/core/network/server_checker.dart';
import 'package:bk_absen/core/storage/cache_service.dart';
import 'package:bk_absen/features/home/data/attendance_repository.dart';
import 'package:dio/dio.dart';
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

  String _todayString() {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String? _attendanceDate(CheckInOutModel? attendance) {
    return attendance?.tanggal.split(' ').first;
  }

  CheckInOutModel? _getValidLocalAttendance() {
    final current = state.attendance;

    if (current != null &&
        _attendanceDate(current) == _todayString() &&
        current.checkIn != null &&
        current.checkIn!.isNotEmpty) {
      return current;
    }

    final cache = CacheService.read('attendance_today');
    if (cache == null) return null;

    final cacheMap = Map<String, dynamic>.from(cache);
    final cacheDate = cacheMap['tanggal']?.toString().split(' ').first;
    final cacheCheckIn = cacheMap['check_in']?.toString();

    if (cacheDate != _todayString() ||
        cacheCheckIn == null ||
        cacheCheckIn.isEmpty) {
      return null;
    }

    return CheckInOutModel.fromJson(cacheMap);
  }

  CheckInOutModel _mergeAttendance(
    CheckInOutModel serverAttendance,
    CheckInOutModel? localAttendance,
  ) {
    final today = _todayString();

    // Server mengembalikan data bukan hari ini.
    // Jangan gunakan check-in/check-out lama.
    if (_attendanceDate(serverAttendance) != today) {
      if (localAttendance != null &&
          _attendanceDate(localAttendance) == today &&
          localAttendance.checkIn != null &&
          localAttendance.checkIn!.isNotEmpty) {
        return CheckInOutModel(
          tanggal: today,
          checkIn: localAttendance.checkIn,
          checkOut: localAttendance.checkOut,
          totalWaktu: localAttendance.totalWaktu,
          isOff: localAttendance.isOff,
          hasShift: localAttendance.hasShift,
          limitLate: localAttendance.limitLate,
        );
      }

      return CheckInOutModel(
        tanggal: today,
        checkIn: null,
        checkOut: null,
        totalWaktu: null,
        isOff: serverAttendance.isOff,
        hasShift: serverAttendance.hasShift,
        limitLate: serverAttendance.limitLate,
      );
    }

    // Server adalah data hari ini dan sudah punya check-in.
    if (serverAttendance.checkIn != null &&
        serverAttendance.checkIn!.isNotEmpty) {
      return serverAttendance;
    }

    // Server hari ini tetapi check-in kosong.
    // Jika local punya check-in hari ini, pertahankan.
    if (localAttendance != null &&
        _attendanceDate(localAttendance) == today &&
        localAttendance.checkIn != null &&
        localAttendance.checkIn!.isNotEmpty) {
      return CheckInOutModel(
        tanggal: today,
        checkIn: localAttendance.checkIn,
        checkOut: serverAttendance.checkOut ?? localAttendance.checkOut,
        totalWaktu: serverAttendance.totalWaktu ?? localAttendance.totalWaktu,
        isOff: serverAttendance.isOff,
        hasShift: serverAttendance.hasShift,
        limitLate: serverAttendance.limitLate,
      );
    }

    return serverAttendance;
  }

  Future<void> load() async {
    final localAttendance = _getValidLocalAttendance();

    state = state.copyWith(isLoading: true);

    try {
      final user = await repo.getUser();
      final serverAttendance = await repo.getToday();

      CheckInOutModel? finalAttendance;

      if (serverAttendance != null) {
        finalAttendance = _mergeAttendance(serverAttendance, localAttendance);

        await CacheService.write('attendance_today', {
          'tanggal': finalAttendance.tanggal,
          'check_in': finalAttendance.checkIn,
          'check_out': finalAttendance.checkOut,
          'total_waktu': finalAttendance.totalWaktu,
          'is_off': finalAttendance.isOff,
          'has_shift': finalAttendance.hasShift,
          'limit_late': finalAttendance.limitLate,
        });
      } else {
        finalAttendance = localAttendance;
      }

      state = state.copyWith(
        user: user ?? state.user,
        attendance: finalAttendance,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(attendance: localAttendance, isLoading: false);
    }
  }

  void updateAttendanceLocal(CheckInOutModel attendance) {
    state = state.copyWith(attendance: attendance);
  }

  Future<void> clearOfflineAttendance() async {
    await repo.offlineRepo.clear();
    await CacheService.delete("attendance_today");

    state = state.copyWith(isLoading: false);
  }

  Future<bool> _shouldSaveOffline(DioException e) async {
    final statusCode = e.response?.statusCode;

    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 422) {
      return false;
    }

    final isNgrokOffline =
        statusCode == 404 &&
        e.response?.headers.value('ngrok-error-code') == 'ERR_NGROK_3200';

    final shouldCheckHealth =
        statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504 ||
        isNgrokOffline;

    if (e.response != null && !shouldCheckHealth) {
      return false;
    }

    final isNetworkError =
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;

    if (e.response == null && !isNetworkError) {
      return false;
    }

    final serverAlive = await ServerChecker.isAlive();

    return !serverAlive;
  }

  Future<void> _updateAttendanceAfterCheckOut() async {
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
      final cache = CacheService.read("attendance_today");

      if (cache != null) {
        current = CheckInOutModel.fromJson(Map<String, dynamic>.from(cache));
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

    await CacheService.write("attendance_today", {
      "tanggal": attendance.tanggal,
      "check_in": attendance.checkIn,
      "check_out": attendance.checkOut,
      "total_waktu": attendance.totalWaktu,
      "is_off": attendance.isOff,
      "has_shift": attendance.hasShift,
      "limit_late": attendance.limitLate,
    });

    state = state.copyWith(attendance: attendance);
  }

  Future<void> _updateAttendanceAfterCheckIn() async {
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

    final attendance = CheckInOutModel(
      tanggal: today,
      checkIn: checkInTime,
      checkOut: null,
      totalWaktu: null,
      isOff: false,
      hasShift: true,
      limitLate: state.attendance?.limitLate,
    );

    await CacheService.write("attendance_today", {
      "tanggal": attendance.tanggal,
      "check_in": attendance.checkIn,
      "check_out": attendance.checkOut,
      "total_waktu": attendance.totalWaktu,
      "is_off": attendance.isOff,
      "has_shift": attendance.hasShift,
      "limit_late": attendance.limitLate,
    });

    state = state.copyWith(attendance: attendance);
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
    if (isAfterShiftCheckoutTime()) {
      throw Exception('Tidak bisa check-in setelah jam kerja berakhir');
    }
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

      await _updateAttendanceAfterCheckIn();
    } on DioException catch (e) {
      final shouldSave = await _shouldSaveOffline(e);

      if (!shouldSave) {
        rethrow;
      }

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

      await _updateAttendanceAfterCheckIn();
      return;
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
      throw Exception("Sudah checkout hari ini");
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

      await _updateAttendanceAfterCheckOut();
    } on DioException catch (e) {
      final shouldSave = await _shouldSaveOffline(e);

      if (!shouldSave) {
        rethrow;
      }

      await repo.saveOfflineCheckOut(
        employeeId: employeeId,
        imageBytes: imageBytes,
        lat: lat,
        lng: lng,
        distance: distance,
        locationStatus: locationStatus,
        earlyReason: earlyReason,
      );

      await _updateAttendanceAfterCheckOut();
      return;
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

    final attendanceDate = data.tanggal.split(' ').first;

    if (attendanceDate != today) {
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
    final user = state.user;

    final checkInTime = user?.checkInTime;
    final toleransiLate = user?.toleransiLate ?? 0;

    if (checkInTime == null || checkInTime.isEmpty) {
      return false;
    }

    final parts = checkInTime.split(":");

    if (parts.length < 2) {
      return false;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    final second = parts.length >= 3 ? int.tryParse(parts[2]) ?? 0 : 0;

    if (hour == null || minute == null) {
      return false;
    }

    final now = DateTime.now();

    // Jadwal masuk
    final checkInSchedule = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
    );

    // Jadwal masuk + toleransi
    final lateLimit = checkInSchedule.add(Duration(minutes: toleransiLate));

    // Tepat pada batas toleransi masih dianggap tidak terlambat.
    return now.isAfter(lateLimit);
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

  bool isAfterShiftCheckoutTime() {
    final checkoutTime = state.user?.checkOutTime;

    if (checkoutTime == null || checkoutTime.isEmpty) {
      return false;
    }

    final now = DateTime.now();

    final parts = checkoutTime.split(':');
    if (parts.length < 2) {
      return false;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    final second = parts.length >= 3 ? int.tryParse(parts[2]) ?? 0 : 0;

    if (hour == null || minute == null) {
      return false;
    }

    final checkoutToday = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
    );
    return now.isAfter(checkoutToday);
  }
}
