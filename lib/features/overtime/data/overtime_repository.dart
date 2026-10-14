import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/overtime_model.dart';
import 'package:bk_absen/model/overtime_period.dart';
import 'package:dio/dio.dart';

class OvertimeRepository {
  Future<OvertimeResponse> fetchOvertime({required int period}) async {
    try {
      final response = await DioClient.dio.get(
        '/myovertime',
        queryParameters: {'period': period},
      );

      final responseData = response.data;

      final data = (responseData['data'] as List)
          .map((e) => OvertimeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final periodData = responseData['period'];

      final totalOvertimeMinutes = periodData?['total_overtime_minutes'] ?? 0;

      return OvertimeResponse(
        data: data,
        totalOvertimeMinutes: totalOvertimeMinutes,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed get overtime');
    }
  }

  Future<String> submitOvertime({
    required String date,
    required String timeFrom,
    required String timeTo,
    required String reason,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/overtime',
        data: {
          "date": date,
          "time_from": timeFrom,
          "time_to": timeTo,
          "reason": reason,
        },
      );

      return response.data['message'] ?? "Berhasil";
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? "Failed submit overtime";
    }
  }
}
