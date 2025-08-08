import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/draft/submit/submit_draft_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class SubmitDraftOrderService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<void> submit(int idSalesOrder) async {
    final response =
        await _client.put('/sales-orders/$idSalesOrder/submit', null);

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);
        final submitResponse =
            SubmitDraftOrderResponseModel.fromJson(jsonResponse);
        print(
            'Sukses: ${submitResponse.meta.message}'); // Gunakan pesan dari API
        // Atau tampilkan pesan sukses ke pengguna
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(submitResponse.meta.message)));
      } catch (e) {
        // Jika parsing gagal, tetap tampilkan pesan sukses umum
        print(
            'Sales Order berhasil dikirim ke approval (respons tidak dapat diparsing)');
      }
      // Jangan throw exception untuk status 200
      return; // Keluar dari fungsi jika sukses
    } else {
      // Tangani error berdasarkan respons API
      String errorMessage = 'Gagal mengirim Sales Order ke approval';
      try {
        final jsonResponse = json.decode(response.body);
        final submitResponse =
            SubmitDraftOrderResponseModel.fromJson(jsonResponse);
        errorMessage =
            submitResponse.meta.message; // Gunakan pesan error dari API
      } catch (e) {
        // Jika parsing gagal, gunakan pesan error umum
        errorMessage =
            'Gagal mengirim Sales Order ke approval (respons tidak dapat diparsing)';
      }
      throw Exception(errorMessage);
    }
  }
}
