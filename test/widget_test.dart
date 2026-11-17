// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_data_source.dart';
import 'package:flutter_ui_fundamentals/widgets/course_card.dart';

/// Data source palsu supaya test tidak membutuhkan Supabase.
class _FakeDataSource implements CourseDataSource {
  final List<Course> items = [
    const Course(
      id: 1,
      code: 'MOB101',
      title: 'Pemrograman Mobile',
      credits: 3,
      status: 'active',
    ),
  ];

  @override
  Future<List<Course>> getCourses() async => List.of(items);

  @override
  Future<Course> createCourse(Course course) async {
    items.add(course);
    return course;
  }

  @override
  Future<void> updateCourse(int id, Course course) async {}

  @override
  Future<void> deleteCourse(int id) async {
    items.removeWhere((course) => course.id == id);
  }
}

void main() {
  test('Course.fromJson dan toJson', () {
    final course = Course.fromJson({
      'id': 7,
      'code': 'PBM',
      'title': 'Pemrograman Mobile',
      'credits': 3,
      'status': 'done',
    });

    expect(course.id, 7);
    expect(course.statusLabel, 'Done');
    expect(course.toJson(), {
      'code': 'PBM',
      'title': 'Pemrograman Mobile',
      'credits': 3,
      'status': 'done',
    });
  });

  test('Menghapus course juga menghapusnya dari favorites', () async {
    final provider = CourseProvider(CourseRepository(_FakeDataSource()));
    await provider.loadCourses();
    provider.toggleFavorite('MOB101');
    expect(provider.favoriteCount, 1);

    await provider.deleteCourse(provider.courses.first);

    expect(provider.courses, isEmpty);
    expect(provider.favoriteCount, 0);
  });

  testWidgets('CourseCard menampilkan data dan bisa ditandai favorit', (
    tester,
  ) async {
    final provider = CourseProvider(CourseRepository(_FakeDataSource()));
    await provider.loadCourses();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: CourseCard(course: provider.courses.first, onTap: () {}),
          ),
        ),
      ),
    );

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('MOB101'), findsOneWidget);
    expect(find.text('3 SKS'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
    await tester.pump();

    expect(provider.isFavorite('MOB101'), isTrue);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });
}
