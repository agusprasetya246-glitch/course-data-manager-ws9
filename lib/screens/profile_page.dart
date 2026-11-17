// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

import '../config/app_info.dart';
import '../widgets/feedback_form.dart';
import '../widgets/student_avatar.dart';

/// Tab Profile: identitas mahasiswa dan form feedback.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 40, bottom: 24),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              const StudentAvatar(radius: 46, borderWidth: 4),
              const SizedBox(height: 16),
              Text(
                AppInfo.studentName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              Text(
                AppInfo.studentId,
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: FeedbackForm(),
            ),
          ),
        ),
      ],
    );
  }
}
