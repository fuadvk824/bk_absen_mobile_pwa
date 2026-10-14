class OffdayRequestModel {
  final int id;
  final int employeeId;
  final int workScheduleDayId;
  final String date;
  final String statusStartDate;
  final String statusEndDate;
  final String status;
  final String reason;

  OffdayRequestModel({
    required this.id,
    required this.employeeId,
    required this.workScheduleDayId,
    required this.date,
    required this.statusStartDate,
    required this.statusEndDate,
    required this.status,
    required this.reason,
  });

  factory OffdayRequestModel.fromJson(Map<String, dynamic> json) {
    return OffdayRequestModel(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      workScheduleDayId: json['work_schedule_day_id'] ?? 0,
      date: json['date'] ?? '',
      statusStartDate: json['status_start_date'] ?? '',
      statusEndDate: json['status_end_date'] ?? '',
      status: json['status'] ?? 'pending',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'work_schedule_day_id': workScheduleDayId,
      'date': date,
      'status_start_date': statusStartDate,
      'status_end_date': statusEndDate,
      'status': status,
      'reason': reason,
    };
  }
}
