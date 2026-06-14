

class LeaveCategoryModel {
  final int id;
  final String leaveName;
  final int remainingDays;

  LeaveCategoryModel({
    required this.id,
    required this.leaveName,
    required this.remainingDays,
  });

  factory LeaveCategoryModel.fromJson(Map<String, dynamic> json) {
    return LeaveCategoryModel(
      id: json['id'],
      leaveName: json['leave_name'],
      remainingDays: json['remaining_days'],
    );
  }
}