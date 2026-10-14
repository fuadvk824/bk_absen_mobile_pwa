import 'package:bk_absen/model/calendar_item_model.dart';

class CalendarLegend {
  final String status;
  final int warna;

  CalendarLegend({required this.status, required this.warna});

  factory CalendarLegend.fromJson(Map<String, dynamic> json) {
    return CalendarLegend(
      status: json['status'] ?? '',
      warna: json['warna'] ?? 0xff9e9e9e,
    );
  }
}

class CalendarResponse {
  final List<CalendarItem> items;
  final List<CalendarLegend> legend;

  CalendarResponse({required this.items, required this.legend});

  factory CalendarResponse.fromJson(Map<String, dynamic> json) {
    return CalendarResponse(
      items: (json['data'] as List)
          .map((e) => CalendarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      legend: (json['legend'] as List? ?? [])
          .map((e) => CalendarLegend.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
