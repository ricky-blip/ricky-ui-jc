// screen/edit_draft_sales_order_screen.dart
import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/model/detail_draft_order_model.dart';
import 'package:ricky_ui_jc/model/edit_draft_order_model.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/service/detail_draft_order_service.dart';
import 'package:ricky_ui_jc/service/edit_draft_order_service.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';

class EditDraftSalesOrderScreen extends StatefulWidget {
  final int idSalesOrder;

  const EditDraftSalesOrderScreen({required this.idSalesOrder, super.key});

  @override
  State<EditDraftSalesOrderScreen> createState() =>
      _EditDraftSalesOrderScreenState();
}

class _EditDraftSalesOrderScreenState extends State<EditDraftSalesOrderScreen> {
  late DetailDraftOrderResponseModel? _draft; // Ubah menjadi nullable
  bool _isLoading = true;

  final EditDraftOrderService _editService = EditDraftOrderService();

  // Kontroler untuk input quantity dan harga jual
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _priceControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchDraft();
  }

  Future<void> _fetchDraft() async {
    try {
      final isValid = await SecureStorage.isTokenValid();
      if (!isValid) {
        await _forceLogout('Sesi telah berakhir. Silakan login ulang.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final draft =
          await DetailDraftOrderService().getDetail(widget.idSalesOrder);
      setState(() {
        _draft = draft; // Inisialisasi _draft
        _isLoading = false;

        // Inisialisasi kontroler untuk setiap barang
        for (var item in _draft?.data.details ?? []) {
          _quantityControllers
              .add(TextEditingController(text: item.quantity.toString()));
          _priceControllers.add(
              TextEditingController(text: item.hargaJual.toStringAsFixed(2)));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail Sales Order: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forceLogout(String message) async {
    await SecureStorage.deleteAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // screen/edit_draft_sales_order_screen.dart
// Di dalam _saveChanges()
  Future<void> _saveChanges() async {
    try {
      // Validasi setiap item sebelum parsing
      final rawDetails = _draft?.data.details ?? [];
      final List<EditDraftOrderDetail> details = [];

      for (var i = 0; i < rawDetails.length; i++) {
        final item = rawDetails[i];
        final index = i; // Gunakan index dari loop untuk kontroler

        // Validasi idBarang ada dan tidak null
        if (item.idBarang == null) {
          throw Exception(
              'Data barang tidak lengkap: idBarang untuk ${item.namaBarang} tidak ditemukan.');
        }

        // Pastikan input dari TextField valid sebelum parsing
        final quantityText = _quantityControllers[index].text.trim();
        final priceText = _priceControllers[index].text.trim();

        if (quantityText.isEmpty) {
          throw Exception('Mohon isi quantity untuk barang ${item.namaBarang}');
        }
        if (priceText.isEmpty) {
          throw Exception(
              'Mohon isi harga jual untuk barang ${item.namaBarang}');
        }

        // Parsing input user
        int quantity;
        double hargaJual;
        try {
          quantity = int.parse(quantityText);
        } catch (e) {
          throw Exception(
              'Quantity untuk ${item.namaBarang} harus berupa angka bulat.');
        }
        try {
          hargaJual = double.parse(priceText);
        } catch (e) {
          throw Exception(
              'Harga Jual untuk ${item.namaBarang} harus berupa angka.');
        }

        details.add(EditDraftOrderDetail(
          idBarang: item.idBarang!,
          address: item.address.toString(),
          quantity: quantity,
          hargaJual: hargaJual,
        ));
      }

      final editedDraft = EditDraftOrderModel(details: details);

      await _editService.edit(widget.idSalesOrder, editedDraft);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perubahan berhasil disimpan")),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Logging untuk debugging
      print("Error saat menyimpan perubahan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Draft Sales Order'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_draft != null) _buildHeader(_draft!.data),
                  const SizedBox(height: 24),
                  if (_draft != null) _buildDetails(_draft!.data),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Simpan Perubahan"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(DetailDraftOrderData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No Faktur: ${data.noFaktur}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Tanggal Order: ${data.tanggalOrder.toLocal().toString()}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Jenis Transaksi: ${data.transactionType}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Nama Customer: ${data.namaCustomer}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Alamat Customer: ${data.alamatCustomer}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Nomor Telepon: ${data.phoneCustomer}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        // Text(
        //   'Email: ${data.emailCustomer}',
        //   style: const TextStyle(fontSize: 14),
        // ),
        // const SizedBox(height: 16),
        // Text(
        //   'Subtotal: Rp ${data.subtotal.toStringAsFixed(2)}',
        //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   'PPN: ${data.ppn}%',
        //   style: const TextStyle(fontSize: 14),
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   'Jumlah PPN: Rp ${data.jumlahPpn.toStringAsFixed(2)}',
        //   style: const TextStyle(fontSize: 14),
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   'Total Harga: Rp ${data.totalHarga.toStringAsFixed(2)}',
        //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   'Status: ${data.status}',
        //   style: const TextStyle(fontSize: 14),
        // ),
        // const SizedBox(height: 16),
        // Text(
        //   'Penjualan oleh:',
        //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   'Nama: ${data.salesPerson.fullName}',
        //   style: const TextStyle(fontSize: 14),
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   'Username: ${data.salesPerson.username}',
        //   style: const TextStyle(fontSize: 14),
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   'Role: ${data.salesPerson.role}',
        //   style: const TextStyle(fontSize: 14),
        // ),
      ],
    );
  }

  Widget _buildDetails(DetailDraftOrderData data) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.details.length,
      itemBuilder: (context, index) {
        final item = data.details[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Barang: ${item.namaBarang}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity:'),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _quantityControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Harga Jual:'),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _priceControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Alamat: ${item.address}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Subtotal: Rp ${(item.quantity * item.hargaJual).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
