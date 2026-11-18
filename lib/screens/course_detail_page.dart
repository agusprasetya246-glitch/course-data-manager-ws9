// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/app_snackbar.dart';
import '../utils/error_message.dart';
import '../widgets/info_tile.dart';
import 'course_form_page.dart';

/// Detail satu course. Data awal diterima lewat constructor, lalu selalu
/// memakai versi terbaru dari provider supaya ikut berubah setelah diedit.
class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.course});

  final Course course;

  Future<void> _confirmDelete(BuildContext context, Course current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Course'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${current.title}" (${current.code})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Ambil semua yang butuh context SEBELUM await.
    final provider = context.read<CourseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await provider.deleteCourse(current);
      showAppSnackBar(messenger, 'Course ${current.code} berhasil dihapus!');
      navigator.pop();
    } catch (e) {
      showAppSnackBar(
        messenger,
        'Gagal menghapus course: ${readableError(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final current = provider.courseById(course.id) ?? course;
    final isFavorite = provider.isFavorite(current.code);
    final canModify = context.watch<ProfileProvider>().canModify(current);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              color: isFavorite ? Colors.pink.shade400 : null,
            ),
            onPressed: () =>
                context.read<CourseProvider>().toggleFavorite(current.code),
          ),
          // Edit dan Hapus hanya untuk pemilik course atau Admin.
          if (canModify) ...[
            IconButton(
              tooltip: 'Edit course',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CourseFormPage(initialCourse: current),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Hapus course',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: provider.isSaving
                  ? null
                  : () => _confirmDelete(context, current),
            ),
          ],
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  current.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InfoTile(
                      icon: Icons.qr_code,
                      label: 'Kode',
                      value: current.code,
                    ),
                    InfoTile(
                      icon: Icons.star_border_rounded,
                      label: 'SKS',
                      value: '${current.credits}',
                    ),
                    InfoTile(
                      icon: Icons.check_circle_outline,
                      label: 'Status',
                      value: current.statusLabel,
                    ),
                  ],
                ),
                const Divider(height: 48),
                const Text(
                  'Tentang Mata Kuliah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mata kuliah ${current.title} merupakan bagian dari kurikulum '
                  'yang wajib diselesaikan.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
