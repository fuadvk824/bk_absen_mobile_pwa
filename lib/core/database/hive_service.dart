import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../offline/models/offline_attendance_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(OfflineAttendanceModelAdapter());
    await Hive.openBox<OfflineAttendanceModel>(
      "offline_attendance",
    );
  }
}
