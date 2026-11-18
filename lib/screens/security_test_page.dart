// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_info.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/profile_provider.dart';

/// Halaman uji keamanan RLS (Praktik 6), hanya tampil di mode debug.
/// Halaman ini memanggil Supabase LANGSUNG dan melewati semua pengecekan
/// di UI, seperti yang bisa dilakukan penyerang. Hasil yang diharapkan:
/// database tetap menolak perubahan pada data milik pengguna lain.
class SecurityTestPage extends StatefulWidget {
  const SecurityTestPage({super.key});

  @override
  State<SecurityTestPage> createState() => _SecurityTestPageState();
}

class _SecurityTestPageState extends State<SecurityTestPage> {
  static const _table = 'courses';

  final _client = Supabase.instance.client;
  final List<_TestResult> _results = [];
  int? _targetId;
  bool _isRunning = false;

  void _record(String name, String expected, String actual, String detail) {
    if (!mounted) return;
    setState(() => _results.add(_TestResult(name, expected, actual, detail)));
  }

  Future<void> _runTests(Course target) async {
    final id = target.id;
    if (id == null) return;
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    // 1. SELECT: membaca daftar course -> harus DIIZINKAN
    const selectName = 'Melihat daftar course';
    try {
      final rows = await _client.from(_table).select('id');
      _record(
        selectName,
        'Allowed',
        'Allowed',
        '${rows.length} course terbaca',
      );
    } on PostgrestException catch (e) {
      _record(selectName, 'Allowed', 'Denied', '${e.code}: ${e.message}');
    }

    // 2. UPDATE course milik orang lain -> harus DITOLAK
    final updateName = 'Mengedit course ${target.code} milik orang lain';
    try {
      final rows = await _client
          .from(_table)
          .update({'title': 'DIUBAH OLEH PENYERANG'})
          .eq('id', id)
          .select('id');
      _record(
        updateName,
        'Denied',
        rows.isEmpty ? 'Denied' : 'Allowed',
        rows.isEmpty ? '0 baris berubah, ditolak RLS' : 'DATA BERHASIL DIUBAH!',
      );
    } on PostgrestException catch (e) {
      _record(updateName, 'Denied', 'Denied', '${e.code}: ${e.message}');
    }

    // 3. DELETE course milik orang lain -> harus DITOLAK
    final deleteName = 'Menghapus course ${target.code} milik orang lain';
    try {
      final rows = await _client
          .from(_table)
          .delete()
          .eq('id', id)
          .select('id');
      _record(
        deleteName,
        'Denied',
        rows.isEmpty ? 'Denied' : 'Allowed',
        rows.isEmpty
            ? '0 baris terhapus, ditolak RLS'
            : 'DATA BERHASIL DIHAPUS!',
      );
    } on PostgrestException catch (e) {
      _record(deleteName, 'Denied', 'Denied', '${e.code}: ${e.message}');
    }

    // 4. INSERT dengan owner_id milik orang lain -> harus DITOLAK (42501)
    final insertName = 'Menambah course atas nama pemilik ${target.code}';
    try {
      await _client.from(_table).insert({
        'code': 'HACK${DateTime.now().millisecondsSinceEpoch % 10000}',
        'title': 'Course palsu',
        'credits': 1,
        'owner_id': target.ownerId,
      });
      _record(insertName, 'Denied', 'Allowed', 'BARIS PALSU TERSIMPAN!');
    } on PostgrestException catch (e) {
      _record(insertName, 'Denied', 'Denied', '${e.code}: ${e.message}');
    }

    // 5. Baca ulang dari database: course target harus masih utuh
    final checkName = 'Course ${target.code} masih utuh di database';
    try {
      final row = await _client
          .from(_table)
          .select('title')
          .eq('id', id)
          .maybeSingle();
      final intact = row != null && row['title'] == target.title;
      _record(
        checkName,
        'Utuh',
        intact ? 'Utuh' : 'Berubah',
        row == null ? 'Course hilang!' : 'Judul: ${row['title']}',
      );
    } on PostgrestException catch (e) {
      _record(checkName, 'Utuh', 'Error', '${e.code}: ${e.message}');
    }

    if (mounted) setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final myId = profile?.id;
    final others = context
        .watch<CourseProvider>()
        .courses
        .where((course) => course.id != null && course.ownerId != myId)
        .toList();

    Course? target;
    for (final course in others) {
      if (course.id == _targetId) target = course;
    }
    final selected = target;
    final passed = _results.where((result) => result.passed).length;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Uji Keamanan RLS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('Login sebagai: ${profile?.displayName ?? '-'}'),
              subtitle: Text(
                '${profile?.email ?? '-'} • ${profile?.roleLabel ?? '-'}',
              ),
            ),
          ),
          if (profile?.isAdmin ?? false)
            Card(
              color: Colors.orange.shade100,
              child: const ListTile(
                leading: Icon(Icons.warning_amber_rounded),
                title: Text('Admin memang boleh mengubah semua course'),
                subtitle: Text(
                  'Untuk uji ini, login sebagai Pengajar lain atau Mahasiswa.',
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Pilih course milik pengguna lain sebagai target, lalu jalankan '
            'uji. Halaman ini memanggil Supabase langsung, tanpa pengecekan '
            'apa pun di aplikasi.',
          ),
          const SizedBox(height: 16),
          if (others.isEmpty)
            const Text('Tidak ada course milik pengguna lain.')
          else
            DropdownButtonFormField<int>(
              initialValue: selected?.id,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Course target',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final course in others)
                  DropdownMenuItem(
                    value: course.id!,
                    child: Text(
                      '${course.code} – ${course.title}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _isRunning
                  ? null
                  : (id) => setState(() => _targetId = id),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: (_isRunning || selected == null)
                ? null
                : () => _runTests(selected),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Jalankan Uji'),
          ),
          if (_isRunning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Hasil: $passed dari ${_results.length} uji PASS',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final result in _results)
              Card(
                child: ListTile(
                  leading: Icon(
                    result.passed ? Icons.check_circle : Icons.cancel,
                    color: result.passed ? Colors.green : Colors.red,
                  ),
                  title: Text(result.name),
                  subtitle: Text(
                    'Expected: ${result.expected} • Actual: ${result.actual}\n'
                    '${result.detail}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    result.passed ? 'PASS' : 'FAIL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: result.passed ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Text(
            '${AppInfo.studentId} · ${AppInfo.studentName}',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Satu baris hasil uji: PASS kalau hasil sebenarnya sama dengan harapan.
class _TestResult {
  const _TestResult(this.name, this.expected, this.actual, this.detail);

  final String name;
  final String expected;
  final String actual;
  final String detail;

  bool get passed => expected == actual;
}
