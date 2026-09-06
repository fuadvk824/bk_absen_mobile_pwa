class LetterModel {
  final int id;
  final int? employeeId;
  final String employeeCode;
  final String name;
  final String nameOffice;
  final String nomorSurat;
  final String jenisSurat;
  final String tanggalSurat;
  final String alasanSurat;
  final String? pdfUrl;
  final String? sentAt;
  final String? readAt;
  final bool isRead;

  LetterModel({
    required this.id,
    this.employeeId,
    required this.employeeCode,
    required this.name,
    required this.nameOffice,
    required this.nomorSurat,
    required this.jenisSurat,
    required this.tanggalSurat,
    required this.alasanSurat,
    this.pdfUrl,
    this.sentAt, 
    this.readAt,
    required this.isRead,
  });

  LetterModel copyWith({
    int? id,
    int? employeeId,
    String? employeeCode,
    String? name,
    String? nameOffice,
    String? nomorSurat,
    String? jenisSurat,
    String? tanggalSurat,
    String? alasanSurat,
    String? pdfUrl,
    String? sentAt,
    String? readAt,
    bool? isRead,
  }) {
    return LetterModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      nameOffice: nameOffice ?? this.nameOffice,
      nomorSurat: nomorSurat ?? this.nomorSurat,
      jenisSurat: jenisSurat ?? this.jenisSurat,
      tanggalSurat: tanggalSurat ?? this.tanggalSurat,
      alasanSurat: alasanSurat ?? this.alasanSurat,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'],
      employeeCode: json['employee_code'] ?? '',
      name: json['name'] ?? '',
      nameOffice: json['name_office'] ?? '',
      nomorSurat: json['nomor_surat'] ?? '',
      jenisSurat: json['jenis_surat'] ?? '',
      tanggalSurat: json['tanggal_surat'] ?? '',
      alasanSurat: json['alasan_surat'] ?? '',
      pdfUrl: json['pdf_url'],
      sentAt: json['sent_at'],
      readAt: json['read_at'],
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_code': employeeCode,
      'name': name,
      'name_office': nameOffice,
      'nomor_surat': nomorSurat,
      'jenis_surat': jenisSurat,
      'tanggal_surat': tanggalSurat,
      'alasan_surat': alasanSurat,
      'pdf_url': pdfUrl,
      'sent_at': sentAt,
      'read_at': readAt,
      'is_read': isRead,
    };
  }
}
