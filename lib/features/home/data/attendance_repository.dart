import 'dart:typed_data';

import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/check_in_out_model.dart';
import 'package:bk_absen/model/user_model.dart';
import 'package:dio/dio.dart';

class AttendanceRepository {
  Future<UserModel?> getUser() async {
    try {
      final res = await DioClient.dio.get('/me');

      return UserModel.fromJson(res.data);
    } catch (_) {
      return null;
    }
  }

  Future<CheckInOutModel?> getToday() async {
    try {
      final res = await DioClient.dio.get('/attendance');
      final data = res.data['data'] ?? res.data;
      return CheckInOutModel.fromJson(data);
    } catch (_) {
      return null;
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
  }) async {
    final formDataMap = {
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

    if (lateReason != null) {
      formDataMap["late_reason"] = lateReason;
    }

    if (lateProofBytes != null) {
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
  }) async {
    final formDataMap = {
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

    if (earlyReason != null) {
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
