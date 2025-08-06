import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ricky_ui_jc/model/submit_draft_order_model.dart';

class SubmitDraftOrderService {
  Future<SubmitDraftOrderResponseModel> submitDraftOrder(
      int idSalesOrder) async {
    final url = Uri.parse('$baseUrlHp/sales-orders/$idSalesOrder/submit');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return SubmitDraftOrderResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to submit draft sales order');
      }
    } catch (e) {
      throw Exception('Error submitting draft sales order: $e');
    }
  }
}
