// utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'jwt_decoder.dart'; // ← Pastikan ini diimpor

class SecureStorage {
  static final _storage = const FlutterSecureStorage();

  // === Baca & Tulis Data ===
  static Future<void> write(
      {required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  static Future<void> writeInt(
      {required String key, required int value}) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<int?> readInt({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  // === 🔐 Cek Token Valid ===
  static Future<bool> isTokenValid() async {
    try {
      final token = await read(key: 'token');
      if (token == null) return false;
      return !JwtDecoder.isTokenExpired(token);
    } catch (e) {
      return false;
    }
  }
}
