// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

import '../config/app_info.dart';
import '../utils/app_snackbar.dart';

/// Form feedback di halaman Profile (simulasi kirim, tanpa backend).
class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndSend() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('Konfirmasi'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin mengirim feedback ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Kirim'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSending = true);

    // Simulasi pengiriman ke server.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _isSending = false);
    _commentController.clear();
    showAppSnackBar(messenger, 'Feedback berhasil dikirim!');
  }

  InputDecoration _decoration(String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      filled: true,
      fillColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kirim Feedback',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: AppInfo.studentName,
            readOnly: true,
            decoration: _decoration('Nama Lengkap', Icons.person),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: AppInfo.studentId,
            readOnly: true,
            decoration: _decoration('Nomor Induk Mahasiswa', Icons.badge),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            maxLines: 3,
            decoration: _decoration(
              'Tulis komentar Anda...',
              Icons.chat_bubble_outline,
            ),
            validator: (value) => (value == null || value.trim().length < 5)
                ? 'Komentar minimal 5 karakter'
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSending ? null : _confirmAndSend,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSending
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text(
                    'Kirim Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
