import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/overtime_model.dart';
import 'package:dio/dio.dart';

class OvertimeRepository {
  Future<List<OvertimeModel>> fetchOvertime() async {
    try {
      final response = await DioClient.dio.get('/myovertime');
      final data = response.data['data'] as List;
      return data.map((e) => OvertimeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed get overtime");
    }
  }

  Future<String> submitOvertime({
    required String date,
    required String timeFrom,
    required String timeTo,
    required String reason,
  }) async {
    try {
      final response = await DioClient.dio.post('/overtime', data: {
        "date": date,
        "time_from": timeFrom,
        "time_to": timeTo,
        "reason": reason,
      });
      return response.data['message'] ?? "Berhasil";
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? "Failed submit overtime";
    }
  }
}