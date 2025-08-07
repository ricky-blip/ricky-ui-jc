// service/barang_service.dart
import 'dart:convert';
import 'package:ricky_ui_jc/model/barang_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class BarangService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<List<BarangModel>> getAllBarangs() async {
    final response = await _client.get('/barang/getAllBarang');
    final jsonResult = jsonDecode(response.body) as Map<String, dynamic>;

    if (jsonResult.containsKey('data') && jsonResult['data'] is List) {
      return (jsonResult['data'] as List)
          .map((json) => BarangModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Struktur data tidak valid dari API');
    }
  }
}
