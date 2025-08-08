import 'dart:convert';
import 'package:ricky_ui_jc/model/approval_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class ApprovalOrderService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<ApprovalOrderResponseModel> getUnvalidatedOrders() async {
    final response = await _client.get('/sales-orders/unvalidated');
    final jsonResponse = json.decode(response.body);
    return ApprovalOrderResponseModel.fromJson(jsonResponse);
  }

  Future<ApprovalOrderResponseModel> getRejectedOrders() async {
    final response = await _client.get('/sales-orders/rejected');
    final jsonResponse = json.decode(response.body);
    return ApprovalOrderResponseModel.fromJson(jsonResponse);
  }

  Future<ApprovalOrderResponseModel> getValidatedOrders() async {
    final response = await _client.get('/sales-orders/validated');
    final jsonResponse = json.decode(response.body);
    return ApprovalOrderResponseModel.fromJson(jsonResponse);
  }
}
