import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_manager.dart';
import '../../../model/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    try {
      final res = await DioClient.dio.post(
        '/login',
        data: {"email": email, "password": password},
      );

      final token = res.data['token'];
      await TokenManager.set(token);

      final me = await DioClient.dio.get('/me');
      return UserModel.fromJson(me.data);
    } on DioException catch (e) {
      // ambil message dari backend
      final msg = e.response?.data['message'] ?? "Login gagal";
      throw Exception(msg);
    }
  }
  // Future<UserModel> login(String email, String password) async {
  //   final res = await DioClient.dio.post(
  //     '/login',
  //     data: {"email": email, "password": password},
  //   );

  //   final token = res.data['token'];
  //   await TokenManager.set(token);

  //   final me = await DioClient.dio.get('/me');
  //   return UserModel.fromJson(me.data);
  // }

  Future<UserModel?> me() async {
    try {
      final res = await DioClient.dio.get('/me');
      return UserModel.fromJson(res.data);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await DioClient.dio.post('/logout');
    } catch (_) {}

    await TokenManager.clear();
  }
}
