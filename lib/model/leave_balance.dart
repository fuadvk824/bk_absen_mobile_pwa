class LeaveBalanceModel {
  final String leaveName;
  final int totalQuota;
  final int usedDays;
  final int remainingDays;

  LeaveBalanceModel({
    required this.leaveName,
    required this.totalQuota,
    required this.usedDays,
    required this.remainingDays,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      leaveName: json['leave_name'],
      totalQuota: json['total_quota'],
      usedDays: json['used_days'],
      remainingDays: json['remaining_days'],
    );
  }
}