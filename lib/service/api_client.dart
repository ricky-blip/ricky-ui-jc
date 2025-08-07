// service/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/utils/secure_storage.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<http.Response> get(String endpoint) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan login kembali.');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);
    return response; // Kembalikan response mentah
  }

  Future<http.Response> post(String endpoint, Object? body) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan login kembali.');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));
    return response; // Kembalikan response mentah
  }

  Future<http.Response> put(String endpoint, Object? body) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan login kembali.');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(body));
    return response; // Kembalikan response mentah
  }
}
