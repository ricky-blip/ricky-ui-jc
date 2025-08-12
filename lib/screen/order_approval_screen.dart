// screen/order_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/screen/detail_all_data_screen.dart';
import 'package:ricky_ui_jc/service/approval/rejected_so_service.dart';
import 'package:ricky_ui_jc/service/approval/validated_so_service.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/service/approval_order_service.dart';
import 'package:ricky_ui_jc/model/approval_order_model.dart';
import 'package:ricky_ui_jc/network/network_api.dart';

// Enum untuk merepresentasikan status filter
enum OrderStatus { unvalidated, rejected, validated }

class OrderApprovalScreen extends StatefulWidget {
  const OrderApprovalScreen({super.key});

  @override
  State<OrderApprovalScreen> createState() => _OrderApprovalScreenState();
}

class _OrderApprovalScreenState extends State<OrderApprovalScreen> {
  String _fullName = '';
  String _role = '';
  ApprovalOrderResponseModel? _orders;
  bool _isLoading = true;
  OrderStatus _selectedFilter = OrderStatus.unvalidated;
  final TextEditingController _searchController = TextEditingController();

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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Gagal muat data user: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
        _orders = null;
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Gagal memuat data Sales Order: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {
          _isLoading = false;
          _orders = null;
        });
      }
    }
  }

  Future<void> _searchOrders(OrderStatus status, String query) async {
    try {
      final isValid = await SecureStorage.isTokenValid();
      if (!isValid) {
        await _forceLogout('Sesi telah berakhir. Silakan login ulang.');
        return;
      }

      setState(() {
        _isLoading = true;
        _orders = null;
      });

      final token = await SecureStorage.read(key: 'token');
      // ✅ Backend sudah pakai UPPER() dan LIKE, jadi kita kirim query apa saja
      final response = await http.get(
        Uri.parse(
            '$baseUrlHp/sales-orders/${_getStatusPath(status)}/search?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orders = ApprovalOrderResponseModel.fromJson(data);
        if (mounted) {
          setState(() {
            _orders = orders;
            _isLoading = false;
          });
        }
      } else {
        final error = json.decode(response.body)['meta']['message'];
        print('Gagal mencari: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _orders = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {
          _isLoading = false;
          _orders = null;
        });
      }
    }
  }

  String _getStatusPath(OrderStatus status) {
    switch (status) {
      case OrderStatus.unvalidated:
        return 'unvalidated';
      case OrderStatus.rejected:
        return 'rejected';
      case OrderStatus.validated:
        return 'validated';
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
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Order $idSalesOrder ditolak'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      _fetchOrders(_selectedFilter);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Gagal menolak order: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _validateOrder(int idSalesOrder) async {
    try {
      await _validatedService.validated(idSalesOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Order $idSalesOrder disetujui'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      _fetchOrders(_selectedFilter);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Gagal menyetujui order: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildFilterChip(OrderStatus status, String label, Color color) {
    final isSelected = _selectedFilter == status;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : color,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
      elevation: isSelected ? 4 : 0,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? color : color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = status;
            _searchController.clear();
          });
          _fetchOrders(status);
        }
      },
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildOrderCard(dynamic order) {
    final bool showActionButtons =
        _selectedFilter == OrderStatus.unvalidated && _role == 'SALES_MANAGER';

    Color statusColor;
    IconData statusIcon;

    switch (_selectedFilter) {
      case OrderStatus.unvalidated:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case OrderStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case OrderStatus.validated:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
      shadowColor: statusColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.2),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              statusColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          _selectedFilter.name.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID: ${order.idSalesOrder}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Order Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.receipt_long,
                      'No Faktur',
                      order.noFaktur,
                      true,
                    ),
                    const Divider(height: 16, color: Colors.grey),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Customer',
                      order.namaCustomer,
                      false,
                    ),
                    const Divider(height: 16, color: Colors.grey),
                    _buildInfoRow(
                      Icons.swap_horiz,
                      'Tipe Transaksi',
                      order.transactionType,
                      false,
                    ),
                    const Divider(height: 16, color: Colors.grey),
                    _buildInfoRow(
                      Icons.payments_outlined,
                      'Total Harga',
                      'Rp ${_formatCurrency(order.totalHarga)}',
                      false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailAllDataSOScreen(
                              idSalesOrder: order.idSalesOrder,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Detail'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (showActionButtons) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectOrder(order.idSalesOrder),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _validateOrder(order.idSalesOrder),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Validate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isBold) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showActionButtons =
        _selectedFilter == OrderStatus.unvalidated && _role == 'SALES_MANAGER';

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Approval Sales Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari no faktur, customer...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _fetchOrders(_selectedFilter);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _fetchOrders(_selectedFilter);
                          } else {
                            _searchOrders(_selectedFilter, value);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          OrderStatus.unvalidated,
                          'Unvalidated',
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildFilterChip(
                          OrderStatus.rejected,
                          'Rejected',
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildFilterChip(
                          OrderStatus.validated,
                          'Validated',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Memuat data...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Theme.of(context).primaryColor,
                        onRefresh: () => _searchController.text.isEmpty
                            ? _fetchOrders(_selectedFilter)
                            : _searchOrders(
                                _selectedFilter, _searchController.text),
                        child: _orders == null || _orders!.data.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.inbox_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Tidak ada data order',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tarik ke bawah untuk memuat ulang',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _orders!.data.length,
                                itemBuilder: (context, index) {
                                  final order = _orders!.data[index];
                                  return _buildOrderCard(order);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
