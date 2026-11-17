// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

/// Kartu satu course. Navigasi diserahkan ke pemanggil lewat callback,
/// jadi widget ini tidak bergantung pada screen tertentu.
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.onEdit,
  });

  final Course course;
  final VoidCallback onTap;

  /// null = tombol edit tidak ditampilkan.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // select: kartu hanya rebuild kalau status favorit course ini berubah.
    final isFavorite = context.select<CourseProvider, bool>(
      (provider) => provider.isFavorite(course.code),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.menu_book_rounded, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          course.code,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        _Badge(
                          label: '${course.credits} SKS',
                          color: Colors.green.shade800,
                          background: Colors.green.shade100,
                        ),
                        _Badge(
                          label: course.statusLabel,
                          color: colorScheme.primary,
                          background: colorScheme.primaryContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                ),
                color: isFavorite ? Colors.pink.shade400 : Colors.grey.shade400,
                onPressed: () =>
                    context.read<CourseProvider>().toggleFavorite(course.code),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit course',
                  icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  onPressed: onEdit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
