import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

class JwtDecoder {
  /// Decode JWT dan ambil payload
  static Map<String, dynamic> decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token tidak valid: bukan JWT');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded);
  }

  /// Cek apakah token sudah expired
  static bool isTokenExpired(String token) {
    try {
      final payload = decodeToken(token);
      if (payload.containsKey('exp')) {
        final exp = payload['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return exp < now;
      }
      return false; // Jika tidak ada exp, anggap tidak expired
    } catch (e) {
      return true; // Jika error decode, anggap expired (aman)
    }
  }
}
