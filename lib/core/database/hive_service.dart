import 'package:bk_absen/offline/models/offline_sync_failure_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../offline/models/offline_attendance_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrasi adapter
    Hive.registerAdapter(OfflineAttendanceModelAdapter());
    Hive.registerAdapter(OfflineSyncFailureModelAdapter());

    // Membuka box absensi offline
    await Hive.openBox<OfflineAttendanceModel>(
      "offline_attendance",
    );

    // Membuka box laporan kegagalan sinkronisasi
    await Hive.openBox<OfflineSyncFailureModel>(
      "offline_sync_failures",
    );
  }
}
