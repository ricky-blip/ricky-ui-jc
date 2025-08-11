import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/model/draft/get/draft_so_model.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/screen/detail_draft_sales_order_screen.dart';
import 'package:ricky_ui_jc/screen/edit_draft_sales_order_screen.dart';
import 'package:ricky_ui_jc/service/draft_so_service.dart';
import 'package:ricky_ui_jc/service/delete_draft_order_service.dart';
import 'package:ricky_ui_jc/service/submit_draft_order_service.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';

class DraftSalesOrderScreen extends StatefulWidget {
  const DraftSalesOrderScreen({super.key});

  @override
  State<DraftSalesOrderScreen> createState() => _DraftSalesOrderScreenState();
}

class _DraftSalesOrderScreenState extends State<DraftSalesOrderScreen> {
  String _fullName = '';
  String _role = '';
  List<DraftSalesOrderModel> _draftSalesOrders = [];
  bool _isLoading = false;

  final DraftSalesOrderService _draftService = DraftSalesOrderService();
  final DeleteDraftOrderService _deleteService = DeleteDraftOrderService();
  final SubmitDraftOrderService _submitService = SubmitDraftOrderService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDraftSalesOrders();
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

  Future<void> _fetchDraftSalesOrders() async {
    try {
      final isValid = await SecureStorage.isTokenValid();
      if (!isValid) {
        await _forceLogout('Sesi telah berakhir. Silakan login ulang.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final response = await _draftService.getDraftSalesOrders();

      if (response.meta.code == 200 && response.data != null) {
        setState(() {
          _draftSalesOrders = response.data!;
        });
      } else {
        setState(() {
          _draftSalesOrders = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.meta.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat draft sales order: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forceLogout(String message) async {
    await SecureStorage.deleteAll();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteDraft(int idSalesOrder) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text('Apakah Anda yakin ingin menghapus draft ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _deleteService.deleteDraft(idSalesOrder);
        if (response.meta.status == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.meta.message)),
          );
          // Refresh list setelah penghapusan berhasil
          await _fetchDraftSalesOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus draft')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus draft: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _submitDraftOrder(int idSalesOrder) async {
    try {
      await _submitService.submit(idSalesOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Sales Order berhasil dikirim ke approval")),
      );
      setState(() {
        _draftSalesOrders
            .removeWhere((draft) => draft.idSalesOrder == idSalesOrder);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim Sales Order ke approval: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
    await _fetchDraftSalesOrders();
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
                    'Draft Sales Order',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading && _draftSalesOrders.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _draftSalesOrders.length,
                          itemBuilder: (context, index) {
                            final draft = _draftSalesOrders[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.red.shade100),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'ID: ${draft.idSalesOrder}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteDraft(draft.idSalesOrder),
                                          tooltip: 'Hapus',
                                        ),
                                      ],
                                    ),
                                    Text('No Faktur: ${draft.noFaktur}'),
                                    Text('Customer: ${draft.namaCustomer}'),
                                    Text('Transaksi: ${draft.transactionType}'),
                                    // Text(
                                    //   'Total: Rp ${draft.totalHarga.toStringAsFixed(2)}',
                                    // ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (_role != 'SALES_MANAGER')
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditDraftSalesOrderScreen(
                                                          idSalesOrder: draft
                                                              .idSalesOrder),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text("Edit"),
                                          ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailDraftSalesOrderScreen(
                                                  idSalesOrder:
                                                      draft.idSalesOrder,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Detail"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (_role != 'SALES_MANAGER')
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => _submitDraftOrder(
                                            draft.idSalesOrder,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Submit"),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
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
