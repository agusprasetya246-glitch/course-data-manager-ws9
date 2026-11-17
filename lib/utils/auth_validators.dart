// NIM: 2415051039 | Nama: Agus Prasetya

/// Validator form untuk LoginPage dan RegisterPage.
/// Nilainya sama dengan "Minimum password length" di Supabase.
const int minPasswordLength = 6;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email wajib diisi';
  if (!_emailPattern.hasMatch(email)) return 'Format email tidak valid';
  return null;
}

/// [checkLength] dimatikan di halaman Login: cukup wajib diisi,
/// benar atau salahnya password diputuskan oleh Supabase.
String? validatePassword(String? value, {bool checkLength = true}) {
  if (value == null || value.isEmpty) return 'Password wajib diisi';
  if (checkLength && value.length < minPasswordLength) {
    return 'Password minimal $minPasswordLength karakter';
  }
  return null;
}
