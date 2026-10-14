class ColleagueOffdayModel {
  final int id;
  final int workScheduleId;
  final String workDate;
  final bool isOff;
  final String? note;

  const ColleagueOffdayModel({
    required this.id,
    required this.workScheduleId,
    required this.workDate,
    required this.isOff,
    this.note,
  });

  factory ColleagueOffdayModel.fromJson(Map<String, dynamic> json) {
    return ColleagueOffdayModel(
      id: json['id'] as int? ?? 0,
      workScheduleId: json['work_schedule_id'] as int? ?? 0,
      workDate: json['work_date']?.toString() ?? '',
      isOff: json['is_off'] == true,
      note: json['note']?.toString(),
    );
  }
}
