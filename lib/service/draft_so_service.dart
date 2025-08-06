import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/draft_so_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftSalesOrderService {
  Future<DraftSalesOrderResponseModel> getDraftSalesOrders() async {
    final url = Uri.parse('$baseUrlHp/sales-orders/drafts');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return DraftSalesOrderResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load draft sales orders');
      }
    } catch (e) {
      throw Exception('Error fetching draft sales orders: $e');
    }
  }
}
