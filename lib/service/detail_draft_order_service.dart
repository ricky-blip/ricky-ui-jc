import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/draft/get/detail_draft_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class DetailDraftOrderService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<DetailDraftOrderResponseModel> getDetail(int idSalesOrder) async {
    final response = await _client.get('/sales-orders/drafts/$idSalesOrder');

    if (response.statusCode == 200) {
      // --- Tambahkan logging di sini ---
      print('--- DEBUG: Raw Response Body for Draft ID $idSalesOrder ---');
      print(response.body);
      print('--------------------------------------------------------');
      // --- Akhir logging ---

      final jsonResponse = json.decode(response.body);

      // --- (Opsional) Logging JSON Map ---
      // print('--- DEBUG: Decoded JSON Response ---');
      // print(jsonResponse);
      // print('------------------------------------');

      return DetailDraftOrderResponseModel.fromJson(jsonResponse);
    } else {
      throw Exception(
          'Gagal memuat detail Sales Order: ${response.statusCode}');
    }
  }
}
