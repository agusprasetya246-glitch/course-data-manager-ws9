// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

/// SnackBar seragam untuk operasi berhasil (hijau) atau gagal (merah).
/// Menerima ScaffoldMessengerState yang diambil sebelum `await`.
void showAppSnackBar(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
}

/// SnackBar untuk push notification yang datang saat aplikasi sedang dibuka
/// (foreground), karena pada kondisi ini Android tidak menampilkannya.
void showNotificationSnackBar(
  ScaffoldMessengerState messenger, {
  required String title,
  required String body,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (body.isNotEmpty) Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}
