import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/auth/auth_model.dart';
import 'package:ricky_ui_jc/model/auth/change_password.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';

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

  Future<ChangePasswordResponse> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final token = await SecureStorage.read(key: 'token');

    final response = await http.put(
      Uri.parse('$baseUrlHp/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "confirmNewPassword": confirmNewPassword,
      }),
    );

    final json = jsonDecode(response.body);
    return ChangePasswordResponse.fromJson(json);
  }

  Future<void> saveFcmToken(String fcmToken) async {
    final token = await SecureStorage.read(key: 'token');
    final url = Uri.parse('$baseUrlHp/auth/save-fcm-token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal simpan FCM token');
    }
  }
}
