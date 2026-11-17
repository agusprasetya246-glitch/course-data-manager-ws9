// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

import '../config/app_info.dart';
import '../services/auth_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/auth_validators.dart';
import '../utils/error_message.dart';
import 'main_screen.dart';

/// Halaman pendaftaran akun baru melalui Supabase Auth.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    // Diambil sebelum await agar context tidak dipakai setelah jeda async.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);

    try {
      final response = await AuthService.instance.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.session != null) {
        // Confirm email nonaktif: akun langsung login dan masuk aplikasi.
        showAppSnackBar(messenger, 'Akun berhasil dibuat');
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        // Confirm email aktif: akun bisa dipakai setelah link di email dibuka.
        showAppSnackBar(
          messenger,
          'Registrasi berhasil. Buka email Anda untuk konfirmasi akun.',
        );
        navigator.pop();
      }
    } catch (error) {
      showAppSnackBar(messenger, readableError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daftar untuk memakai ${AppInfo.appName}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      helperText: 'Minimal $minPasswordLength karakter',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password wajib diisi';
                      }
                      if (value != _passwordController.text) {
                        return 'Password tidak sama';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _register(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _register,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Sudah punya akun? Login'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppInfo.studentId} · ${AppInfo.studentName}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
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
