// NIM: 2415051039 | Nama: Agus Prasetya

/// Batas lebar layar untuk layout responsif.
class Breakpoints {
  Breakpoints._();

  /// Mulai lebar ini navigasi memakai NavigationRail.
  static const double expanded = 840;

  static bool isExpanded(double width) => width >= expanded;

  /// Jumlah kolom daftar course sesuai lebar area yang tersedia.
  static int courseColumns(double width) {
    if (width >= 1200) return 3;
    if (width >= 720) return 2;
    return 1;
  }
}
