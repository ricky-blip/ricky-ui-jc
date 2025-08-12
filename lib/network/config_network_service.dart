import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const _keyBaseUrl = 'baseUrlHp';
  static const defaultBaseUrl = 'http://192.168.10.999:8080/api';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl) ?? defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, url);
  }
}
