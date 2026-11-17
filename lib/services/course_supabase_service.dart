// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

/// Sumber data course dari tabel `courses` di Supabase (Pertemuan 7, Tahap 12-15).
class CourseSupabaseService implements CourseDataSource {
  CourseSupabaseService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'courses';

  @override
  Future<List<Course>> getCourses() async {
    final rows = await _client.from(_table).select().order('id');
    return rows.map(Course.fromJson).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final row = await _client
        .from(_table)
        .insert(course.toJson())
        .select()
        .single();
    return Course.fromJson(row);
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    await _client.from(_table).update(course.toJson()).eq('id', id);
  }

  @override
  Future<void> deleteCourse(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
