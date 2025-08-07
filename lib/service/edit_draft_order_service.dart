import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/edit_draft_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class EditDraftOrderService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<void> edit(int idSalesOrder, EditDraftOrderModel draft) async {
    final response = await _client.put(
      '/sales-orders/$idSalesOrder/edit',
      draft.toJson(),
    );

    print(" EditDraftOrderService $response");
    print(" EditDraftOrderService ${response.body}");

    if (response.statusCode == 200) {
      print('Sales Order berhasil diperbarui');
    } else {
      throw Exception('Gagal memperbarui Sales Order');
    }
  }
}
