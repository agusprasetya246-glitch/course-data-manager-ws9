// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_info.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/app_snackbar.dart';
import '../utils/error_message.dart';

/// Form tambah (initialCourse == null) atau edit course.
class CourseFormPage extends StatefulWidget {
  const CourseFormPage({super.key, this.initialCourse});

  final Course? initialCourse;

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _codeController = TextEditingController(
    text: widget.initialCourse?.code ?? '',
  );
  late final _titleController = TextEditingController(
    text: widget.initialCourse?.title ?? '',
  );
  late final _creditsController = TextEditingController(
    text: widget.initialCourse?.credits.toString() ?? '',
  );
  late String _status = widget.initialCourse?.status ?? 'planned';

  bool get _isEdit => widget.initialCourse != null;

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  String? _validateCredits(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Credits wajib diisi';

    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'Credits harus berupa angka positif';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final course = Course(
      id: widget.initialCourse?.id,
      code: _codeController.text.trim().toUpperCase(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    // Ambil semua yang butuh context SEBELUM await.
    final provider = context.read<CourseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final editId = widget.initialCourse?.id;

    try {
      if (editId != null) {
        await provider.updateCourse(editId, course);
      } else {
        await provider.createCourse(course);
      }
      showAppSnackBar(
        messenger,
        _isEdit ? 'Course berhasil diperbarui!' : 'Course berhasil ditambahkan!',
      );
      navigator.pop();
    } catch (e) {
      showAppSnackBar(
        messenger,
        'Gagal menyimpan: ${readableError(e)}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CourseProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? 'Edit Course (${AppInfo.studentId})'
              : 'Tambah Course (${AppInfo.studentId})',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mahasiswa: ${AppInfo.studentName} (${AppInfo.studentId})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              // Kode read-only saat edit, karena dipakai sebagai kunci favorites.
              TextFormField(
                controller: _codeController,
                readOnly: _isEdit,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Kode Course',
                  helperText: _isEdit
                      ? 'Kode bersifat read-only (kunci favorites)'
                      : null,
                  filled: _isEdit,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    _requiredField(value, 'Kode course wajib diisi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Kuliah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    _requiredField(value, 'Judul course wajib diisi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah SKS (Credits)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateCredits,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final status in Course.statuses)
                    DropdownMenuItem(
                      value: status,
                      child: Text(Course.labelOf(status)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                // Nonaktif selama menyimpan untuk mencegah submit ganda.
                onPressed: isSaving ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
