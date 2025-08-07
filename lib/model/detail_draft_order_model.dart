class DetailDraftOrderResponseModel {
  final Meta meta;
  final DetailDraftOrderData data;

  DetailDraftOrderResponseModel({
    required this.meta,
    required this.data,
  });

  factory DetailDraftOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return DetailDraftOrderResponseModel(
      meta: Meta.fromJson(json['meta']),
      data: DetailDraftOrderData.fromJson(json['data']),
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

class DetailDraftOrderData {
  final String noFaktur;
  final DateTime tanggalOrder;
  final String transactionType;
  final String namaCustomer;
  final String alamatCustomer;
  final String phoneCustomer;
  final String emailCustomer;
  final double subtotal;
  final double ppn;
  final double jumlahPpn;
  final double totalHarga;
  final String status;
  final SalesPerson salesPerson;
  final dynamic salesManager; // Bisa null
  final List<DetailItem> details;

  DetailDraftOrderData({
    required this.noFaktur,
    required this.tanggalOrder,
    required this.transactionType,
    required this.namaCustomer,
    required this.alamatCustomer,
    required this.phoneCustomer,
    required this.emailCustomer,
    required this.subtotal,
    required this.ppn,
    required this.jumlahPpn,
    required this.totalHarga,
    required this.status,
    required this.salesPerson,
    required this.salesManager,
    required this.details,
  });

  factory DetailDraftOrderData.fromJson(Map<String, dynamic> json) {
    return DetailDraftOrderData(
      noFaktur: json['noFaktur'],
      tanggalOrder: DateTime.parse(json['tanggalOrder']),
      transactionType: json['transactionType'],
      namaCustomer: json['namaCustomer'],
      alamatCustomer: json['alamatCustomer'],
      phoneCustomer: json['phoneCustomer'],
      emailCustomer: json['emailCustomer'],
      subtotal: json['subtotal'].toDouble(),
      ppn: json['ppn'].toDouble(),
      jumlahPpn: json['jumlahPpn'].toDouble(),
      totalHarga: json['totalHarga'].toDouble(),
      status: json['status'],
      salesPerson: SalesPerson.fromJson(json['salesPerson']),
      salesManager: json['salesManager'] != null
          ? SalesPerson.fromJson(json['salesManager'])
          : null,
      details: (json['details'] as List<dynamic>)
          .map((item) => DetailItem.fromJson(item))
          .toList(),
    );
  }
}

class SalesPerson {
  final String fullName;
  final String username;
  final String role;

  SalesPerson({
    required this.fullName,
    required this.username,
    required this.role,
  });

  factory SalesPerson.fromJson(Map<String, dynamic> json) {
    return SalesPerson(
      fullName: json['fullName'],
      username: json['username'],
      role: json['role'],
    );
  }
}

class DetailItem {
  final int? idBarang;
  final String kodeBarang;
  final String namaBarang;
  final String satuan;
  final int quantity;
  final double hargaJual;
  final String? address;
  final double subtotal;

  DetailItem({
    required this.idBarang,
    required this.kodeBarang,
    required this.namaBarang,
    required this.satuan,
    required this.quantity,
    required this.hargaJual,
    required this.address,
    required this.subtotal,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      idBarang: json['idBarang'] is int ? json['idBarang'] : null,
      kodeBarang: json['kodeBarang'],
      namaBarang: json['namaBarang'],
      satuan: json['satuan'],
      quantity: json['quantity'],
      hargaJual: json['hargaJual'].toDouble(),
      address: json['address'] ?? "",
      subtotal: json['subtotal'].toDouble(),
    );
  }
}
