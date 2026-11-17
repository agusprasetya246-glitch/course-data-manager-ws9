// NIM: 2415051039 | Nama: Agus Prasetya
import '../models/course.dart';
import '../services/course_data_source.dart';

/// Penghubung provider dengan sumber data yang sedang aktif.
class CourseRepository {
  CourseRepository(this._dataSource);

  final CourseDataSource _dataSource;

  Future<List<Course>> getCourses() => _dataSource.getCourses();

  Future<Course> createCourse(Course course) =>
      _dataSource.createCourse(course);

  Future<void> updateCourse(int id, Course course) =>
      _dataSource.updateCourse(id, course);

  Future<void> deleteCourse(int id) => _dataSource.deleteCourse(id);
}
