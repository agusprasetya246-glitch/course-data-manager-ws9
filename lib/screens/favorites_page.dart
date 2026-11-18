// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_view.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';

/// Tab Favorites: course yang ditandai favorit (shared state dari provider).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<CourseProvider>().favoriteCourses;
    final access = context.watch<ProfileProvider>();

    if (favorites.isEmpty) {
      return const EmptyView(
        icon: Icons.favorite_border_rounded,
        message: 'Belum ada mata kuliah favorit.',
        hint: 'Ketuk ikon hati pada kartu course.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = favorites[index];
        return CourseCard(
          course: course,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
          ),
          // Mahasiswa tetap bisa memfavoritkan, tapi tidak bisa mengedit.
          onEdit: access.canModify(course)
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CourseFormPage(initialCourse: course),
                  ),
                )
              : null,
        );
      },
    );
  }
}
