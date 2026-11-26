class CheckInOutModel {
  final String tanggal;
  final String? checkIn;
  final String? checkOut;
  final String? totalWaktu;
  final bool isOff;
  final bool isLeave;
  final String? limitLate; //tambahan
  final bool hasShift;

  CheckInOutModel({
    required this.tanggal,
    this.checkIn,
    this.checkOut,
    this.totalWaktu,
    required this.isOff,
    this.isLeave = false,
    this.limitLate, //tambahan
    this.hasShift = false,
  });

  factory CheckInOutModel.fromJson(Map<String, dynamic> json) {
    return CheckInOutModel(
      tanggal: json['tanggal'] ?? '',
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      totalWaktu: json['total_waktu'],
      isOff: json['is_off'] ?? false,
      isLeave: json['is_leave'] ?? false,
      limitLate: json['limit_late'], //tambahan
      hasShift: json['has_shift'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'check_in': checkIn,
      'check_out': checkOut,
      'total_waktu': totalWaktu,
      'is_off': isOff,
      'is_leave': isLeave,
      'limit_late': limitLate,
      'has_shift': hasShift,
    };
  }
}
