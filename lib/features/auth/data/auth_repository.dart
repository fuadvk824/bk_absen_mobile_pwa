import 'package:bk_absen/core/storage/cache_service.dart';
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_manager.dart';
import '../../../model/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    try {
      final res = await DioClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final token = res.data['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('Token login tidak ditemukan.');
      }

      await TokenManager.set(token);

      final me = await DioClient.dio.get('/me');

      final userData = Map<String, dynamic>.from(me.data);

      await CacheService.write('user', userData);

      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Server sedang tidak dapat dihubungi. '
          'Silakan coba beberapa menit lagi.',
        );
      }

      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];

        if (message is String && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      if (e.response != null) {
        throw Exception(
          'Terjadi kesalahan pada server '
          '(${e.response?.statusCode}). '
          'Silakan coba beberapa menit lagi.',
        );
      }

      throw Exception('Tidak dapat terhubung ke server. Silakan coba lagi.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  Future<UserModel?> me() async {
    try {
      final res = await DioClient.dio.get('/me');

      final userData = Map<String, dynamic>.from(res.data);

      await CacheService.write('user', userData);

      return UserModel.fromJson(userData);
    } catch (_) {
      
      final cache = CacheService.read('user');

      if (cache != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(cache));
      }

      return null;
    }
  }

  Future<void> logout() async {
    try {
      await DioClient.dio.post('/logout');
    } catch (_) {
      // Tetap logout lokal walaupun server tidak tersedia
    }

    await TokenManager.clear();
    await CacheService.delete('user');
  }
}
