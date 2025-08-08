import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/service/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Future<void> Function(String message) onForceLogout;

  const ChangePasswordScreen({super.key, required this.onForceLogout});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _authService = AuthService();

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await _authService.changePassword(
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        confirmNewPassword: _confirmPasswordController.text.trim(),
      );

      if (res.meta.code == 200) {
        await widget
            .onForceLogout("Password berhasil diubah. Silakan login kembali.");
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.meta.message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: "Password Lama",
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureOld ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                obscureText: _obscureOld,
                validator: (value) =>
                    value!.isEmpty ? "Password lama wajib diisi" : null,
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: "Password Baru",
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                obscureText: _obscureNew,
                validator: (value) =>
                    value!.isEmpty ? "Password baru wajib diisi" : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password Baru",
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                obscureText: _obscureConfirm,
                validator: (value) {
                  if (value!.isEmpty) return "Konfirmasi password wajib diisi";
                  if (value != _newPasswordController.text) {
                    return "Konfirmasi password tidak cocok";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleChangePassword,
                      child: const Text("Ubah Password"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
