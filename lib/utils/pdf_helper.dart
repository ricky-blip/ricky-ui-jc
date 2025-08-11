// utils/pdf_helper.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/utils/jwt_decoder.dart'; // Pastikan Anda punya ini

class PdfHelper {
  static Future<void> downloadAndOpenPdf(
      String baseUrl, int salesOrderId) async {
    try {
      // ✅ 1. Ambil token dari SecureStorage
      final token = await SecureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // ✅ 2. Cek apakah token expired
      if (JwtDecoder.isTokenExpired(token)) {
        throw Exception('Token sudah expired');
      }

      // ✅ 3. Buat URL
      final url = '$baseUrl/sales-orders/$salesOrderId/pdf';
      print('📥 URL PDF: $url');

      // ✅ 4. Kirim request
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📦 Status Code: ${response.statusCode}'); // 🔍 Debug
      if (response.statusCode != 200) {
        print('❌ Body Error: ${response.body}'); // 🔍 Lihat error dari backend
        throw Exception('Gagal download PDF: ${response.statusCode}');
      }

      // ✅ 5. Simpan & buka file
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sales_order_$salesOrderId.pdf');
      await file.writeAsBytes(response.bodyBytes);
      print('💾 PDF disimpan di: ${file.path}');

      // ✅ 6. Buka file
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception('Gagal buka PDF: ${result.message}');
      }
    } catch (e) {
      print('🚨 Error di PdfHelper: $e'); // 🔥 Ini yang akan bantu kita debug
      rethrow;
    }
  }
}
