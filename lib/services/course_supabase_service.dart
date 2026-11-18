// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

/// Sumber data course dari tabel `courses` di Supabase.
/// Hak akses dijaga oleh Row Level Security di database (Worksheet 9).
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

  /// INSERT yang ditolak RLS melempar PostgrestException (kode 42501).
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
    final rows = await _client
        .from(_table)
        .update(course.toJson())
        .eq('id', id)
        .select('id');
    _ensureAffected(rows, 'mengubah');
  }

  @override
  Future<void> deleteCourse(int id) async {
    final rows = await _client.from(_table).delete().eq('id', id).select('id');
    _ensureAffected(rows, 'menghapus');
  }

  /// UPDATE/DELETE yang ditolak RLS TIDAK melempar error: barisnya hanya
  /// tidak ikut terpengaruh. Hasil kosong berarti operasi ditolak
  /// (atau course-nya sudah tidak ada).
  void _ensureAffected(List<dynamic> rows, String action) {
    if (rows.isEmpty) {
      throw Exception(
        'Akses ditolak: Anda tidak berhak $action course ini, '
        'atau course sudah tidak ada.',
      );
    }
  }
}
