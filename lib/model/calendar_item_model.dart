class CalendarItem {
  final DateTime date;
  final String type;
  final String status;
  final String checkIn;
  final String checkOut;
  final String totalWaktu;
  final int warna;
  final String lateReason;

  CalendarItem({
    required this.date,
    required this.type,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.totalWaktu,
    required this.warna,
    required this.lateReason,
  });

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    return CalendarItem(
      date: DateTime.parse(json['date']).toLocal(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      checkIn: json['check_in'] ?? '--:--',
      checkOut: json['check_out'] ?? '--:--',
      totalWaktu: json['total_waktu'] ?? '--:--',
      warna: json['warna'] ?? 0xff9e9e9e,
      lateReason: json['late_reason'] ?? '-',
    );
  }
}