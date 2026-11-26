// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sync_failure_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineSyncFailureModelAdapter
    extends TypeAdapter<OfflineSyncFailureModel> {
  @override
  final typeId = 1;

  @override
  OfflineSyncFailureModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineSyncFailureModel(
      reportId: fields[0] as String,
      clientEventId: fields[1] as String,
      attendanceType: fields[2] as String,
      attendanceAt: fields[3] as DateTime?,
      errorStage: fields[4] as String,
      httpStatus: (fields[5] as num?)?.toInt(),
      errorCode: fields[6] as String?,
      errorMessage: fields[7] as String,
      attemptNumber: (fields[8] as num).toInt(),
      appVersion: fields[9] as String?,
      deviceInfo: fields[10] as String?,
      metadata: (fields[11] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineSyncFailureModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.clientEventId)
      ..writeByte(2)
      ..write(obj.attendanceType)
      ..writeByte(3)
      ..write(obj.attendanceAt)
      ..writeByte(4)
      ..write(obj.errorStage)
      ..writeByte(5)
      ..write(obj.httpStatus)
      ..writeByte(6)
      ..write(obj.errorCode)
      ..writeByte(7)
      ..write(obj.errorMessage)
      ..writeByte(8)
      ..write(obj.attemptNumber)
      ..writeByte(9)
      ..write(obj.appVersion)
      ..writeByte(10)
      ..write(obj.deviceInfo)
      ..writeByte(11)
      ..write(obj.metadata)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineSyncFailureModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
