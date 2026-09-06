import 'package:hive_ce/hive.dart';

import '../models/offline_attendance_model.dart';

class OfflineRepository {
  final Box<OfflineAttendanceModel> box = Hive.box<OfflineAttendanceModel>(
    'offline_attendance',
  );

  Future<void> save(OfflineAttendanceModel item) async {
    await box.add(item);
  }

  Future<List<OfflineAttendanceModel>> getPending() async {
    final list = box.values.where((item) => !item.synced).toList();

    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return list;
  }

  Future<void> markSynced(dynamic key) async {
    final item = box.get(key);

    if (item == null) return;

    item.synced = true;

    await item.save();
  }

  Future<List<OfflineAttendanceModel>> getAll() async {
    return box.values.toList();
  }

  Future<int> countPending() async {
    return box.values.where((item) => !item.synced).length;
  }

  Future<void> delete(dynamic key) async {
    await box.delete(key);
  }

  Future<void> clear() async {
    await box.clear();
  }
}
