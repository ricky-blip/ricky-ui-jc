class CustomerModel {
  final int idCustomer;
  final String kodeCustomer;
  final String namaCustomer;
  final String address;
  final String phone;
  final String email;
  final bool isActive;

  CustomerModel({
    required this.idCustomer,
    required this.kodeCustomer,
    required this.namaCustomer,
    required this.address,
    required this.phone,
    required this.email,
    required this.isActive,
  });

  /// Factory dari JSON ke objek CustomerModel
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      idCustomer: json['idCustomer'] ?? 0,
      kodeCustomer: json['kodeCustomer'] ?? '',
      namaCustomer: json['namaCustomer'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      isActive: json['isactive'] ?? false,
    );
  }

  /// Optional: dari objek ke JSON (berguna jika mau kirim balik ke API)
  Map<String, dynamic> toJson() {
    return {
      'idCustomer': idCustomer,
      'kodeCustomer': kodeCustomer,
      'namaCustomer': namaCustomer,
      'address': address,
      'phone': phone,
      'email': email,
      'isactive': isActive,
    };
  }

  @override
  String toString() {
    return '$namaCustomer - $kodeCustomer';
  }
}
