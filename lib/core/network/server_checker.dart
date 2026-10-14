import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class ServerChecker {
  ServerChecker._();

  static Future<bool> isAlive() async {
    try {
      final response = await DioClient.dio.get(
        "/health",
        options: Options(
          connectTimeout: const Duration(seconds: 3),
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      return response.statusCode == 200 &&
          response.data is Map &&
          response.data['status'] == 'ok';
    } on DioException  {
      return false;
    } catch (_){
      return false;
    }
  }
}
 