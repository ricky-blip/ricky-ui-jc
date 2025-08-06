class BarangModel {
  final int idBarang;
  final String kodeBarang;
  final String namaBarang;
  final String satuan;
  final double harga;
  final int stokQty;
  final int reservedQty;
  final int availableQty;
  final bool isActive;

  BarangModel({
    required this.idBarang,
    required this.kodeBarang,
    required this.namaBarang,
    required this.satuan,
    required this.harga,
    required this.stokQty,
    required this.reservedQty,
    required this.availableQty,
    required this.isActive,
  });

  /// Membuat instance BarangModel dari JSON Map
  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      idBarang: json['idBarang'] ?? 0,
      kodeBarang: json['kodeBarang'] ?? '',
      namaBarang: json['namaBarang'] ?? '',
      satuan: json['satuan'] ?? '',
      harga: (json['harga'] is num) ? json['harga'].toDouble() : 0.0,
      stokQty: json['stokQty'] ?? 0,
      reservedQty: json['reservedQty'] ?? 0,
      availableQty: json['availableQty'] ?? 0,
      isActive: json['isactive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBarang': idBarang,
      'kodeBarang': kodeBarang,
      'namaBarang': namaBarang,
      'satuan': satuan,
      'harga': harga,
      'stokQty': stokQty,
      'reservedQty': reservedQty,
      'availableQty': availableQty,
      'isactive': isActive,
    };
  }

  @override
  String toString() {
    return '$namaBarang - $kodeBarang (Rp $harga)';
  }
}
