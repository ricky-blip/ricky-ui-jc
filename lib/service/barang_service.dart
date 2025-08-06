import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/barang_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarangService {
  Future<List<BarangModel>> getAllBarangs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak tersedia. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrlHp/barang/getAllBarang'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResult = jsonDecode(response.body);

      // Periksa apakah ada key 'data' dan itu adalah List
      if (jsonResult.containsKey('data') && jsonResult['data'] is List) {
        final List<dynamic> data = jsonResult['data'];

        // Map setiap item JSON ke BarangModel
        return data.map((json) => BarangModel.fromJson(json)).toList();
      } else {
        // Tangani kasus jika struktur JSON tidak sesuai harapan
        throw Exception('Struktur data tidak valid dari API');
      }
    } else {
      // Tangani error HTTP
      throw Exception(
          'Gagal memuat barang. Status code: ${response.statusCode}, Message: ${response.body}');
    }
  }
}
