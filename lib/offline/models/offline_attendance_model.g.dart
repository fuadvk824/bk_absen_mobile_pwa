// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_attendance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineAttendanceModelAdapter
    extends TypeAdapter<OfflineAttendanceModel> {
  @override
  final typeId = 0;

  @override
  OfflineAttendanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineAttendanceModel(
      type: fields[0] as String,
      employeeId: (fields[1] as num).toInt(),
      imageBytes: (fields[2] as List).cast<int>(),
      latitude: (fields[3] as num).toDouble(),
      longitude: (fields[4] as num).toDouble(),
      distance: (fields[5] as num).toDouble(),
      locationStatus: fields[6] as String,
      lateReason: fields[7] as String?,
      lateProofBytes: (fields[8] as List?)?.cast<int>(),
      earlyReason: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      status: fields[11] == null ? "pending" : fields[11] as String,
      retryCount: fields[12] == null ? 0 : (fields[12] as num).toInt(),
      synced: fields[13] == null ? false : fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineAttendanceModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.imageBytes)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.distance)
      ..writeByte(6)
      ..write(obj.locationStatus)
      ..writeByte(7)
      ..write(obj.lateReason)
      ..writeByte(8)
      ..write(obj.lateProofBytes)
      ..writeByte(9)
      ..write(obj.earlyReason)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.retryCount)
      ..writeByte(13)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineAttendanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
