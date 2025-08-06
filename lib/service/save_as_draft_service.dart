import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/model/save_as_draft_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveAsDraftService {
  Future<void> save(SaveAsDraftModel salesOrder) async {
    final url = Uri.parse('$baseUrlHp/sales-orders/draft');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final payload = json.encode(salesOrder.toJson());

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: payload,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        print('Sales Order saved successfully');
      } else {
        String errorMessage = 'Failed to save sales order';
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse is Map<String, dynamic> &&
              errorResponse.containsKey('meta')) {
            final meta = errorResponse['meta'];
            if (meta is Map<String, dynamic> && meta.containsKey('message')) {
              errorMessage = meta['message'] as String? ?? errorMessage;
            }
          }
        } catch (parseError) {
          print('Error parsing error response: $parseError');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error occurred while saving sales order: $e');
      throw e;
    }
  }
}
