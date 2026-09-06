class UserModel {
  final int userId;
  final int employeeId;
  final String name;
  final String jenisKelamin;

  final String? department;
  final String? position;
  final String? checkInTime;
  final String? checkOutTime;
  final int? toleransiLate;

  // final String? officeName;
  // final String? officeAddress;

  final double? officeLatitude;
  final double? officeLongitude;
  final double? officeRadius;

  final String keyStatus;

  UserModel({
    required this.userId,
    required this.employeeId,
    required this.name,
    required this.jenisKelamin,

    this.department,
    this.position,
    this.checkInTime,
    this.checkOutTime,
    this.toleransiLate,

    // this.officeName,
    // this.officeAddress,

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
      jenisKelamin: json['jenis_kelamin'],

      department: json['department'],
      position: json['position'],
      checkInTime: json['checkin_time'],
      checkOutTime: json['checkout_time'],
      toleransiLate: json['toleransi_late'],

      // officeName: json['office_name'],
      // officeAddress: json['office_address'],

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
      'jenis_kelamin': jenisKelamin,

      'department': department,
      'position': position,
      'checkin_time': checkInTime,
      'checkout_time': checkOutTime,
      'toleransi_late': toleransiLate,

      // 'office_name': officeName,
      // 'office_address': officeAddress,

      'office_latitude': officeLatitude,
      'office_longitude': officeLongitude,
      'office_radius': officeRadius,

      'key_status': keyStatus,
    };
  }
}
