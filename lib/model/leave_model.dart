import 'package:bk_absen/model/leave_balance.dart';

class LeaveModel {
  final int id;
  final String leaveName;
  final String startDate;
  final String endDate;
  final String? file;
  final String? reason;
  final String status;
  final int warna;

  LeaveModel({
    required this.id,
    required this.leaveName,
    required this.startDate,
    required this.endDate,
    this.file,
    this.reason,
    required this.status,
    required this.warna,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      leaveName: json['leave_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      file: json['file'],
      reason: json['reason'],
      status: json['status'],
      warna: json['warna'],
    );
  }
}

class LeaveResponse {
   final bool success;
  final List<LeaveModel> leaves;
  final List<LeaveBalanceModel> balances;

  LeaveResponse({
     required this.success,
    required this.leaves,
    required this.balances,
  });

  factory LeaveResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return LeaveResponse(
      success: json['success'] ?? false,
      leaves: (data['leaves'] as List)
          .map((e) => LeaveModel.fromJson(e))
          .toList(),
      balances: (data['balances'] as List)
          .map((e) => LeaveBalanceModel.fromJson(e))
          .toList(),
    );
  }
}
