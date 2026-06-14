class OvertimeModel {
  final int id;
  final String date;
  final String timeFrom;
  final String timeTo;
  final String reason;
  final String status;
  final int warna;

  OvertimeModel({
    required this.id,
    required this.date,
    required this.timeFrom,
    required this.timeTo,
    required this.reason,
    required this.status,
    required this.warna,
  });

  factory OvertimeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      timeFrom: json['time_from'] ?? '',
      timeTo: json['time_to'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',

      // penting: backend kamu kirim 0xffffc107 (hex int)
      warna: _parseColor(json['warna']),
    );
  }

  static int _parseColor(dynamic value) {
    if (value == null) return 0xff9e9e9e;

    if (value is int) return value;

    if (value is String) {
      // kalau backend kirim "0xffffc107"
      return int.tryParse(value) ?? 0xff9e9e9e;
    }

    return 0xff9e9e9e;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date,
      "time_from": timeFrom,
      "time_to": timeTo,
      "reason": reason,
      "status": status,
      "warna": warna,
    };
  }
}