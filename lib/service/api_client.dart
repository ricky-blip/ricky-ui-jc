// service/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/utils/secure_storage.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<http.Response> get(String endpoint) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) throw Exception('Sesi berakhir. Silakan login kembali.');

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<http.Response> post(String endpoint, Object? body) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) throw Exception('Sesi berakhir. Silakan login kembali.');

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  // ✅ Tambahkan metode PUT di sini
  Future<http.Response> put(String endpoint, Object? body) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) throw Exception('Sesi berakhir. Silakan login kembali.');

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Sesi telah berakhir. Silakan login kembali.');
    }
    if (response.statusCode == 403) {
      throw Exception('Akses ditolak');
    }
    if (response.statusCode >= 400) {
      try {
        // ✅ Perbaiki _handleResponse untuk mengembalikan pesan error yang lebih baik
        final jsonBody = json.decode(response.body);
        final message = jsonBody['meta']?['message'] ?? 'Terjadi kesalahan';
        throw Exception(message);
      } catch (e) {
        // Jika gagal mem-parsing JSON, lempar pesan generik
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    }
    return response;
  }
}
