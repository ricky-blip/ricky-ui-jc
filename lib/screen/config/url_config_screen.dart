import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/network/config_network_service.dart';
import 'package:ricky_ui_jc/network/network_api.dart';
import 'package:ricky_ui_jc/screen/splash_screen.dart';

class UrlConfigScreen extends StatefulWidget {
  const UrlConfigScreen({super.key});

  @override
  State<UrlConfigScreen> createState() => _UrlConfigScreenState();
}

class _UrlConfigScreenState extends State<UrlConfigScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _saveUrl() async {
    String ipPort = _controller.text.trim();

    if (ipPort.isEmpty) {
      setState(() => _errorMessage = "IP & Port tidak boleh kosong");
      return;
    }
    if (!RegExp(r'^\d{1,3}(\.\d{1,3}){3}:\d+$').hasMatch(ipPort)) {
      setState(() => _errorMessage = "Format IP & Port tidak valid");
      return;
    }

    String fullUrl = 'http://$ipPort/api';
    await ConfigService.setBaseUrl(fullUrl);
    baseUrlHp = fullUrl;

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        title: const Text(
          'Set URL API',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.link,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Masukkan IP dan Port Server",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Contoh: 192.168.0.10:8080",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'IP & Port',
                      hintText: '192.168.x.x:8080',
                      prefixIcon: const Icon(Icons.cloud),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: _errorMessage,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveUrl,
                      icon: const Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Simpan & Lanjut",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
