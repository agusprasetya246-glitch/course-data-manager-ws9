// NIM: 2415051039 | Nama: Agus Prasetya
import '../models/course.dart';

/// Kontrak sumber data course. Implementasinya REST API atau Supabase,
/// dipilih di main.dart tanpa mengubah repository, provider, atau screen.
abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
}
