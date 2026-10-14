import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/calendar_legend_model.dart';
import 'package:dio/dio.dart';

class CalendarRepository {
  Future<CalendarResponse> fetch({
    required int year,
    required int month,
  }) async {
    try {
      final res = await DioClient.dio.get(
        '/mycalendar',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      return CalendarResponse.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Tidak dapat terhubung ke server. '
          'Periksa koneksi internet.',
        );
      }

      if (e.response?.statusCode == 401) {
        throw Exception(
          'Sesi login tidak valid. Silakan login kembali.',
        );
      }

      throw Exception(
        'Gagal mengambil data kalender.',
      );
    }
  }
}