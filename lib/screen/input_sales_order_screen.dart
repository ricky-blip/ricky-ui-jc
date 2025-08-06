import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/model/save_as_draft_model.dart';
import 'package:ricky_ui_jc/screen/main_screen.dart';
import 'package:ricky_ui_jc/service/save_as_draft_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/service/customer_service.dart';
import 'package:ricky_ui_jc/model/barang_model.dart';
import 'package:ricky_ui_jc/service/barang_service.dart';

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
  // Change listBarang type to store dynamic data including idBarang and hargaJual
  List<Map<String, dynamic>> listBarang = [];
  // Change dropdown selected value types to String? and initialize to null
  String? _selectedJenisTransaksi;
  String? _selectedLokasiTujuan;
  String? _selectedSatuan;
  int? _selectedIdCustomer;
  int? _selectedIdBarang;
  double? _selectedDataHrgJual;
  bool _lokasiDropdownEnabled =
      false; // Start disabled, enabled only when set by customer
  bool _satuanDropdownEnabled =
      false; // Start disabled, enabled only when set by barang

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? '';
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> _refreshData() async {
    await _loadUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> showCariBarangDialog() async {
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: barangs.isEmpty
                        ? const Center(
                            child: Text("Tidak ada barang ditemukan"),
                          )
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
                                trailing: Text(barang.satuan),
                                onTap: () {
                                  setState(() {
                                    _barangController.text = barang.namaBarang;
                                    // Set Satuan dan disable dropdown
                                    _selectedSatuan = barang.satuan;
                                    _satuanDropdownEnabled = false; // Disable
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
    // Validasi sebelum menambahkan ke listBarang
    // 1. Barang harus dipilih (cek _selectedIdBarang dan _barangController tidak kosong)
    // 2. Qty harus diisi
    // 3. Lokasi Tujuan harus dipilih (cek _selectedLokasiTujuan - tidak null karena auto-set)
    // 4. Satuan harus dipilih (cek _selectedSatuan - tidak null karena auto-set)
    // 5. Jenis Transaksi harus dipilih (cek _selectedJenisTransaksi)
    // 6. Customer harus dipilih (cek _selectedIdCustomer)
    if (_barangController.text.isEmpty ||
        _qtyController.text.isEmpty ||
        _selectedIdBarang == null ||
        _selectedDataHrgJual == null ||
        _selectedLokasiTujuan == null || // Cek null (auto-set, jadi harus ada)
        // _selectedLokasiTujuan!.isEmpty || // Tidak perlu cek string kosong karena auto-set
        _selectedSatuan == null || // Cek null (auto-set, jadi harus ada)
        // _selectedSatuan!.isEmpty || // Tidak perlu cek string kosong karena auto-set
        _selectedJenisTransaksi == null ||
        _selectedJenisTransaksi!.isEmpty || // Cek string kosong juga
        _selectedIdCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Mohon lengkapi Customer, Jenis Transaksi, Barang, Lokasi, Qty, dan Satuan")),
      );
      return;
    }
    // Jika semua validasi lolos, tambahkan ke list
    setState(() {
      listBarang.add({
        'idBarang': _selectedIdBarang!,
        'barang': _barangController.text,
        'qty': _qtyController.text,
        'address': _selectedLokasiTujuan!, // Tidak null karena divalidasi
        'harga': _selectedDataHrgJual.toString(),
        'hargaJual': _selectedDataHrgJual!, // Store as double
      });
    });
    _barangController.clear();
    _qtyController.clear();
    // Reset pilihan barang setelah ditambahkan karena satuan sudah auto-set
    _selectedIdBarang = null;
    _selectedDataHrgJual = null;
    _selectedSatuan = null; // Reset satuan
    _satuanDropdownEnabled = false; // Disable dropdown satuan kembali
    // _selectedLokasiTujuan dan _lokasiDropdownEnabled tetap karena berasal dari customer
  }

  Future<void> _handleSimpan() async {
    // Validasi sebelum menyimpan
    // 1. Customer harus dipilih
    // 2. Jenis Transaksi harus dipilih
    // 3. List Barang tidak boleh kosong
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
    // Validasi tambahan untuk setiap item dalam listBarang (jika diperlukan)
    // Misalnya, pastikan setiap item memiliki data yang valid
    // Untuk saat ini, asumsikan data dalam listBarang sudah divalidasi saat ditambahkan
    // di _handleTambah.
    // Buat list detail
    List<SaveAsDraftDetail> details = [];
    try {
      details = listBarang.map((item) {
        // Asumsikan data sudah divalidasi di _handleTambah
        return SaveAsDraftDetail(
          idBarang: item['idBarang'] as int,
          address:
              item['address'] as String, // Pasti String karena sudah divalidasi
          quantity: int.parse(item['qty'] as String),
          hargaJual: item['hargaJual'] as double,
        );
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error memproses data barang: $e")),
      );
      return; // Hentikan proses simpan jika ada error dalam membuat detail
    }
    // Buat model untuk disimpan
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
      // Reset form setelah berhasil
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
        _lokasiDropdownEnabled = false; // Reset dan disable
        _satuanDropdownEnabled = false; // Reset dan disable
      });
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print("Gagal menyimpan sales order (Full Error): $e");
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                              // Set Lokasi Tujuan dan disable dropdown
                              _selectedLokasiTujuan = customer.address;
                              _lokasiDropdownEnabled = false; // Disable
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Remove automaticallyImplyLeading if you want full control, but it's fine to keep
        // automaticallyImplyLeading: false,
        leading: PopupMenuButton<String>(
          icon: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          onSelected: (String value) {
            if (value == 'logout') {
              _logout();
            } else if (value == 'ubah_password') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fitur ubah password belum tersedia')),
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'ubah_password',
              child: Text('Ubah Password'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $_fullName',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _role,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
        // Add the refresh button to the AppBar actions
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData, // Call the refresh function
            tooltip: 'Refresh', // Optional tooltip
          ),
        ],
      ),
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
                  // SingleChildScrollView is now a child of RefreshIndicator
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
                        // Jenis Transaksi Dropdown
                        _buildDropdown(
                          value:
                              _selectedJenisTransaksi, // Pass the nullable value
                          hint: 'Pilih Jenis Transaksi', // Add hint
                          items: const ['Tunai', 'Kredit'],
                          onChanged: (val) {
                            setState(() {
                              _selectedJenisTransaksi = val; // val can be null
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFieldWithButton(
                          controller: _barangController,
                          hint: 'Barang',
                          buttonText: 'Cari Barang',
                          onPressed: () {
                            showCariBarangDialog();
                          },
                        ),
                        const SizedBox(height: 12),
                        // Lokasi Tujuan Dropdown - Items based on selected value
                        _buildDropdown(
                          value:
                              _selectedLokasiTujuan, // Pass the nullable value
                          hint: 'Pilih Lokasi Tujuan', // Add hint
                          // Items list hanya berisi nilai yang dipilih (jika ada)
                          items: _selectedLokasiTujuan != null
                              ? [_selectedLokasiTujuan!]
                              : [],
                          onChanged: _lokasiDropdownEnabled
                              ? (val) {
                                  setState(() {
                                    _selectedLokasiTujuan =
                                        val; // val can be null
                                  });
                                }
                              : null, // Disable jika _lokasiDropdownEnabled false
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
                            // Satuan Dropdown - Items based on selected value
                            Expanded(
                              child: _buildDropdown(
                                value:
                                    _selectedSatuan, // Pass the nullable value
                                hint: 'Pilih Satuan', // Add hint
                                // Items list hanya berisi nilai yang dipilih (jika ada)
                                items: _selectedSatuan != null
                                    ? [_selectedSatuan!]
                                    : [],
                                onChanged: _satuanDropdownEnabled
                                    ? (val) {
                                        setState(() {
                                          _selectedSatuan =
                                              val; // val can be null
                                        });
                                      }
                                    : null, // Disable jika _satuanDropdownEnabled false
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        //NOTE - Button Tambah
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
                        //NOTE - List Barang hasil Inputan
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "List Barang",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...listBarang.map((item) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.red.shade100,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['barang']}  (${item['qty']})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(item['address'] as String? ?? ''),
                                  Text(item['harga'] as String? ?? ''),
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
                      )),
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

  // Updated _buildDropdown to handle nullable values and hints
  Widget _buildDropdown({
    required String? value, // Accept nullable String
    required String hint, // Add hint parameter
    required List<String> items,
    required ValueChanged<String?>?
        onChanged, // Accept nullable String for onChanged
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value, // Pass the nullable value
          hint: Text(hint), // Set the hint text
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem<String?>(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          // Disable dropdown jika onChanged null
          // Note: DropdownButton tetap bisa di-tap meski onChanged null,
          // tapi tidak akan memicu apa-apa. Untuk UX lebih baik,
          // pertimbangkan menggunakan widget lain atau styling khusus.
          // Untuk saat ini, logika disable ada di onChanged null.
        ),
      ),
    );
  }
}
