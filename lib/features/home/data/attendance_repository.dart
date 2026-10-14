import 'dart:typed_data';

import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/core/storage/cache_service.dart';
import 'package:bk_absen/model/check_in_out_model.dart';
import 'package:bk_absen/model/user_model.dart';
import 'package:bk_absen/offline/models/offline_attendance_model.dart';
import 'package:bk_absen/offline/repository/offline_repository.dart';
import 'package:dio/dio.dart';

class AttendanceRepository {
  final OfflineRepository offlineRepo = OfflineRepository();

  Future<void> saveOfflineCheckIn({
    required int employeeId,
    required Uint8List imageBytes,
    required double lat,
    required double lng,
    required double distance,
    required String locationStatus,
    String? lateReason,
    Uint8List? lateProofBytes,
    DateTime? checkinAt,
  }) async {
    final data = OfflineAttendanceModel(
      type: "checkin",
      employeeId: employeeId,
      imageBytes: imageBytes.toList(),
      latitude: lat,
      longitude: lng,
      distance: distance,
      locationStatus: locationStatus,
      lateReason: lateReason,
      lateProofBytes: lateProofBytes?.toList(),
      createdAt: checkinAt ?? DateTime.now(),
    );

    await offlineRepo.save(data);
  }

  Future<void> saveOfflineCheckOut({
    required int employeeId,
    required Uint8List imageBytes,
    required double lat,
    required double lng,
    required double distance,
    required String locationStatus,
    String? earlyReason,
    DateTime? checkoutAt,
  }) async {
    final data = OfflineAttendanceModel(
      type: "checkout",
      employeeId: employeeId,
      imageBytes: imageBytes.toList(),
      latitude: lat,
      longitude: lng,
      distance: distance,
      locationStatus: locationStatus,
      earlyReason: earlyReason,
      createdAt: checkoutAt ?? DateTime.now(),
    );

    await offlineRepo.save(data);
  }

  Future<UserModel?> getUser() async {
    try {
      final res = await DioClient.dio.get('/me');

      final data = Map<String, dynamic>.from(res.data);

      await CacheService.write("home_user", data);

      return UserModel.fromJson(data);
    } catch (_) {
      final cache = CacheService.read("home_user");

      if (cache == null) {
        return null;
      }

      return UserModel.fromJson(Map<String, dynamic>.from(cache));
    }
  }
 
  Future<CheckInOutModel?> getToday() async {
    final now = DateTime.now();

    final today =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";

    try {
      final res = await DioClient.dio.get('/attendance');
      final data = Map<String, dynamic>.from(res.data['data'] ?? res.data);
      final attendance = CheckInOutModel.fromJson(data);
      final attendanceDate = attendance.tanggal.toString().split(' ').first;

      // Server mengembalikan attendance hari ini.
      if (attendanceDate == today) {
        await CacheService.write("attendance_today", {
          "tanggal": attendance.tanggal,
          "check_in": attendance.checkIn,
          "check_out": attendance.checkOut,
          "total_waktu": attendance.totalWaktu,
          "is_off": attendance.isOff,
          "has_shift": attendance.hasShift,
          "limit_late": attendance.limitLate,
        });

        return attendance;
      }

      // Server mengembalikan attendance kemarin.
      // Jangan masukkan data tersebut sebagai attendance hari ini.
      return CheckInOutModel(
        tanggal: today,
        checkIn: null,
        checkOut: null,
        totalWaktu: null,
        isOff: attendance.isOff,
        hasShift: attendance.hasShift,
        limitLate: attendance.limitLate,
      );
    } catch (e) {
      final cache = CacheService.read("attendance_today");

      if (cache == null) {
        return null;
      }

      final cacheMap = Map<String, dynamic>.from(cache);

      final cacheTanggal = cacheMap['tanggal']?.toString().split(' ').first;

      // Cache bukan hari ini.
      if (cacheTanggal != today) {
        return CheckInOutModel(
          tanggal: today,
          checkIn: null,
          checkOut: null,
          totalWaktu: null,
          isOff: false,
          hasShift: cacheMap['has_shift'] ?? true,
          limitLate: null,
        );
      }

      return CheckInOutModel.fromJson(cacheMap);
    }
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
    DateTime? checkinAt,
  }) async {
    final formDataMap = <String, dynamic>{
      "employee_id": employeeId,
      "latitude_checkin": lat,
      "longitude_checkin": lng,
      "distance_checkin": distance,
      "location_status": locationStatus,
      "gambar_checkin": MultipartFile.fromBytes(
        imageBytes,
        filename: "checkin.jpg",
      ),
    };

    if (checkinAt != null) {
      formDataMap["checkin_at"] = checkinAt.toIso8601String();
    }

    if (lateReason != null && lateReason.trim().isNotEmpty) {
      formDataMap["late_reason"] = lateReason;
    }

    if (lateProofBytes != null && lateProofBytes.isNotEmpty) {
      formDataMap["late_proof"] = MultipartFile.fromBytes(
        lateProofBytes,
        filename: "late_proof.jpg",
      );
    }

    final formData = FormData.fromMap(formDataMap);

    await DioClient.dio.post(
      '/checkin',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> checkOut({
    required int employeeId,
    required Uint8List imageBytes,
    required double lat,
    required double lng,
    required double distance,
    required String locationStatus,
    String? earlyReason,
    DateTime? checkoutAt,
  }) async {
    final formDataMap = <String, dynamic>{
      "employee_id": employeeId,
      "latitude_checkout": lat,
      "longitude_checkout": lng,
      "distance_checkout": distance,
      "location_status": locationStatus,
      "gambar_checkout": MultipartFile.fromBytes(
        imageBytes,
        filename: "checkout.jpg",
      ),
    };

    if (checkoutAt != null) {
      formDataMap["checkout_at"] = checkoutAt.toIso8601String();
    }

    if (earlyReason != null && earlyReason.trim().isNotEmpty) {
      formDataMap["early_reason"] = earlyReason;
    }

    final formData = FormData.fromMap(formDataMap);

    await DioClient.dio.patch(
      '/checkout',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
