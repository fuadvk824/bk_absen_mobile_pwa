import 'package:bk_absen/features/home/provider/attendance_provider.dart';
import 'package:bk_absen/offline/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncManager {
  final Ref ref;

  bool _syncing = false;
  SyncManager(this.ref);

  Future<void> sync() async {
    if (_syncing) return;

    _syncing = true;

    try {
      final service = SyncService();
      final synced = await service.syncPending();

      if (synced) {
        await ref.read(attendanceProvider.notifier).load();
      }
    } finally {
      _syncing = false;
    }
  }

 
}
