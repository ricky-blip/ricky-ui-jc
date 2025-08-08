// screen/edit_draft_sales_order_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/model/draft/get/detail_draft_order_model.dart';
import 'package:ricky_ui_jc/model/draft/edit/edit_draft_order_model.dart';
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
  DetailDraftOrderResponseModel? _draft; // Tidak perlu 'late' jika bisa null
  bool _isLoading = true;
  final EditDraftOrderService _editService = EditDraftOrderService();

  // Kontroler untuk input quantity dan harga jual
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _priceControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchDraftDetails();
  }

  Future<void> _fetchDraftDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final details =
          await DetailDraftOrderService().getDetail(widget.idSalesOrder);
      setState(() {
        _draft = details;
        _isLoading = false;

        // Reset kontroler sebelum membuat yang baru
        for (var controller in _quantityControllers) {
          controller.dispose();
        }
        for (var controller in _priceControllers) {
          controller.dispose();
        }
        _quantityControllers.clear();
        _priceControllers.clear();

        // Buat TextEditingController untuk setiap detail barang dan inisialisasi dengan nilai saat ini
        if (_draft != null && _draft!.data.details.isNotEmpty) {
          for (var item in _draft!.data.details) {
            _quantityControllers
                .add(TextEditingController(text: item.quantity.toString()));
            _priceControllers.add(
                TextEditingController(text: item.hargaJual.toStringAsFixed(2)));
            // Gunakan toStringAsFixed(2) untuk memastikan format desimal konsisten
          }
        }
      });
    } catch (e) {
      if (mounted) {
        // Tambahkan mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail Sales Order: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_draft == null) return;

    try {
      final List<EditDraftOrderDetail> details = [];

      for (var i = 0; i < _draft!.data.details.length; i++) {
        final item = _draft!.data.details[i];
        final quantityText = _quantityControllers[i].text.trim();
        final priceText = _priceControllers[i].text.trim();

        if (quantityText.isEmpty) {
          throw Exception(
              'Quantity untuk ${item.namaBarang} tidak boleh kosong.');
        }
        if (priceText.isEmpty) {
          throw Exception(
              'Harga Jual untuk ${item.namaBarang} tidak boleh kosong.');
        }
        if (item.idBarang == null) {
          throw Exception(
              'Data barang tidak lengkap: ID Barang untuk "${item.namaBarang}" tidak ditemukan.');
        }
        if (item.address == null || item.address!.trim().isEmpty) {
          throw Exception(
              'Data barang tidak lengkap: Alamat untuk "${item.namaBarang}" tidak ditemukan.');
        }

        final int quantity = int.tryParse(quantityText) ??
            (throw Exception(
                'Quantity untuk ${item.namaBarang} harus berupa angka bulat.'));
        final double hargaJual = double.tryParse(priceText) ??
            (throw Exception(
                'Harga Jual untuk ${item.namaBarang} harus berupa angka.'));

        details.add(EditDraftOrderDetail(
          idBarang: item.idBarang!,
          address: item.address!.trim(),
          quantity: quantity,
          hargaJual: hargaJual,
        ));
      }

      final editedDraft = EditDraftOrderModel(details: details);
      await _editService.edit(widget.idSalesOrder, editedDraft);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perubahan berhasil disimpan")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanMessage)),
        );
      }
    }
  }

  @override
  void dispose() {
    // Bersihkan controller saat widget dihapus
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
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
            'Tanggal Order: ${data.tanggalOrder.toLocal().toString().split(' ').first}'), // Format tanggal
        const SizedBox(height: 8),
        Text('Jenis Transaksi: ${data.transactionType}'),
        const SizedBox(height: 8),
        Text('Nama Customer: ${data.namaCustomer}'),
        const SizedBox(height: 8),
        Text('Total Harga: Rp ${data.totalHarga.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        // Opsional: Hapus tombol Edit/Detail jika tidak diperlukan di halaman ini
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     ElevatedButton(
        //       onPressed: () {
        //         // Navigasi ke halaman edit
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.blue,
        //         foregroundColor: Colors.white,
        //       ),
        //       child: const Text("Edit"),
        //     ),
        //     ElevatedButton(
        //       onPressed: () {
        //         // Navigasi ke halaman detail
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.green,
        //         foregroundColor: Colors.white,
        //       ),
        //       child: const Text("Detail"),
        //     ),
        //   ],
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
                Text('Qty sekarang: ${item.quantity}'),
                Text(
                    'Harga Jual sekarang: Rp ${item.hargaJual.toStringAsFixed(2)}'),
                Text('Alamat: ${item.address}'),
                const SizedBox(height: 4),
                Text(
                    'Subtotal: Rp ${(item.quantity * item.hargaJual).toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityControllers[index],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false), // Hanya integer
                        decoration: const InputDecoration(
                          labelText: 'Quantity Baru',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _priceControllers[index],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true), // Bisa desimal
                        decoration: const InputDecoration(
                          labelText: 'Harga Jual Baru',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
