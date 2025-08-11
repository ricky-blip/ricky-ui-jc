import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/model/draft/get/draft_so_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';

class SearchDraftService {
  Future<List<DraftSalesOrderModel>> searchDrafts(String query) async {
    final token = await SecureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrlHp/sales-orders/drafts/search?q=$query'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['data'];
      return list.map((e) => DraftSalesOrderModel.fromJson(e)).toList();
    }
    throw Exception('Gagal mencari draft: ${response.statusCode}');
  }
}
