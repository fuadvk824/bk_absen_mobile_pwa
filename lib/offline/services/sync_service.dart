import 'dart:typed_data';

import 'package:bk_absen/core/network/server_checker.dart';
import 'package:bk_absen/core/storage/cache_service.dart';
import 'package:bk_absen/features/home/data/attendance_repository.dart';
import 'package:bk_absen/offline/repository/offline_repository.dart';
import 'package:dio/dio.dart';

class SyncService {
  final OfflineRepository repo = OfflineRepository();

  final AttendanceRepository attendanceRepo = AttendanceRepository();

  Future<bool> syncPending() async {
    try {
      final alive = await ServerChecker.isAlive();

      if (!alive) {
        return false;
      }

      final pending = await repo.getPending();

      if (pending.isEmpty) {
        return true;
      }

      pending.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final item in pending) {
        if (item.imageBytes.isEmpty) {
          continue;
        }

        if (item.lateProofBytes != null && item.lateProofBytes!.isEmpty) {
          continue;
        }

        try {
          if (item.type == 'checkin') {
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
          } else if (item.type == 'checkout') {
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
          } else {
            return false;
          }

          await repo.delete(item.key);
        } on DioException catch (e) {
          final statusCode = e.response?.statusCode;

          if (item.type == 'checkin' &&
              statusCode == 400 &&
              e.response?.data is Map &&
              e.response?.data['message'] == 'Sudah checkin hari ini') {
            await repo.delete(item.key);

            continue;
          }

          if (statusCode != null) {
            break;
          }

          return false;
        } catch (e) {
          return false;
        }
      }

      final remaining = await repo.countPending();

      if (remaining == 0) {
        await CacheService.delete('attendance_today');
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
