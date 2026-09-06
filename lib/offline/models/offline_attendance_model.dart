import 'package:hive_ce/hive.dart';

part 'offline_attendance_model.g.dart';

@HiveType(typeId: 0)
class OfflineAttendanceModel extends HiveObject {
  @HiveField(0)
  String type;

  @HiveField(1)
  int employeeId;

  /// gambar checkin / checkout
  @HiveField(2)
  List<int> imageBytes;

  @HiveField(3)
  double latitude;

  @HiveField(4)
  double longitude;

  @HiveField(5)
  double distance;

  @HiveField(6)
  String locationStatus;

  @HiveField(7)
  String? lateReason;

  /// bukti terlambat
  @HiveField(8)
  List<int>? lateProofBytes;

  @HiveField(9)
  String? earlyReason;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  String status;

  @HiveField(12)
  int retryCount;

  @HiveField(13)
  bool synced;

  OfflineAttendanceModel({
    required this.type,
    required this.employeeId,
    required this.imageBytes,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.locationStatus,
    this.lateReason,
    this.lateProofBytes,
    this.earlyReason,
    required this.createdAt,
    this.status = "pending",
    this.retryCount = 0,
    this.synced = false,
  });
}