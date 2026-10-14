import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/colleague_pending_request_model.dart';
import 'package:bk_absen/model/colleague_schedule_model.dart';
import 'package:bk_absen/model/offday_schedule_model.dart';
import 'package:dio/dio.dart';

class OffdayResponse {
  final List<OffdayScheduleModel> data;
  final List<ColleagueScheduleModel> colleagueOffdays;
  final List<ColleaguePendingScheduleModel> colleaguePendingRequests;

  final String periodStart;
  final String periodEnd;

  OffdayResponse({
    required this.data,
    required this.colleagueOffdays,
    required this.colleaguePendingRequests,
    required this.periodStart,
    required this.periodEnd,
  });
}

class OffdayRequestResponse {
  final int total;
  final String message;

  OffdayRequestResponse({required this.total, required this.message});
}

class OffdayRepository {
  Future<OffdayResponse> fetchSchedule({int? year}) async {
    try {
      final response = await DioClient.dio.get(
        '/offday/schedule',
        queryParameters: year != null ? {'year': year} : null,
      );

      final responseData = response.data;

      final data = (responseData['data'] as List? ?? [])
          .map(
            (e) => OffdayScheduleModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();

      final colleagueOffdays =
          (responseData['colleague_offdays'] as List? ?? [])
              .map(
                (e) => ColleagueScheduleModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
      final colleaguePendingRequests =
          (responseData['colleague_pending_offday_requests'] as List? ?? [])
              .map(
                (e) => ColleaguePendingScheduleModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();

      return OffdayResponse(
        data: data,
        colleagueOffdays: colleagueOffdays,
        colleaguePendingRequests: colleaguePendingRequests,
        periodStart: responseData['period_start']?.toString() ?? '',
        periodEnd: responseData['period_end']?.toString() ?? '',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed get work schedule',
      );
    }
  }

  Future<OffdayRequestResponse> submitOffday({
    required String reason,
    required List<Map<String, dynamic>> changes,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/offday/requests',
        data: {'reason': reason, 'changes': changes},
      );

      final responseData = response.data;

      return OffdayRequestResponse(
        total: responseData['data']?['total'] ?? 0,
        message: responseData['message'] ?? 'Berhasil',
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed submit offday');
    }
  }

  Future<void> deleteRequest(int requestId) async {
    try {
      final response = await DioClient.dio.delete(
        '/offday/requests/$requestId',
      );

      final data = response.data;

      if (data is Map && data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal menghapus pengajuan.');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal menghapus pengajuan.',
      );
    }
  }
}
