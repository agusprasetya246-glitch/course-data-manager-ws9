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
  if (error is PostgrestException) {
    return 'Database menolak permintaan: ${error.message}';
  }
  return text.startsWith('Exception: ') ? text.substring(11) : text;
}
