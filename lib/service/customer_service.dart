import 'dart:convert';
import 'package:ricky_ui_jc/model/customer/customer_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class CustomerService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<List<CustomerModel>> getAllCustomers() async {
    final response = await _client.get('/customers/getAllCustomer');
    final jsonResult = jsonDecode(response.body) as Map<String, dynamic>;

    if (jsonResult.containsKey('data') && jsonResult['data'] is List) {
      return (jsonResult['data'] as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Struktur data customer tidak valid');
    }
  }
}
