import 'dart:convert';

class DraftSalesOrderResponseModel {
  final Meta meta;
  final List<DraftSalesOrderModel> data;

  DraftSalesOrderResponseModel({
    required this.meta,
    required this.data,
  });

  factory DraftSalesOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return DraftSalesOrderResponseModel(
      meta: Meta.fromJson(json['meta']),
      data: (json['data'] as List<dynamic>)
          .map((item) => DraftSalesOrderModel.fromJson(item))
          .toList(),
    );
  }
}

class Meta {
  final int code;
  final String status;
  final String message;
  final String timestamp;

  Meta({
    required this.code,
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      code: json['code'],
      status: json['status'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}

class DraftSalesOrderModel {
  final int idSalesOrder;
  final String noFaktur;
  final String namaCustomer;
  final String transactionType;
  final double totalHarga;

  DraftSalesOrderModel({
    required this.idSalesOrder,
    required this.noFaktur,
    required this.namaCustomer,
    required this.transactionType,
    required this.totalHarga,
  });

  factory DraftSalesOrderModel.fromJson(Map<String, dynamic> json) {
    return DraftSalesOrderModel(
      idSalesOrder: json['idSalesOrder'],
      noFaktur: json['noFaktur'],
      namaCustomer: json['namaCustomer'],
      transactionType: json['transactionType'],
      totalHarga: json['totalHarga'].toDouble(),
    );
  }
}
