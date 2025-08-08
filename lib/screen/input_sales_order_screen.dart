import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/model/input%20so/save_as_draft_model.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/service/save_as_draft_service.dart';
import 'package:ricky_ui_jc/service/customer_service.dart';
import 'package:ricky_ui_jc/model/barang/barang_model.dart';
import 'package:ricky_ui_jc/service/barang_service.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';

class InputSalesOrderScreen extends StatefulWidget {
  const InputSalesOrderScreen({super.key});

  @override
  State<InputSalesOrderScreen> createState() => _InputSalesOrderScreenState();
}

class _InputSalesOrderScreenState extends State<InputSalesOrderScreen> {
  String _fullName = '';
  String _role = '';

  final CustomerService _customerService = CustomerService();
  final BarangService _barangService = BarangService();

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _barangController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  List<Map<String, dynamic>> listBarang = [];

  String? _selectedJenisTransaksi;
  String? _selectedLokasiTujuan;
  String? _selectedSatuan;
  int? _selectedIdCustomer;
  int? _selectedIdBarang;
  double? _selectedDataHrgJual;

  bool _lokasiDropdownEnabled = false;
  bool _satuanDropdownEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final fullName = await SecureStorage.read(key: 'fullName');
      final role = await SecureStorage.read(key: 'role');
      if (mounted) {
        setState(() {
          _fullName = fullName ?? '';
          _role = role ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal muat data user: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  Future<void> showCariBarangDialog() async {
    final isValid = await SecureStorage.isTokenValid();
    if (!isValid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sesi telah berakhir. Silakan login ulang.')),
      );
      await SecureStorage.deleteAll();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
      return;
    }

    try {
      final barangs = await _barangService.getAllBarangs();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Colors.blue.shade100,
                    child: const Text(
                      "Pilih Barang",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: barangs.isEmpty
                        ? const Center(
                            child: Text("Tidak ada barang ditemukan"))
                        : ListView.separated(
                            itemCount: barangs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final barang = barangs[index];
                              return ListTile(
                                title: Text(barang.namaBarang),
                                subtitle: Text(
                                    "${barang.kodeBarang} - Rp ${barang.harga.toStringAsFixed(2)}"),
                                trailing: Text(
                                    "${barang.satuan} (${barang.availableQty})"),
                                onTap: () {
                                  setState(() {
                                    _barangController.text = barang.namaBarang;
                                    _selectedSatuan = barang.satuan;
                                    _satuanDropdownEnabled = false;
                                    _selectedIdBarang = barang.idBarang;
                                    _selectedDataHrgJual = barang.harga;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat barang: $e')),
        );
      }
    }
  }

  void _handleTambah() {
    if (_barangController.text.isEmpty ||
        _qtyController.text.isEmpty ||
        _selectedIdBarang == null ||
        _selectedDataHrgJual == null ||
        _selectedLokasiTujuan == null ||
        _selectedSatuan == null ||
        _selectedJenisTransaksi == null ||
        _selectedJenisTransaksi!.isEmpty ||
        _selectedIdCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Mohon lengkapi Customer, Jenis Transaksi, Barang, Lokasi, Qty, dan Satuan"),
        ),
      );
      return;
    }

    setState(() {
      listBarang.add({
        'idBarang': _selectedIdBarang!,
        'barang': _barangController.text,
        'qty': _qtyController.text,
        'address': _selectedLokasiTujuan!,
        'harga': _selectedDataHrgJual.toString(),
        'hargaJual': _selectedDataHrgJual!,
        'satuan': _selectedSatuan ?? '-',
      });
    });

    _barangController.clear();
    _qtyController.clear();
    _selectedIdBarang = null;
    _selectedDataHrgJual = null;
    _selectedSatuan = null;
    _satuanDropdownEnabled = false;
  }

  Future<void> _handleSimpan() async {
    if (_selectedIdCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon pilih Customer")),
      );
      return;
    }

    if (_selectedJenisTransaksi == null || _selectedJenisTransaksi!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon pilih Jenis Transaksi")),
      );
      return;
    }

    if (listBarang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon tambahkan minimal satu barang")),
      );
      return;
    }

    List<SaveAsDraftDetail> details = [];
    try {
      details = listBarang.map((item) {
        return SaveAsDraftDetail(
          idBarang: item['idBarang'] as int,
          address: item['address'] as String,
          quantity: int.parse(item['qty'] as String),
          hargaJual: item['hargaJual'] as double,
        );
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error memproses data barang: $e")),
      );
      return;
    }

    final save = SaveAsDraftModel(
      idCustomer: _selectedIdCustomer!,
      transactionType: _selectedJenisTransaksi!.toUpperCase(),
      details: details,
    );

    try {
      await SaveAsDraftService().save(save);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sales order berhasil disimpan")),
      );
      setState(() {
        _customerController.clear();
        _barangController.clear();
        _qtyController.clear();
        listBarang.clear();
        _selectedIdCustomer = null;
        _selectedIdBarang = null;
        _selectedDataHrgJual = null;
        _selectedJenisTransaksi = null;
        _selectedLokasiTujuan = null;
        _selectedSatuan = null;
        _lokasiDropdownEnabled = false;
        _satuanDropdownEnabled = false;
      });
    } catch (e) {
      // Coba ekstrak pesan kesalahan dari respons JSON
      String errorMessage = e.toString();

      try {
        // Ambil bagian JSON dari Exception
        final startIndex = errorMessage.indexOf('{');
        if (startIndex != -1) {
          final jsonResponse = json.decode(errorMessage.substring(startIndex));
          if (jsonResponse is Map<String, dynamic> &&
              jsonResponse.containsKey('meta') &&
              jsonResponse['meta'] is Map<String, dynamic> &&
              jsonResponse['meta'].containsKey('message')) {
            errorMessage = jsonResponse['meta']['message'];
          }
        }
      } catch (_) {
        // Jika gagal parse, gunakan pesan default
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> showCariCustomerDialog() async {
    try {
      final customers = await _customerService.getAllCustomers();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Colors.red.shade100,
                    child: const Text(
                      "Pilih Customer",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: customers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return ListTile(
                          title: Text(customer.namaCustomer),
                          subtitle: Text(customer.address),
                          trailing: Text(customer.kodeCustomer),
                          onTap: () {
                            setState(() {
                              _customerController.text = customer.namaCustomer;
                              _selectedLokasiTujuan = customer.address;
                              _lokasiDropdownEnabled = false;
                              _selectedIdCustomer = customer.idCustomer;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat customer: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8C4C4),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8D6D6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'Input Sales Order',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildFieldWithButton(
                          controller: _customerController,
                          hint: 'Customer',
                          buttonText: 'Cari Customer',
                          onPressed: showCariCustomerDialog,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown(
                          value: _selectedJenisTransaksi,
                          hint: 'Pilih Jenis Transaksi',
                          items: const ['Tunai', 'Kredit'],
                          onChanged: (val) {
                            setState(() {
                              _selectedJenisTransaksi = val;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFieldWithButton(
                          controller: _barangController,
                          hint: 'Barang',
                          buttonText: 'Cari Barang',
                          onPressed: showCariBarangDialog,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown(
                          value: _selectedLokasiTujuan,
                          hint: 'Pilih Lokasi Tujuan',
                          items: _selectedLokasiTujuan != null
                              ? [_selectedLokasiTujuan!]
                              : [],
                          onChanged: _lokasiDropdownEnabled
                              ? (val) {
                                  setState(() {
                                    _selectedLokasiTujuan = val;
                                  });
                                }
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _qtyController,
                                hint: 'Qty',
                                keyboard: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedSatuan,
                                hint: 'Pilih Satuan',
                                items: _selectedSatuan != null
                                    ? [_selectedSatuan!]
                                    : [],
                                onChanged: _satuanDropdownEnabled
                                    ? (val) {
                                        setState(() {
                                          _selectedSatuan = val;
                                        });
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _handleTambah,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size.fromHeight(45),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah"),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "List Barang",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: listBarang.isEmpty
                                  ? null
                                  : () {
                                      setState(() {
                                        listBarang.clear();
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              icon: const Icon(Icons.delete_forever, size: 16),
                              label: const Text("Hapus Semua",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...listBarang.map((item) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.red.shade100),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item['barang']} (${item['qty']} ${item['satuan'] ?? '-'})',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            listBarang.remove(item);
                                          });
                                        },
                                        tooltip: 'Hapus',
                                      ),
                                    ],
                                  ),
                                  Text(item['address'] as String? ?? ''),
                                  Text('Rp ${item['harga'] as String? ?? '0'}'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _handleSimpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWithButton({
    required TextEditingController controller,
    required String hint,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTextField(controller: controller, hint: hint),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem<String?>(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
