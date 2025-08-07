import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ricky_ui_jc/model/save_as_draft_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/service/api_client.dart';

class SaveAsDraftService {
  final ApiClient _client = ApiClient(baseUrl: baseUrlHp);

  Future<SaveAsDraftResponseModel> save(SaveAsDraftModel salesOrder) async {
    final response =
        await _client.post('/sales-orders/draft', salesOrder.toJson());

    final jsonResponse = json.decode(response.body);
    return SaveAsDraftResponseModel.fromJson(jsonResponse);
  }
}
