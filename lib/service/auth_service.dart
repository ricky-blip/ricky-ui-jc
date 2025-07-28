import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/network/network_api.dart';
import '../model/auth_model.dart';

class AuthService {
  final String uri = "$baseUrlHp/auth/login";

  Future<LoginResponse> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login gagal: ${response.statusCode}');
    }
  }
}
