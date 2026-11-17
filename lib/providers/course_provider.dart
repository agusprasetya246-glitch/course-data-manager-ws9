// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../utils/error_message.dart';

class CourseProvider extends ChangeNotifier {
  CourseProvider(this._repository);

  final CourseRepository _repository;

  List<Course> _courses = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  final Set<String> _favoriteCodes = {};

  List<Course> get courses => List.unmodifiable(_courses);
  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;
  String? get error => _error;

  int get favoriteCount => _favoriteCodes.length;

  List<Course> get favoriteCourses =>
      _courses.where((course) => _favoriteCodes.contains(course.code)).toList();

  bool isFavorite(String code) => _favoriteCodes.contains(code);

  Course? courseById(int? id) {
    if (id == null) return null;
    for (final course in _courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  Future<void> loadCourses({bool showLoading = true}) async {
    if (showLoading) _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _repository.getCourses();
    } catch (e) {
      _error = readableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCourse(Course course) =>
      _save(() => _repository.createCourse(course));

  Future<void> updateCourse(int id, Course course) =>
      _save(() => _repository.updateCourse(id, course));

  /// DELETE, lalu hapus juga dari favorites.
  Future<void> deleteCourse(Course course) async {
    final id = course.id;
    if (id == null) return;

    await _save(() => _repository.deleteCourse(id));
    _favoriteCodes.remove(course.code);
    notifyListeners();
  }

  void toggleFavorite(String code) {
    if (!_favoriteCodes.remove(code)) {
      _favoriteCodes.add(code);
    }
    notifyListeners();
  }

  /// Dipanggil saat logout: mengosongkan data agar akun berikutnya
  /// tidak melihat course atau favorit milik akun sebelumnya.
  void clear() {
    _courses = [];
    _favoriteCodes.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save(Future<void> Function() action) async {
    _isSaving = true;
    notifyListeners();

    try {
      await action();
      await loadCourses(showLoading: false);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
