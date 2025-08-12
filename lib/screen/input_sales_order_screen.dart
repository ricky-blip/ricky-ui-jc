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

class _InputSalesOrderScreenState extends State<InputSalesOrderScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customerController.dispose();
    _barangController.dispose();
    _qtyController.dispose();
    super.dispose();
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
        _showErrorSnackBar('Gagal muat data user: $e');
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> showCariBarangDialog() async {
    final isValid = await SecureStorage.isTokenValid();
    if (!isValid) {
      if (!mounted) return;
      _showErrorSnackBar('Sesi telah berakhir. Silakan login ulang.');
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Pilih Barang",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: barangs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Tidak ada barang ditemukan",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: barangs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final barang = barangs[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.inventory_2,
                                      color: Colors.blue.shade600, size: 20),
                                ),
                                title: Text(barang.namaBarang,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  "${barang.kodeBarang} - Rp ${barang.harga.toStringAsFixed(0)}",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${barang.satuan} (${barang.availableQty})",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
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
        _showErrorSnackBar('Gagal memuat barang: $e');
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
      _showErrorSnackBar(
          "Mohon lengkapi Customer, Jenis Transaksi, Barang, Lokasi, Qty, dan Satuan");
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
      _showErrorSnackBar("Mohon pilih Customer");
      return;
    }

    if (_selectedJenisTransaksi == null || _selectedJenisTransaksi!.isEmpty) {
      _showErrorSnackBar("Mohon pilih Jenis Transaksi");
      return;
    }

    if (listBarang.isEmpty) {
      _showErrorSnackBar("Mohon tambahkan minimal satu barang");
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menyimpan sales order...'),
              ],
            ),
          ),
        ),
      ),
    );

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
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar("Error memproses data barang: $e");
      return;
    }

    final save = SaveAsDraftModel(
      idCustomer: _selectedIdCustomer!,
      transactionType: _selectedJenisTransaksi!.toUpperCase(),
      details: details,
    );

    try {
      await SaveAsDraftService().save(save);
      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar("Sales order berhasil disimpan");
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
      Navigator.pop(context); // Close loading dialog

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

      _showErrorSnackBar(errorMessage);
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Pilih Customer",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: customers.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Tidak ada customer ditemukan",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: customers.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.person,
                                      color: Colors.green.shade600, size: 20),
                                ),
                                title: Text(customer.namaCustomer,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  customer.address,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    customer.kodeCustomer,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _customerController.text =
                                        customer.namaCustomer;
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
      _showErrorSnackBar('Gagal memuat customer: $e');
    }
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${index + 1}',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade600,
                                size: 16,
                              ),
                              onPressed: () {
                                setState(() {
                                  listBarang.remove(item);
                                });
                              },
                              tooltip: 'Hapus Item',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${item['barang']} (${item['qty']} ${item['satuan'] ?? '-'})',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16, color: Colors.grey),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['address'] as String? ?? '',
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16, color: Colors.grey),
                            Row(
                              children: [
                                Icon(Icons.payments_outlined,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Rp ${item['harga'] as String? ?? '0'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Colors.redAccent,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldWithButton(
                                controller: _customerController,
                                hint: 'Customer',
                                buttonText: 'Cari Customer',
                                onPressed: showCariCustomerDialog,
                                icon: Icons.person_search,
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
                                icon: Icons.payment,
                              ),
                              const SizedBox(height: 12),
                              _buildFieldWithButton(
                                controller: _barangController,
                                hint: 'Barang',
                                buttonText: 'Cari Barang',
                                onPressed: showCariBarangDialog,
                                icon: Icons.inventory,
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
                                icon: Icons.location_on,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _qtyController,
                                      hint: 'Qty',
                                      keyboard: TextInputType.number,
                                      icon: Icons.numbers,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                      icon: Icons.straighten,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _handleTambah,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    elevation: 2,
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text("Tambah Item"),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // List Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Daftar Barang (${listBarang.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (listBarang.isNotEmpty)
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      title: const Text('Konfirmasi'),
                                      content: const Text(
                                          'Hapus semua item dalam daftar?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              listBarang.clear();
                                            });
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                                icon: const Icon(Icons.delete_sweep, size: 16),
                                label: const Text("Hapus Semua",
                                    style: TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        if (listBarang.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.shopping_cart_outlined,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tambahkan barang untuk melanjutkan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...listBarang.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return _buildItemCard(item, index);
                          }).toList(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Save Button
              if (_role != 'SALES_MANAGER')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: listBarang.isEmpty ? null : _handleSimpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text(
                        'Simpan ke Draft',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
    required IconData icon,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child:
              _buildTextField(controller: controller, hint: hint, icon: icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 1,
            ),
            icon: const Icon(Icons.search, size: 14),
            label: Text(
              buttonText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
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
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.grey[600], size: 16)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey[600], size: 16),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                isExpanded: true,
                onChanged: onChanged,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                items: items
                    .map((e) => DropdownMenuItem<String?>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
