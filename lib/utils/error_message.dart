// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mengubah exception menjadi pesan yang bisa dibaca pengguna.
String readableError(Object error) {
  final text = error.toString();

  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('ClientException')) {
    return 'Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi.';
  }
  if (error is AuthException) {
    return _authMessage(error.message);
  }
  if (error is PostgrestException) {
    return 'Database menolak permintaan: ${error.message}';
  }
  return text.startsWith('Exception: ') ? text.substring(11) : text;
}

/// Menerjemahkan pesan Supabase Auth (bahasa Inggris) ke bahasa Indonesia.
String _authMessage(String message) {
  final lower = message.toLowerCase();

  if (lower.contains('invalid login credentials')) {
    return 'Email atau password salah.';
  }
  if (lower.contains('already registered')) {
    return 'Email sudah terdaftar. Silakan login.';
  }
  if (lower.contains('email not confirmed')) {
    return 'Email belum dikonfirmasi. Buka link konfirmasi di email Anda.';
  }
  if (lower.contains('password should be')) {
    return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
  }
  if (lower.contains('invalid format')) {
    return 'Format email tidak valid.';
  }
  if (lower.contains('rate limit')) {
    return 'Terlalu banyak percobaan. Tunggu beberapa menit, lalu coba lagi.';
  }
  return message;
}
