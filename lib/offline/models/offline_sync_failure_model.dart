import 'package:hive_ce/hive.dart';

part 'offline_sync_failure_model.g.dart';

@HiveType(typeId: 1)
class OfflineSyncFailureModel extends HiveObject {
  @HiveField(0)
  String reportId;

  @HiveField(1)
  String clientEventId;

  @HiveField(2)
  String attendanceType;

  @HiveField(3)
  DateTime? attendanceAt;

  @HiveField(4)
  String errorStage;

  @HiveField(5)
  int? httpStatus;

  @HiveField(6)
  String? errorCode;

  @HiveField(7)
  String errorMessage;

  @HiveField(8)
  int attemptNumber;

  @HiveField(9)
  String? appVersion;

  @HiveField(10)
  String? deviceInfo;

  @HiveField(11)
  Map<String, dynamic>? metadata;

  @HiveField(12)
  DateTime createdAt;

  OfflineSyncFailureModel({
    required this.reportId,
    required this.clientEventId,
    required this.attendanceType,
    this.attendanceAt,
    required this.errorStage,
    this.httpStatus,
    this.errorCode,
    required this.errorMessage,
    required this.attemptNumber,
    this.appVersion,
    this.deviceInfo,
    this.metadata,
    required this.createdAt,
  });
}
