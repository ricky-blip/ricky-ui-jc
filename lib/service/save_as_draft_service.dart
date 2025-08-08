// service/save_as_draft_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/input%20so/save_as_draft_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class SaveAsDraftService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<SaveAsDraftResponseModel> save(SaveAsDraftModel salesOrder) async {
    try {
      // 1. Kirim request dan dapatkan response
      final response =
          await _client.post('/sales-orders/draft', salesOrder.toJson());

      // 2. Periksa status code
      if (response.statusCode == 201) {
        // Atau 200, tergantung API kamu
        // 3a. Jika sukses, parsing dan kembalikan model
        final jsonResponse = json.decode(response.body);
        return SaveAsDraftResponseModel.fromJson(jsonResponse);
      } else {
        // 3b. Jika error dari server, coba dapatkan pesan error
        try {
          final jsonResponse = json.decode(response.body);
          // Pastikan struktur JSON sesuai
          if (jsonResponse is Map<String, dynamic> &&
              jsonResponse.containsKey('meta') &&
              jsonResponse['meta'] is Map<String, dynamic> &&
              jsonResponse['meta'].containsKey('message')) {
            final errorMessage = jsonResponse['meta']['message'];
            throw Exception(errorMessage); // Lempar pesan error spesifik
          } else {
            // Jika struktur tidak dikenali
            throw Exception(
                'Gagal menyimpan sales order: ${response.statusCode} ${response.reasonPhrase}');
          }
        } catch (parseError) {
          // Jika gagal parsing JSON error, lempar error umum
          throw Exception(
              'Gagal menyimpan sales order: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      // Tangkap error jaringan atau error lainnya dari ApiClient (jika masih dilempar)
      // dan lempar ulang agar bisa ditangani oleh pemanggil (InputSalesOrderScreen)
      rethrow;
    }
  }
}
