import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  DetailDraftOrderResponseModel? _draft;
  bool _isLoading = true;
  bool _isSaving = false;
  final EditDraftOrderService _editService = EditDraftOrderService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _priceControllers = [];
  final List<FocusNode> _quantityFocusNodes = [];
  final List<FocusNode> _priceFocusNodes = [];

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
        _initializeControllers();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail Sales Order: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    // Dispose existing controllers
    _disposeControllers();

    if (_draft != null && _draft!.data.details.isNotEmpty) {
      for (var item in _draft!.data.details) {
        _quantityControllers
            .add(TextEditingController(text: item.quantity.toString()));
        _priceControllers.add(
            TextEditingController(text: item.hargaJual.toStringAsFixed(0)));
        _quantityFocusNodes.add(FocusNode());
        _priceFocusNodes.add(FocusNode());
      }
    }
  }

  void _disposeControllers() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    for (var node in _quantityFocusNodes) {
      node.dispose();
    }
    for (var node in _priceFocusNodes) {
      node.dispose();
    }
    _quantityControllers.clear();
    _priceControllers.clear();
    _quantityFocusNodes.clear();
    _priceFocusNodes.clear();
  }

  Future<void> _saveChanges() async {
    if (_draft == null || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

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

        if (quantity <= 0) {
          throw Exception(
              'Quantity untuk ${item.namaBarang} harus lebih dari 0.');
        }
        if (hargaJual <= 0) {
          throw Exception(
              'Harga Jual untuk ${item.namaBarang} harus lebih dari 0.');
        }

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
          const SnackBar(
            content: Text("Perubahan berhasil disimpan"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  double _calculateNewSubtotal(int index) {
    if (index >= _quantityControllers.length ||
        index >= _priceControllers.length) {
      return 0.0;
    }

    final quantity = int.tryParse(_quantityControllers[index].text) ?? 0;
    final price = double.tryParse(_priceControllers[index].text) ?? 0.0;
    return quantity * price;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Draft Sales Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.orange[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isLoading && _draft != null)
            TextButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _draft == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Data tidak tersedia',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _fetchDraftDetails,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderHeader(_draft!.data),
                              const SizedBox(height: 16),
                              _buildEditableItemsList(_draft!.data),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      _buildBottomActions(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderHeader(DetailDraftOrderData data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_document,
                  color: Colors.orange[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informasi Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('No Faktur', data.noFaktur, Icons.numbers),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Tanggal Order',
              data.tanggalOrder.toLocal().toString().split(' ').first,
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Jenis Transaksi', data.transactionType, Icons.swap_horiz),
            const SizedBox(height: 12),
            _buildInfoRow('Customer', data.namaCustomer, Icons.person),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Total Saat Ini',
              'Rp ${_formatCurrency(data.totalHarga)}',
              Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableItemsList(DetailDraftOrderData data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Edit Barang (${data.details.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.details.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = data.details[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaBarang,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kode: ${item.kodeBarang}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Alamat: ${item.address}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data Saat Ini:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} ${item.satuan} | Harga: Rp ${_formatCurrency(item.hargaJual)} | Subtotal: Rp ${_formatCurrency(item.subtotal)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityControllers[index],
                              focusNode: _quantityFocusNodes[index],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Quantity Baru',
                                hintText: 'Masukkan quantity',
                                prefixIcon: Icon(Icons.numbers,
                                    color: Colors.grey[600]),
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.orange[600]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Quantity tidak boleh kosong';
                                }
                                final quantity = int.tryParse(value);
                                if (quantity == null || quantity <= 0) {
                                  return 'Quantity harus berupa angka positif';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(
                                    () {}); // Trigger rebuild for subtotal calculation
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _priceControllers[index],
                              focusNode: _priceFocusNodes[index],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Harga Satuan Baru',
                                hintText: 'Masukkan harga',
                                prefixIcon: Icon(Icons.attach_money,
                                    color: Colors.grey[600]),
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.orange[600]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Harga tidak boleh kosong';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Harga harus berupa angka positif';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(
                                    () {}); // Trigger rebuild for subtotal calculation
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal Baru:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(_calculateNewSubtotal(index))}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Menyimpan...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
