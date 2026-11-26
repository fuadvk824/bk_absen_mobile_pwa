import 'package:hive_ce/hive.dart';

import '../models/offline_sync_failure_model.dart';

class OfflineSyncFailureRepository {
  final Box<OfflineSyncFailureModel> box = Hive.box<OfflineSyncFailureModel>(
    'offline_sync_failures',
  );

  Future<void> save(OfflineSyncFailureModel item) async {
    await box.add(item);
  }

  Future<List<OfflineSyncFailureModel>> getPending() async {
    return box.values.toList();
  }

  Future<void> delete(dynamic key) async {
    await box.delete(key);
  }

  Future<int> countPending() async {
    return box.length;
  }
}
