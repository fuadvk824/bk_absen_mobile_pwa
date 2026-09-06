import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:bk_absen/core/network/server_checker.dart';
import 'package:bk_absen/core/storage/cache_service.dart';
import 'package:bk_absen/features/home/data/attendance_repository.dart';
import 'package:bk_absen/offline/repository/offline_repository.dart';
import 'package:dio/dio.dart';

class SyncService {
  final OfflineRepository repo = OfflineRepository();

  final AttendanceRepository attendanceRepo = AttendanceRepository();

  Future<void> syncPending() async {
    developer.log('================ SYNC START ================');

    final alive = await ServerChecker.isAlive();

    developer.log('SERVER ALIVE = $alive');

    if (!alive) {
      developer.log('SERVER MASIH DOWN');

      return;
    }

    developer.log('SERVER HIDUP');

    final pending = await repo.getPending();

    developer.log('TOTAL PENDING = ${pending.length}');

    if (pending.isEmpty) {
      developer.log('TIDAK ADA DATA PENDING');

      return;
    }

    for (final item in pending) {
      developer.log('------------------------------------------');

      developer.log(
        'SYNC ITEM '
        'key=${item.key} '
        'type=${item.type} '
        'employee=${item.employeeId} '
        'createdAt=${item.createdAt}',
      );

      if (item.imageBytes.isEmpty) {
        developer.log('GAGAL: foto ${item.type} kosong');

        await repo.delete(item.key);

        developer.log('ITEM DIHAPUS KARENA FOTO KOSONG');

        continue;
      }

      if (item.lateProofBytes != null && item.lateProofBytes!.isEmpty) {
        developer.log('GAGAL: foto bukti terlambat kosong');

      
        continue;
      }

      try {
       

        if (item.type == 'checkin') {
          developer.log('UPLOAD CHECKIN...');

          await attendanceRepo.checkIn(
            employeeId: item.employeeId,

            imageBytes: Uint8List.fromList(item.imageBytes),

            lat: item.latitude,
            lng: item.longitude,

            distance: item.distance,

            locationStatus: item.locationStatus,

            lateReason: item.lateReason,

            lateProofBytes: item.lateProofBytes == null
                ? null
                : Uint8List.fromList(item.lateProofBytes!),

            checkinAt: item.createdAt,
          );
        }
      
        else if (item.type == 'checkout') {
          developer.log('UPLOAD CHECKOUT...');

          await attendanceRepo.checkOut(
            employeeId: item.employeeId,

            imageBytes: Uint8List.fromList(item.imageBytes),

            lat: item.latitude,
            lng: item.longitude,

            distance: item.distance,

            locationStatus: item.locationStatus,

            earlyReason: item.earlyReason,

            checkoutAt: item.createdAt,
          );
        }
        
        else {
          developer.log(
            'TYPE TIDAK DIKENALI: '
            '${item.type}',
          );

          continue;
        }

        developer.log(
          'UPLOAD '
          '${item.type.toUpperCase()} '
          'BERHASIL',
        );

       
        await repo.delete(item.key);

        developer.log(
          'HIVE ITEM DIHAPUS: '
          'key=${item.key} '
          'type=${item.type}',
        );

        final remaining = await repo.countPending();

        developer.log('SISA PENDING = $remaining');
      }
      
      on DioException catch (e) {
        developer.log(
          'DIO ERROR '
          '${item.type.toUpperCase()}',
        );

        developer.log(
          'STATUS CODE = '
          '${e.response?.statusCode}',
        );

        developer.log(
          'RESPONSE = '
          '${e.response?.data}',
        );

        developer.log('MESSAGE = ${e.message}');
 
        break;
      }
    
      catch (e, stack) {
        developer.log(
          'SYNC ERROR '
          '${item.type.toUpperCase()}: $e',
        );

        developer.log('STACK: $stack');

        break;
      }
    }

    final remaining = await repo.countPending();

    developer.log('==========================================');

    developer.log(
      'SYNC SELESAI '
      '| SISA PENDING = $remaining',
    );

    if (remaining == 0) {
      await CacheService.delete('attendance_today');

      developer.log('SEMUA OFFLINE DATA SUDAH TERKIRIM');
      developer.log('CACHE attendance_today DIHAPUS');
    } else {
      developer.log(
        'MASIH ADA DATA PENDING. '
        'CACHE TIDAK DIHAPUS.',
      );
    }

    developer.log('================ SYNC END ================');
  }
}
