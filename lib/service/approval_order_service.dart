import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/approval_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class ApprovalOrderService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<ApprovalOrderResponseModel> getUnvalidatedOrders() async {
    final response = await _client.get('/sales-orders/unvalidated');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return ApprovalOrderResponseModel.fromJson(jsonResponse);
    } else {
      throw Exception('Gagal memuat data Sales Order');
    }
  }

  // --- Tambahkan metode berikut ---
  Future<ApprovalOrderResponseModel> getRejectedOrders() async {
    final response = await _client.get('/sales-orders/rejected');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return ApprovalOrderResponseModel.fromJson(jsonResponse);
    } else {
      // Anda mungkin ingin menangani error dengan lebih baik
      // Misalnya, parsing pesan error dari API jika ada
      throw Exception('Gagal memuat data Sales Order Rejected');
    }
  }

  Future<ApprovalOrderResponseModel> getValidatedOrders() async {
    final response = await _client.get('/sales-orders/validated');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return ApprovalOrderResponseModel.fromJson(jsonResponse);
    } else {
      // Anda mungkin ingin menangani error dengan lebih baik
      throw Exception('Gagal memuat data Sales Order Validated');
    }
  }
  // --- Akhir tambahan metode ---
}
