import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> write(String key, Map<String, dynamic> data) async {
    await _prefs?.setString(key, jsonEncode(data));
  }

  static Map<String, dynamic>? read(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<void> delete(String key) async {
    await _prefs?.remove(key);
  }
}