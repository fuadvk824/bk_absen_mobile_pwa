import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/calendar_item_model.dart';

class CalendarRepository {
  Future<List<CalendarItem>> fetch({
    required int year,
    required int month,
  }) async {
    final res = await DioClient.dio.get(
      '/mycalendar',
      queryParameters: {
        "year": year,
        "month": month,
      },
    );

    return (res.data['data'] as List)
        .map((e) => CalendarItem.fromJson(e))
        .toList();
  }
}