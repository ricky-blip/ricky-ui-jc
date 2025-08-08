// service/edit_draft_order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/model/draft/edit/edit_draft_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';

class EditDraftOrderService {
  Future<void> edit(int idSalesOrder, EditDraftOrderModel draft) async {
    final token = await SecureStorage.read(key: 'token');
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan login kembali.');
    }

    final url = Uri.parse('$baseUrlHp/sales-orders/$idSalesOrder/edit');

    print("EditDraftOrderService: PUT $url");
    print("EditDraftOrderService: Request Body: ${jsonEncode(draft.toJson())}");

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(draft.toJson()),
      );

      print("EditDraftOrderService: Status Code: ${response.statusCode}");
      print("EditDraftOrderService: Response Body: ${response.body}");

      final bodyString = response.body.isNotEmpty ? response.body : '{}';
      Map<String, dynamic> jsonResponse = {};

      try {
        jsonResponse = json.decode(bodyString);
      } catch (_) {
        // kalau bukan JSON valid, jsonResponse tetap kosong
      }

      if (response.statusCode == 200) {
        final successMessage = jsonResponse['meta']?['message'] ??
            jsonResponse['message'] ??
            'Sales Order berhasil diperbarui';
        print("EditDraftOrderService: Success - $successMessage");
        return;
      } else {
        final errorMessage = jsonResponse['meta']?['message'] ??
            jsonResponse['message'] ??
            jsonResponse['error'] ??
            'Gagal memperbarui Sales Order';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("EditDraftOrderService: Error - $e");
      rethrow;
    }
  }
}
