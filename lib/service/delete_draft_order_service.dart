// service/delete_draft_order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/delete_draft_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';

class DeleteDraftOrderService {
  Future<DeleteDraftOrderResponseModel> deleteDraft(int idSalesOrder) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrlHp/sales-orders/drafts/$idSalesOrder');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return DeleteDraftOrderResponseModel.fromJson(jsonResponse);
    } else {
      throw Exception('Gagal menghapus draft sales order');
    }
  }
}
