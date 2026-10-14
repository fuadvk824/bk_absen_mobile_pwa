import 'package:bk_absen/model/colleague_offday_model.dart';

class ColleagueScheduleModel {
  final int employeeId;
  final String employeeName;
  final List<ColleagueOffdayModel> offdays;

  const ColleagueScheduleModel({
    required this.employeeId,
    required this.employeeName,
    required this.offdays,
  });

  factory ColleagueScheduleModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ColleagueScheduleModel(
      employeeId: json['employee_id'] as int? ?? 0,

      employeeName:
          json['employee_name']?.toString() ?? '',

      offdays: (json['offdays'] as List? ?? [])
          .map(
            (item) => ColleagueOffdayModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}