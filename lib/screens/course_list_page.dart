// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/breakpoints.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';

/// Tab Courses: daftar course dari database dengan loading, error,
/// empty state, dan tarik-untuk-refresh.
class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = provider.error;
    if (error != null) {
      return ErrorView(
        message: error,
        onRetry: () => context.read<CourseProvider>().loadCourses(),
      );
    }

    final courses = provider.courses;
    if (courses.isEmpty) {
      return const EmptyView(
        icon: Icons.school_outlined,
        message: 'Data course belum tersedia',
        hint: 'Ketuk Tambah Course untuk menambahkan data.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<CourseProvider>().loadCourses(showLoading: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // LayoutBuilder: 1 kolom di layar sempit, 2-3 kolom di layar lebar.
          final columns = Breakpoints.courseColumns(constraints.maxWidth);
          final rowCount = (courses.length / columns).ceil();

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            // Ruang bawah supaya kartu terakhir tidak tertutup tombol Tambah.
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: rowCount,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, row) {
              final start = row * columns;
              // IntrinsicHeight: kartu dalam satu baris sama tinggi,
              // dan tingginya mengikuti isi (aman untuk font besar).
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: start + i < courses.length
                            ? _buildCard(context, courses[start + i])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, Course course) {
    return CourseCard(
      course: course,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
      ),
      onEdit: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CourseFormPage(initialCourse: course),
        ),
      ),
    );
  }
}
