import 'secure_storage.dart';

class TokenManager {
  static String? _token;

  static String? get token => _token;

  static Future<void> init() async {
    _token = await SecureStorage.read('token');
  }

  static Future<void> set(String token) async {
    _token = token;
    await SecureStorage.write('token', token);
  }

  static Future<void> clear() async {
    _token = null;
    await SecureStorage.delete('token');
  }
}