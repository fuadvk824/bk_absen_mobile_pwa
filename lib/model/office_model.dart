class OfficeModel {
  final double latitude;
  final double longitude;
  final double radius;

  OfficeModel({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      // latitude: (json['latitude'] ?? 0).toDouble(),
      // longitude: (json['longitude'] ?? 0).toDouble(),
      // radius: (json['radius'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}

