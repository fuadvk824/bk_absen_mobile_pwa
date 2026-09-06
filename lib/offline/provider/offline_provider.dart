import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/offline_repository.dart';
import '../models/offline_attendance_model.dart';

final offlineRepositoryProvider = Provider(
  (_) => OfflineRepository(),
);

final offlineListProvider =
    FutureProvider<List<OfflineAttendanceModel>>((ref) async {
  return ref.read(offlineRepositoryProvider).getAll();
});

final offlinePendingCountProvider =
    FutureProvider<int>((ref) async {
  return ref.read(offlineRepositoryProvider).countPending();
});