class OvertimeModel {
  final int id;
  final String date;
  final String timeFrom;
  final String timeTo;
  final String reason;
  final String status;
  final int warna;
  final int totalMinutes;

  OvertimeModel({
    required this.id,
    required this.date,
    required this.timeFrom,
    required this.timeTo,
    required this.reason,
    required this.status,
    required this.warna,
    required this.totalMinutes,
  });

  factory OvertimeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      timeFrom: json['time_from'] ?? '',
      timeTo: json['time_to'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      warna: _parseColor(json['warna']),
      totalMinutes: json['total_minutes'] ?? 0,
    );
  }

  static int _parseColor(dynamic value) {
    if (value == null) return 0xff9e9e9e;

    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value) ?? 0xff9e9e9e;
    }

    return 0xff9e9e9e;
  }

  Duration get totalDuration {
    return Duration(minutes: totalMinutes);
  }

  String get totalDurationText {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0 && minutes == 0) {
      return '0jam';
    }

    if (minutes == 0) { 
      return '${hours}jam';
    }

    if (hours == 0) {
      return '${minutes}menit';
    }

    return '${hours}j ${minutes}m';
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
      "total_minutes": totalMinutes,
    };
  }
}
