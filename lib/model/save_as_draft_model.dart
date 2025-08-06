class SaveAsDraftModel {
  final int idCustomer;
  final String transactionType;
  final List<SaveAsDraftDetail> details;

  SaveAsDraftModel({
    required this.idCustomer,
    required this.transactionType,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'idCustomer': idCustomer,
      'transactionType': transactionType,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

class SaveAsDraftDetail {
  final int idBarang;
  final String address;
  final int quantity;
  final double hargaJual;

  SaveAsDraftDetail({
    required this.idBarang,
    required this.address,
    required this.quantity,
    required this.hargaJual,
  });

  Map<String, dynamic> toJson() {
    return {
      'idBarang': idBarang,
      'address': address,
      'quantity': quantity,
      'hargaJual': hargaJual,
    };
  }
}
