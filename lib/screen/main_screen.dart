// screen/main_screen.dart
import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/screen/draft_sales_order_screen.dart';
import 'package:ricky_ui_jc/screen/input_sales_order_screen.dart';
import 'package:ricky_ui_jc/screen/order_approval_screen.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/utils/secure_storage.dart';
import 'package:ricky_ui_jc/utils/jwt_decoder.dart'; // ← Import decoder

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  String _fullName = '';
  String _role = '';

  final List<Widget> _screens = const [
    InputSalesOrderScreen(),
    DraftSalesOrderScreen(),
    OrderApprovalScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _loadUserData();
    _checkTokenValidity(); // Cek token saat pertama kali masuk
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final fullName = await SecureStorage.read(key: 'fullName');
      final role = await SecureStorage.read(key: 'role');

      if (mounted) {
        setState(() {
          _fullName = fullName ?? 'User';
          _role = role ?? 'Role tidak diketahui';
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

  // 🔐 Cek apakah token masih valid
  Future<void> _checkTokenValidity() async {
    try {
      final token = await SecureStorage.read(key: 'token');
      if (token == null) {
        await _forceLogout('Token tidak ditemukan.');
        return;
      }

      if (JwtDecoder.isTokenExpired(token)) {
        await _forceLogout('Sesi telah berakhir. Silakan login kembali.');
        return;
      }
    } catch (e) {
      await _forceLogout('Terjadi kesalahan saat memverifikasi sesi.');
    }
  }

  // 🔐 Fungsi logout paksa
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

  // 🔁 Fungsi untuk cek token sebelum request API (dipanggil di child screen)
  Future<bool> isTokenValid() async {
    try {
      final token = await SecureStorage.read(key: 'token');
      if (token == null) return false;
      return !JwtDecoder.isTokenExpired(token);
    } catch (e) {
      return false;
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      _onTabTapped(0);
      return false;
    }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $_fullName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _role,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD32F2F),
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                size: 18,
                color: Colors.white,
              ),
              onPressed: () async {
                bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm) {
                  await SecureStorage.deleteAll();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              tooltip: 'Logout',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFD32F2F),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Input Sales Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              activeIcon: Icon(Icons.edit),
              label: 'Draft Sales Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Order Approval',
            ),
          ],
        ),
      ),
    );
  }
}
