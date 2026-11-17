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
