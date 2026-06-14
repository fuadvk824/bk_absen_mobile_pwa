import 'package:bk_absen/app/app_router.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/dio_client.dart';
import 'core/storage/cache_service.dart';
import 'core/storage/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FMTCObjectBoxBackend().initialise();
  // await FMTCStore('mapStore').manage.create();

  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: ".env");
  await CacheService.init(); 
  await TokenManager.init();

  DioClient.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // print("TOKEN DIPAKAI: ${TokenManager.token}");
    return MaterialApp(
      title: 'Absensi App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AppRouter(),
    );
  }
}
//camera ui nya per cantik
//tambahin refresh tiap menu

// 07 Mei 2026
//1. saat cuti diambil itu dicalender nya buat tampilan list baru, soalnya kalau tidak nanti tulisan nya tidak hadir
//2. cek ui baru camera
//3. besok mulai buat payroll