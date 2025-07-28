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

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      idCustomer: json['idCustomer'],
      kodeCustomer: json['kodeCustomer'],
      namaCustomer: json['namaCustomer'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      isActive: json['isactive'],
    );
  }
}
