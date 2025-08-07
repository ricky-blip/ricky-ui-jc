class EditDraftOrderModel {
  final List<EditDraftOrderDetail> details;

  EditDraftOrderModel({required this.details});

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

class EditDraftOrderDetail {
  final int idBarang; // Ubah dari String menjadi int
  final String address;
  final int quantity;
  final double hargaJual;

  EditDraftOrderDetail({
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
