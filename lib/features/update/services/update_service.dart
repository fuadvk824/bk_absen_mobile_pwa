
import 'package:bk_absen/features/update/data/app_version.dart';

import '../../../model/app_version_model.dart';
import '../data/version_repository.dart';

class UpdateService {
  final repo = VersionRepository();

  String getCurrentVersion() {
    return appVersion;
  }

  Future<AppVersionModel> getLatestVersion() async {
    return await repo.checkVersion();
  }

  Future<bool> hasUpdate() async {
    final latest = await getLatestVersion();

    return appVersion != latest.version;
  }
}