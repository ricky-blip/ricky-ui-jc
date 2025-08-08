class ApprovalOrderResponseModel {
  final Meta meta;
  final List<ApprovalOrderData> data;

  ApprovalOrderResponseModel({
    required this.meta,
    required this.data,
  });

  factory ApprovalOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return ApprovalOrderResponseModel(
      meta: Meta.fromJson(json['meta']),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => ApprovalOrderData.fromJson(item))
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
      code: json['code'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ApprovalOrderData {
  final int idSalesOrder;
  final String noFaktur;
  final String namaCustomer;
  final String transactionType;
  final double totalHarga;

  ApprovalOrderData({
    required this.idSalesOrder,
    required this.noFaktur,
    required this.namaCustomer,
    required this.transactionType,
    required this.totalHarga,
  });

  factory ApprovalOrderData.fromJson(Map<String, dynamic> json) {
    return ApprovalOrderData(
      idSalesOrder: json['idSalesOrder'] ?? 0,
      noFaktur: json['noFaktur'] ?? '',
      namaCustomer: json['namaCustomer'] ?? '',
      transactionType: json['transactionType'] ?? '',
      totalHarga: (json['totalHarga'] ?? 0).toDouble(),
    );
  }
}
