import 'package:bk_absen/offline/services/sync_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(ref);
});