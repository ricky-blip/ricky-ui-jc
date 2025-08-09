// screen/order_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/screen/detail_all_data_screen.dart';
import 'package:ricky_ui_jc/screen/detail_draft_sales_order_screen.dart';
import 'package:ricky_ui_jc/service/approval/rejected_so_service.dart';
import 'package:ricky_ui_jc/service/approval/validated_so_service.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/service/approval_order_service.dart';
import 'package:ricky_ui_jc/model/approval_order_model.dart';

// Enum untuk merepresentasikan status filter
enum OrderStatus { unvalidated, rejected, validated }

class OrderApprovalScreen extends StatefulWidget {
  const OrderApprovalScreen({super.key});

  @override
  State<OrderApprovalScreen> createState() => _OrderApprovalScreenState();
}

class _OrderApprovalScreenState extends State<OrderApprovalScreen> {
  String _fullName = '';
  String _role = ''; // Simpan role pengguna
  ApprovalOrderResponseModel? _orders;
  bool _isLoading = true;
  OrderStatus _selectedFilter = OrderStatus.unvalidated; // Default filter

  final ApprovalOrderService _approvalService = ApprovalOrderService();
  final RejectedSoService _rejectService = RejectedSoService();
  final ValidatedSoService _validatedService = ValidatedSoService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchOrders(_selectedFilter);
  }

  Future<void> _loadUserData() async {
    try {
      final fullName = await SecureStorage.read(key: 'fullName');
      final role = await SecureStorage.read(key: 'role'); // Baca role
      if (mounted) {
        setState(() {
          _fullName = fullName ?? '';
          _role = role ?? ''; // Simpan role
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

  Future<void> _fetchOrders(OrderStatus status) async {
    try {
      final isValid = await SecureStorage.isTokenValid();
      if (!isValid) {
        await _forceLogout('Sesi telah berakhir. Silakan login ulang.');
        return;
      }

      setState(() {
        _isLoading = true;
        _orders = null; // Reset data sebelumnya
      });

      ApprovalOrderResponseModel orders;

      switch (status) {
        case OrderStatus.unvalidated:
          orders = await _approvalService.getUnvalidatedOrders();
        case OrderStatus.rejected:
          orders = await _approvalService.getRejectedOrders();
        case OrderStatus.validated:
          orders = await _approvalService.getValidatedOrders();
        default:
          throw Exception('Status tidak dikenali');
      }

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data Sales Order: $e')),
        );
        setState(() {
          _isLoading = false;
          _orders = null; // Reset data jika error
        });
      }
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

  Future<void> _rejectOrder(int idSalesOrder) async {
    try {
      await _rejectService.rejected(idSalesOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $idSalesOrder ditolak')),
      );
      _fetchOrders(_selectedFilter);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak order: $e')),
      );
    }
  }

  Future<void> _validateOrder(int idSalesOrder) async {
    try {
      await _validatedService.validated(idSalesOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $idSalesOrder disetujui')),
      );
      _fetchOrders(_selectedFilter);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyetujui order: $e')),
      );
    }
  }

  Widget _buildFilterChip(OrderStatus status, String label, Color color) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == status,
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.3),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = status;
          });
          _fetchOrders(status);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showActionButtons =
        _selectedFilter == OrderStatus.unvalidated && _role == 'SALES_MANAGER';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul dan filter chips
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Approval Sales Order',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterChip(
                        OrderStatus.unvalidated,
                        'Unvalidated',
                        Colors.redAccent,
                      ),
                      _buildFilterChip(
                        OrderStatus.rejected,
                        'Rejected',
                        Colors.grey,
                      ),
                      _buildFilterChip(
                        OrderStatus.validated,
                        'Validated',
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // Konten utama
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _fetchOrders(_selectedFilter),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_orders == null || _orders!.data.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'Tidak ada data Sales Order untuk filter ini.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _orders!.data.length,
                                itemBuilder: (context, index) {
                                  final order = _orders!.data[index];
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'No Faktur: ${order.noFaktur}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Nama Customer: ${order.namaCustomer}'),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Transaksi: ${order.transactionType}'),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Total Harga: Rp ${order.totalHarga.toStringAsFixed(2)}'),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(
                                                  //   SnackBar(
                                                  //       content: Text(
                                                  //           'Detail untuk SO ID: ${order.idSalesOrder}')),
                                                  // );
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailAllDataSOScreen(
                                                        idSalesOrder:
                                                            order.idSalesOrder,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text("Detail"),
                                              ),
                                              if (showActionButtons) ...[
                                                const SizedBox(width: 8),
                                                OutlinedButton(
                                                  onPressed: () => _rejectOrder(
                                                      order.idSalesOrder),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                    side: const BorderSide(
                                                        color: Colors.red),
                                                  ),
                                                  child: const Text("Reject"),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _validateOrder(
                                                          order.idSalesOrder),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  child: const Text("Validate"),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
