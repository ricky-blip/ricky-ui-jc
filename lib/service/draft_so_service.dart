import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/draft/get/draft_so_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';

class DraftSalesOrderService {
  Future<DraftSalesOrderResponseModel> getDraftSalesOrders() async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrlHp/sales-orders/drafts');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    final jsonResponse = json.decode(response.body);

    // Kembalikan model apapun status code-nya
    return DraftSalesOrderResponseModel.fromJson(jsonResponse);
  }
}
