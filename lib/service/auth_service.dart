// service/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/auth_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';

class AuthService {
  Future<LoginResponseModel> login(String username, String password) async {
    final url = Uri.parse('$baseUrlHp/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final jsonResponse = json.decode(response.body);

      final meta = jsonResponse['meta'];
      final code = meta['code'];
      final status = meta['status'];
      final message = meta['message'];

      if (code != 200 || status != 'success') {
        // Hanya tampilkan pesan utama saja dari meta.message
        throw Exception(message);
      }

      return LoginResponseModel.fromJson(jsonResponse);
    } catch (e) {
      print("Error saat login: $e");
      rethrow;
    }
  }
}
