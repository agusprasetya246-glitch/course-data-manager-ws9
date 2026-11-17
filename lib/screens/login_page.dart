// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

import '../config/app_info.dart';
import '../services/auth_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/auth_validators.dart';
import '../utils/error_message.dart';
import 'main_screen.dart';
import 'register_page.dart';

/// Halaman login dengan email dan password melalui Supabase Auth.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    // Diambil sebelum await agar context tidak dipakai setelah jeda async.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);

    try {
      await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      showAppSnackBar(messenger, 'Login berhasil');
      // Login dihapus dari tumpukan agar tombol Back tidak kembali ke sini.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (error) {
      showAppSnackBar(messenger, readableError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openRegister() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.school_rounded,
                      size: 36,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppInfo.appName,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk untuk mengelola data course',
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
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                    validator: (value) =>
                        validatePassword(value, checkLength: false),
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : _openRegister,
                    child: const Text('Belum punya akun? Register'),
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
