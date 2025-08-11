import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/model/draft/get/detail_draft_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/service/Get All Detail/detail_all_data_service.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/utils/pdf_helper.dart';

class DetailAllDataSOScreen extends StatefulWidget {
  final int idSalesOrder;

  const DetailAllDataSOScreen({required this.idSalesOrder, super.key});

  @override
  State<DetailAllDataSOScreen> createState() => _DetailAllDataSOScreenState();
}

class _DetailAllDataSOScreenState extends State<DetailAllDataSOScreen> {
  late DetailDraftOrderResponseModel _detail;
  bool _isLoading = true;

  final DetailAllDataSOService _detailService = DetailAllDataSOService();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final isValid = await SecureStorage.isTokenValid();
      if (!isValid) {
        await _forceLogout('Sesi telah berakhir. Silakan login ulang.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final detail = await _detailService.getDetail(widget.idSalesOrder);
      setState(() {
        _detail = detail;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Sales Order'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? const Center(child: Text('Data tidak tersedia'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                          _detail.data), // ✅ Sudah benar, tidak perlu !
                      const SizedBox(height: 24),
                      _buildDetails(_detail.data),
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
          'Tanggal Order: ${data.tanggalOrder.toLocal().toString().split(' ').first}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Jenis Transaksi: ${data.transactionType}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Customer: ${data.namaCustomer}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Alamat: ${data.alamatCustomer}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'Telepon: ${data.phoneCustomer}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'Email: ${data.emailCustomer}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal:', style: TextStyle(fontSize: 14)),
            Text('Rp ${data.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PPN (${data.ppn.toStringAsFixed(1)}%):',
                style: const TextStyle(fontSize: 14)),
            Text('Rp ${data.jumlahPpn.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1.5),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Rp ${data.totalHarga.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Status: ${data.status}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Text(
          'Dibuat oleh:',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '${data.salesPerson.fullName} (${data.salesPerson.username})',
          style: const TextStyle(fontSize: 14),
        ),
        if (data.salesManager != null) ...[
          const SizedBox(height: 4),
          Text(
            'Manager: ${data.salesManager!.fullName} (${data.salesManager!.username})',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildDetails(DetailDraftOrderData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Barang:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
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
                      'Kode Barang: ${item.kodeBarang}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Nama Barang: ${item.namaBarang}'),
                    const SizedBox(height: 4),
                    Text('Satuan: ${item.satuan}'),
                    const SizedBox(height: 4),
                    Text('Quantity: ${item.quantity}'),
                    const SizedBox(height: 4),
                    Text('Harga Jual: Rp ${item.hargaJual.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Text('Alamat: ${item.address}'),
                    const SizedBox(height: 4),
                    Text('Subtotal: Rp ${item.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            try {
              await PdfHelper.downloadAndOpenPdf(
                baseUrlHp,
                widget.idSalesOrder,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal download PDF: $e')),
              );
            }
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Download PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
