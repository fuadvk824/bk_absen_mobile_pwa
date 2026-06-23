class CheckInOutModel {
  final String tanggal;
  final String? checkIn;
  final String? checkOut;
  final String? totalWaktu;
  final bool isOff;
  final String? limitLate; //tambahan
  final bool hasShift;

  CheckInOutModel({
    required this.tanggal,
    this.checkIn,
    this.checkOut,
    this.totalWaktu,
    required this.isOff,
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
      limitLate: json['limit_late'], //tambahan
      hasShift: json['has_shift'] ?? false,
    );
  }
}
