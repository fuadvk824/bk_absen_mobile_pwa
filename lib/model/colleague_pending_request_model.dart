class ColleaguePendingRequestModel {
  final int id;
  final int workScheduleDayId;
  final String date;
  final String statusStartDate;
  final String statusEndDate;
  final String status;
  final String reason;

  const ColleaguePendingRequestModel({
    required this.id,
    required this.workScheduleDayId,
    required this.date,
    required this.statusStartDate,
    required this.statusEndDate,
    required this.status,
    required this.reason,
  });

  factory ColleaguePendingRequestModel.fromJson(Map<String, dynamic> json) {
    return ColleaguePendingRequestModel(
      id: json['id'] as int? ?? 0,
      workScheduleDayId: json['work_schedule_day_id'] as int? ?? 0,
      date: json['date']?.toString() ?? '',
      statusStartDate: json['status_start_date']?.toString() ?? '',
      statusEndDate: json['status_end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      reason: json['reason']?.toString() ?? '',
    );
  }
}

class ColleaguePendingScheduleModel {
  final int employeeId;
  final String employeeName;
  final List<ColleaguePendingRequestModel> pendingRequests;

  const ColleaguePendingScheduleModel({
    required this.employeeId,
    required this.employeeName,
    required this.pendingRequests,
  });

  factory ColleaguePendingScheduleModel.fromJson(Map<String, dynamic> json) {
    return ColleaguePendingScheduleModel(
      employeeId: json['employee_id'] as int? ?? 0,
      employeeName: json['employee_name']?.toString() ?? '',
      pendingRequests: (json['pending_requests'] as List? ?? [])
          .map(
            (item) => ColleaguePendingRequestModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}