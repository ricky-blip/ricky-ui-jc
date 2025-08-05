import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ricky_ui_jc/screen/auth/login_screen.dart';
import 'package:ricky_ui_jc/service/customer_service.dart';
import 'package:ricky_ui_jc/model/customer_model.dart';

class InputSalesOrderScreen extends StatefulWidget {
  const InputSalesOrderScreen({super.key});

  @override
  State<InputSalesOrderScreen> createState() => _InputSalesOrderScreenState();
}

class _InputSalesOrderScreenState extends State<InputSalesOrderScreen> {
  String _fullName = '';
  String _role = '';

  final CustomerService _customerService = CustomerService();

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _barangController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  String _selectedJenisTransaksi = 'Tunai';
  String _selectedLokasiTujuan = 'Pilih Lokasi';
  String _selectedSatuan = 'Pcs';

  bool _lokasiDropdownEnabled = true;

  List<Map<String, String>> listBarang = [];

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

  void _handleTambah() {
    if (_barangController.text.isNotEmpty && _qtyController.text.isNotEmpty) {
      setState(() {
        listBarang.add({
          'barang': _barangController.text,
          'qty': _qtyController.text,
          'address': _selectedLokasiTujuan,
          'harga': 'Rp 100.000',
        });
      });

      _barangController.clear();
      _qtyController.clear();
    }
  }

  void _handleSimpan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sales order disimpan")),
    );
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
                              _selectedLokasiTujuan = customer.address;
                              _lokasiDropdownEnabled = false;
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
      ),
      body: SafeArea(
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
                        items: const ['Tunai', 'Kredit'],
                        onChanged: (val) {
                          setState(() {
                            _selectedJenisTransaksi = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildFieldWithButton(
                        controller: _barangController,
                        hint: 'Barang',
                        buttonText: 'Cari Barang',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        value: _selectedLokasiTujuan,
                        items: [_selectedLokasiTujuan],
                        onChanged: _lokasiDropdownEnabled
                            ? (val) {
                                setState(() {
                                  _selectedLokasiTujuan = val!;
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
                              items: const ['Pcs'],
                              onChanged: (val) {
                                setState(() {
                                  _selectedSatuan = val!;
                                });
                              },
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "List Barang",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
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
                                Text(item['address'] ?? ''),
                                Text(item['harga'] ?? ''),
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSimpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
    required String value,
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
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
