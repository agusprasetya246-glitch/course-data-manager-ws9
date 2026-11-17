// NIM: 2415051039 | Nama: Agus Prasetya
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';
import 'course_data_source.dart';

/// Sumber data course dari REST API (Pertemuan 7, Tahap 2-9).
class CourseApiService implements CourseDataSource {
  CourseApiService(this.baseUrl, {http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  @override
  Future<List<Course>> getCourses() async {
    final response = await _client.get(_uri('/courses'));
    _ensureSuccess(response, 'mengambil course');

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final response = await _client.post(
      _uri('/courses'),
      headers: _jsonHeaders,
      body: jsonEncode(course.toJson()),
    );
    _ensureSuccess(response, 'membuat course');

    return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    final response = await _client.put(
      _uri('/courses/$id'),
      headers: _jsonHeaders,
      body: jsonEncode(course.toJson()),
    );
    _ensureSuccess(response, 'memperbarui course');
  }

  @override
  Future<void> deleteCourse(int id) async {
    final response = await _client.delete(_uri('/courses/$id'));
    _ensureSuccess(response, 'menghapus course');
  }

  void _ensureSuccess(http.Response response, String action) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal $action (HTTP ${response.statusCode})');
    }
  }
}
