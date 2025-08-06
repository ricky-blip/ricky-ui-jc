import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/model/draft_so_model.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/service/draft_so_service.dart';
import 'package:ricky_ui_jc/service/submit_draft_order_service.dart'; // Import the new service
import 'package:shared_preferences/shared_preferences.dart';

class DraftSalesOrderScreen extends StatefulWidget {
  const DraftSalesOrderScreen({super.key});

  @override
  State<DraftSalesOrderScreen> createState() => _DraftSalesOrderScreenState();
}

class _DraftSalesOrderScreenState extends State<DraftSalesOrderScreen> {
  String _fullName = '';
  String _role = '';
  List<DraftSalesOrderModel> _draftSalesOrders = [];
  bool _isLoading = false; // Add loading state for refresh

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? '';
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> _fetchDraftSalesOrders() async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching
    });
    try {
      final response = await DraftSalesOrderService().getDraftSalesOrders();
      setState(() {
        _draftSalesOrders = response.data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat draft sales order: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading =
            false; // Set loading to false after fetching (success or error)
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
    await _fetchDraftSalesOrders();
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

  // --- Placeholder Action Functions ---

  void _navigateToEdit(int idSalesOrder) {
    // Example navigation:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditDraftSOScreen(idSalesOrder: idSalesOrder),
    //   ),
    // );
    print("Navigating to Edit screen for ID: $idSalesOrder");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Edit for SO ID: $idSalesOrder - Not Implemented')),
    );
  }

  void _navigateToDetail(int idSalesOrder) {
    // Example navigation:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DetailDraftSOScreen(idSalesOrder: idSalesOrder),
    //   ),
    // );
    print("Navigating to Detail screen for ID: $idSalesOrder");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Detail for SO ID: $idSalesOrder - Not Implemented')),
    );
  }

  Future<void> _submitDraftOrder(int idSalesOrder) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response =
          await SubmitDraftOrderService().submitDraftOrder(idSalesOrder);

      if (response.meta.status == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.meta.message)),
        );
        // Optionally, remove the submitted draft from the list
        setState(() {
          _draftSalesOrders
              .removeWhere((draft) => draft.idSalesOrder == idSalesOrder);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim Sales Order ke approval')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim Sales Order ke approval: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _deleteDraft(int idSalesOrder) async {
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: const Text(
                  'Apakah Anda yakin ingin menghapus draft sales order ini?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false
                  },
                ),
                TextButton(
                  child:
                      const Text('Hapus', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Handle case where dialog is dismissed

    if (confirm) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // You need to implement the actual delete logic in your service
        // For example: await DraftSalesOrderService().deleteDraftSalesOrder(idSalesOrder);
        // For now, simulate a successful delete call
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate network delay
        // throw Exception("Simulated Delete Error"); // Uncomment to test error handling

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft berhasil dihapus')),
          );
          // Refresh the list after deletion
          await _fetchDraftSalesOrders();
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
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDraftSalesOrders();
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
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: _isLoading && _draftSalesOrders.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _draftSalesOrders.length,
                          itemBuilder: (context, index) {
                            final draft = _draftSalesOrders[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.red.shade100,
                                ),
                              ),
                              margin: const EdgeInsets.only(
                                  bottom: 12, left: 16, right: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Bar with Title and Delete Button
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
                                        // Delete Button (Top Right)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteDraft(draft.idSalesOrder),
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                    // Draft Details
                                    Text('No Faktur: ${draft.noFaktur}'),
                                    Text(
                                        'Nama Customer: ${draft.namaCustomer}'),
                                    Text(
                                        'Jenis Transaksi: ${draft.transactionType}'),
                                    Text(
                                      'Total Harga: Rp ${draft.totalHarga.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 12),
                                    // Edit and Detail Buttons (Middle)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _navigateToEdit(
                                              draft.idSalesOrder),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Edit"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _navigateToDetail(
                                              draft.idSalesOrder),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Detail"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Submit Button (Bottom)
                                    SizedBox(
                                      width: double
                                          .infinity, // Make button full width
                                      child: ElevatedButton(
                                        onPressed: () => _submitDraftOrder(
                                            draft.idSalesOrder),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
