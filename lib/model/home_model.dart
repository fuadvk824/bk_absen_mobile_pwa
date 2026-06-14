class HomeModel {
  final String? tanggal;
  final String? checkIn;
  final String? checkOut;
  final String? totalWaktu;

  HomeModel({this.tanggal, this.checkIn, this.checkOut, this.totalWaktu});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      tanggal: json['tanggal']?.toString(),
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      totalWaktu: json['total_waktu'],
    );
  }
}
