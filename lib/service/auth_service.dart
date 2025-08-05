import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/auth_model.dart';
import '../network/network_api.dart'; // untuk baseUrlHp

class AuthService {
  final String uri = "$baseUrlHp/auth/login";

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        return LoginResponse.fromJson(jsonResult);
      } else {
        // Tangani respons gagal dengan isi body jika tersedia
        final error = jsonDecode(response.body);
        throw Exception(
            error['meta']?['message'] ?? 'Login gagal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }
}
