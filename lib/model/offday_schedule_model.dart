import 'package:bk_absen/model/offday_request_model.dart';

class OffdayScheduleModel {
  final int id;
  final String startDate;
  final String endDate;
  final int totalWorkDays;
  final int totalOffDays;
  final List<OffdayScheduleDayModel> days;

  OffdayScheduleModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalWorkDays,
    required this.totalOffDays,
    required this.days,
  });

  factory OffdayScheduleModel.fromJson(Map<String, dynamic> json) {
    return OffdayScheduleModel(
      id: json['id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalWorkDays: json['total_work_days'] ?? 0,
      totalOffDays: json['total_off_days'] ?? 0,
      days: (json['days'] as List? ?? [])
          .map(
            (e) =>
                OffdayScheduleDayModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class OffdayScheduleDayModel {
  final int id;
  final String workDate;
  final bool isOff;
  final String status;
  final String? note;

  final bool hasPendingRequest;
  final OffdayRequestModel? pendingRequest;

  const OffdayScheduleDayModel({
    required this.id,
    required this.workDate,
    required this.isOff,
    required this.status,
    this.note,
    this.hasPendingRequest = false,
    this.pendingRequest,
  });

  factory OffdayScheduleDayModel.fromJson(Map<String, dynamic> json) {
    return OffdayScheduleDayModel(
      id: json['id'] as int? ?? 0,

      workDate: json['work_date']?.toString() ?? '',

      isOff: json['is_off'] == true,

      status: json['status']?.toString() ?? '',

      note: json['note']?.toString(),

      hasPendingRequest: json['has_pending_request'] == true,

      pendingRequest: json['pending_request'] != null
          ? OffdayRequestModel.fromJson(
              Map<String, dynamic>.from(json['pending_request']),
            )
          : null,
    );
  }
}
