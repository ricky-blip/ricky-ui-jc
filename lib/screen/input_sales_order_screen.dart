import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/screen/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/customer_model.dart';
import '../service/customer_service.dart';

class InputSalesOrderScreen extends StatefulWidget {
  const InputSalesOrderScreen({super.key});

  @override
  State<InputSalesOrderScreen> createState() => _InputSalesOrderScreenState();
}

class _InputSalesOrderScreenState extends State<InputSalesOrderScreen> {
  String _fullName = '';
  String _role = '';

  List<CustomerModel> _customerList = [];
  CustomerModel? _selectedCustomer;

  void _showCustomerDialog() async {
    try {
      final customers = await CustomerService().getAllCustomers();
      setState(() {
        _customerList = customers;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pilih Customer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _customerList.length,
              itemBuilder: (context, index) {
                final customer = _customerList[index];
                return ListTile(
                  title: Text(customer.namaCustomer),
                  subtitle: Text(customer.address),
                  onTap: () {
                    setState(() {
                      _selectedCustomer = customer;
                      _customerController.text = customer.namaCustomer;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat customer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? 'User';
      _role = prefs.getString('role') ?? '';
    });
  }

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _barangController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  String _selectedJenisTransaksi = 'Tunai';
  String _selectedLokasiTujuan = 'Pilih Lokasi';
  String _selectedSatuan = 'Pcs';

  void _handleTambah() {
    if (_customerController.text.isEmpty ||
        _barangController.text.isEmpty ||
        _qtyController.text.isEmpty ||
        _selectedJenisTransaksi == 'Tunai' ||
        _selectedLokasiTujuan == 'Pilih Lokasi' ||
        _selectedSatuan == 'Pcs') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sales order berhasil ditambahkan'),
        backgroundColor: Colors.green,
      ),
    );

    _clearForm();
  }

  void _clearForm() {
    _customerController.clear();
    _barangController.clear();
    _qtyController.clear();
    setState(() {
      _selectedJenisTransaksi = 'Tunai';
      _selectedLokasiTujuan = 'Pilih Lokasi';
      _selectedSatuan = 'Pcs';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _customerController.dispose();
    _barangController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8C4C4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'Ubah Password',
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
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _role,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.refresh,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8C4C4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent),
              ),
              child: const Text(
                'Input Sales Order',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _customerController,
                    decoration: InputDecoration(
                      hintText: 'Customer',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _showCustomerDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cari Customer',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Jenis Transaksi Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedJenisTransaksi,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.black87),
                  items: [
                    'Tunai',
                    'Kredit',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJenisTransaksi = newValue!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Barang Section
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _barangController,
                    decoration: InputDecoration(
                      hintText: 'Barang',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cari Barang',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Pilih Lokasi Dropdown
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: DropdownButtonHideUnderline(
            //     child: DropdownButton<String>(
            //       value: _selectedLokasiTujuan,
            //       isExpanded: true,
            //       style: const TextStyle(color: Colors.black87),
            //       // items: [
            //       //   'Pilih Lokasi',
            //       // ].map((String value) {
            //       //   return DropdownMenuItem<String>(
            //       //     value: value,
            //       //     child: Text(value),
            //       //   );
            //       // }).toList(),
            //       items: _selectedCustomer != null
            //           ? [_selectedCustomer!.address]
            //               .map((value) => DropdownMenuItem<String>(
            //                     value: value,
            //                     child: Text(value),
            //                   ))
            //               .toList()
            //           : [
            //               const DropdownMenuItem(
            //                 value: 'Pilih Lokasi',
            //                 child: Text('Pilih Lokasi'),
            //               ),
            //             ],
            //       onChanged: (String? newValue) {
            //         setState(() {
            //           _selectedLokasiTujuan = newValue!;
            //         });
            //       },
            //     ),
            //   ),
            // ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCustomer != null
                      ? _selectedCustomer!.address
                      : _selectedLokasiTujuan,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.black87),
                  items: _selectedCustomer != null
                      ? [_selectedCustomer!.address]
                          .map((value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList()
                      : [
                          const DropdownMenuItem(
                            value: 'Pilih Lokasi',
                            child: Text('Pilih Lokasi'),
                          ),
                        ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLokasiTujuan = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Qty',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSatuan,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black87),
                        items: [
                          'Pcs',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSatuan = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _handleTambah,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline),
                SizedBox(width: 8),
                Text(
                  'Tambah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
