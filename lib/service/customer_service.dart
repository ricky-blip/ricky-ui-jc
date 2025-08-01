import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/customer_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  Future<List<CustomerModel>> getAllCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak tersedia. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrlHp/customers/getAllCustomer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => CustomerModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Gagal memuat customer. Status code: ${response.statusCode}');
    }
  }
}
