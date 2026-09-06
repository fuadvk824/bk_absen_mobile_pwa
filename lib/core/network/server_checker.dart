import 'package:dio/dio.dart';

import 'dio_client.dart';

class ServerChecker {
  ServerChecker._();

  static Future<bool> isAlive() async {
    try {
      await DioClient.dio.get(
        "/attendance",
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      return true;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}