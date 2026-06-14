class UserModel {
  final int userId;
  final int employeeId;
  final String name;
  final String? department;
  final String? position;
  final String? checkInTime;
  final String? checkOutTime;
  final int? toleransiLate;

  final double? officeLatitude;
  final double? officeLongitude;
  final double? officeRadius;

  final String keyStatus;

  UserModel({
    required this.userId,
    required this.employeeId,
    required this.name,
    this.department,
    this.position,
    this.checkInTime,
    this.checkOutTime,
    this.toleransiLate,

    this.officeLatitude,
    this.officeLongitude,
    this.officeRadius,

    required this.keyStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId'].toString()) ?? 0,

      employeeId: json['employeeId'] is int
          ? json['employeeId']
          : int.tryParse(json['employeeId'].toString()) ?? 0,
      name: json['name'],
      department: json['department'],
      position: json['position'],
      checkInTime: json['checkin_time'],
      checkOutTime: json['checkout_time'],
      toleransiLate: json['toleransi_late'],

      officeLatitude: (json['office_latitude'] as num?)?.toDouble(),
      officeLongitude: (json['office_longitude'] as num?)?.toDouble(),
      officeRadius: (json['office_radius'] as num?)?.toDouble(),

      keyStatus: json['key_status'] ?? 'old',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'employeeId': employeeId,
      'name': name,
      'department': department,
      'position': position,
      'checkin_time': checkInTime,
      'checkout_time': checkOutTime,
      'toleransi_late': toleransiLate,

      'office_latitude': officeLatitude,
      'office_longitude': officeLongitude,
      'office_radius': officeRadius,

      'key_status': keyStatus,
    };
  }
}
