// import 'package:bk_absen/core/storage/cache_service.dart';

// class TestAttendanceCache {
//   static Future<void> save({
//     required String tanggal,
//     required String checkIn,
//     required String checkOut,
//     String? totalWaktu,
//     bool isOff = false,
//     bool hasShift = true,
//     String? limitLate,
//   }) async {
//     await CacheService.write(
//       'attendance_test_$tanggal',
//       {
//         'tanggal': tanggal,
//         'check_in': checkIn,
//         'check_out': checkOut,
//         'total_waktu': totalWaktu,
//         'is_off': isOff,
//         'has_shift': hasShift,
//         'limit_late': limitLate,
//       },
//     );
//   }

//   static dynamic get(String tanggal) {
//     return CacheService.read('attendance_test_$tanggal');
//   }

//   static Future<void> delete(String tanggal) async {
//     await CacheService.delete('attendance_test_$tanggal');
//   }

//   static Future<void> clear() async {
//     // Hapus tanggal-tanggal test yang kamu gunakan.
//     await CacheService.delete('attendance_test_2026-08-10');
//     await CacheService.delete('attendance_test_2026-08-11');
//   }
// }
