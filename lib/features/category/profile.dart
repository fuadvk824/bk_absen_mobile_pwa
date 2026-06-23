// import 'package:flutter/material.dart';
// import 'package:bk_absen/utils/app_colors.dart';

// class Profile extends StatelessWidget {
//   const Profile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(child: Center(child: Text('Menu Profile, pending...'))),
//     );
//   }
// }
import 'package:bk_absen/features/update/services/update_service.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final updateService = UpdateService();

  String version = '-';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVersion();
  }

  Future<void> loadVersion() async {
    try {
      final latest = await updateService.getLatestVersion();

      setState(() {
        version = latest.version;
        loading = false;
      });
    } catch (e) {
      setState(() {
        version = 'Gagal memuat versi';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : Text(
                  'Versi Backend: v$version',
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }
}
