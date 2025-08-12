import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ricky_ui_jc/model/draft/get/draft_so_model.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/screen/detail_draft_sales_order_screen.dart';
import 'package:ricky_ui_jc/screen/edit_draft_sales_order_screen.dart';
import 'package:ricky_ui_jc/service/draft_so_service.dart';
import 'package:ricky_ui_jc/service/delete_draft_order_service.dart';
import 'package:ricky_ui_jc/service/submit_draft_order_service.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/network/network_api.dart';

class DraftSalesOrderScreen extends StatefulWidget {
  const DraftSalesOrderScreen({super.key});

  @override
  State<DraftSalesOrderScreen> createState() => _DraftSalesOrderScreenState();
}

class _DraftSalesOrderScreenState extends State<DraftSalesOrderScreen>
    with TickerProviderStateMixin {
  String _fullName = '';
  String _role = '';
  List<DraftSalesOrderModel> _draftSalesOrders = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final DraftSalesOrderService _draftService = DraftSalesOrderService();
  final DeleteDraftOrderService _deleteService = DeleteDraftOrderService();
  final SubmitDraftOrderService _submitService = SubmitDraftOrderService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUserData();
    _fetchDraftSalesOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
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
        _showErrorSnackBar('Gagal muat data user: $e');
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
        _animationController.forward();
      } else {
        setState(() {
          _draftSalesOrders = [];
        });
        _showErrorSnackBar(response.meta.message);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat draft sales order: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchDrafts(String query) async {
    try {
      final isValid = await SecureStorage.isTokenValid();
      if (!isValid) {
        await _forceLogout('Sesi telah berakhir. Silakan login ulang.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final token = await SecureStorage.read(key: 'token');
      final response = await http.get(
        Uri.parse('$baseUrlHp/sales-orders/drafts/search?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['data'];
        final results =
            list.map((e) => DraftSalesOrderModel.fromJson(e)).toList();

        if (mounted) {
          setState(() {
            _draftSalesOrders = results;
            _isLoading = false;
          });
        }
      } else {
        final error = json.decode(response.body)['meta']['message'];
        print('Gagal mencari: $error');
        if (mounted) {
          setState(() {
            _draftSalesOrders = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forceLogout(String message) async {
    await SecureStorage.deleteAll();
    if (mounted) {
      _showErrorSnackBar(message);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteDraft(int idSalesOrder) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever, color: Colors.red.shade600),
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus draft ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _deleteService.deleteDraft(idSalesOrder);
        if (response.meta.status == 'success') {
          _showSuccessSnackBar(response.meta.message);
          await _fetchDraftSalesOrders();
        } else {
          _showErrorSnackBar('Gagal menghapus draft');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal menghapus draft: $e');
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
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mengirim ke approval...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await _submitService.submit(idSalesOrder);
      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar("Sales Order berhasil dikirim ke approval");
      setState(() {
        _draftSalesOrders
            .removeWhere((draft) => draft.idSalesOrder == idSalesOrder);
      });
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Gagal mengirim Sales Order ke approval: $e');
    }
  }

  Future<void> _refreshData() async {
    _searchController.clear();
    _animationController.reset();
    await _loadUserData();
    await _fetchDraftSalesOrders();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDraftCard(DraftSalesOrderModel draft, int index) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'ID: ${draft.idSalesOrder}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (_role != 'SALES_MANAGER')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade600,
                                    size: 16,
                                  ),
                                  onPressed: () =>
                                      _deleteDraft(draft.idSalesOrder),
                                  tooltip: 'Hapus Draft',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Divider(),
                        // Content
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.receipt_long, 'No Faktur',
                                  draft.noFaktur, true),
                              const Divider(height: 12, color: Colors.grey),
                              _buildInfoRow(Icons.person_outline, 'Customer',
                                  draft.namaCustomer, false),
                              const Divider(height: 12, color: Colors.grey),
                              _buildInfoRow(Icons.swap_horiz, 'Transaksi',
                                  draft.transactionType, false),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_role != 'SALES_MANAGER') ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditDraftSalesOrderScreen(
                                          idSalesOrder: draft.idSalesOrder,
                                        ),
                                      ),
                                    );
                                  },
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 16),
                                  label: const Text("Edit"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side:
                                        const BorderSide(color: Colors.orange),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailDraftSalesOrderScreen(
                                        idSalesOrder: draft.idSalesOrder,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text("Detail"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_role != 'SALES_MANAGER') ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _submitDraftOrder(draft.idSalesOrder),
                              icon: const Icon(Icons.send, size: 16),
                              label: const Text("Submit"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.drafts_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada draft sales order',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Draft sales order akan muncul di sini',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.blue.shade600,
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

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  _fetchDraftSalesOrders();
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
                        setState(() {}); // Update suffix icon
                        if (value.isEmpty) {
                          _fetchDraftSalesOrders();
                        } else {
                          _searchDrafts(value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: _isLoading && _draftSalesOrders.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Memuat draft sales order...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _draftSalesOrders.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _draftSalesOrders.length,
                              itemBuilder: (context, index) {
                                final draft = _draftSalesOrders[index];
                                return _buildDraftCard(draft, index);
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
