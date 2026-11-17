// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_info.dart';
import '../providers/course_provider.dart';
import '../services/auth_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/student_avatar.dart';

/// Tab Home: sapaan, akun yang sedang login, dan ringkasan course.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _GreetingCard(),
        const SizedBox(height: 16),
        const _AccountCard(),
        const SizedBox(height: 32),
        Text(
          'Ringkasan Belajar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.library_books_rounded,
                color: Colors.orange.shade400,
                value: '${provider.courses.length}',
                label: 'Total Course',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                icon: Icons.favorite_rounded,
                color: Colors.pink.shade400,
                value: '${provider.favoriteCount}',
                label: 'Total Favorit',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const StudentAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo,',
                  style: TextStyle(
                    fontSize: 16,
                    color: onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  AppInfo.studentName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppInfo.studentId,
                    style: TextStyle(
                      fontSize: 12,
                      color: onPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Menampilkan akun Supabase Auth yang sedang login.
class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final email = AuthService.instance.currentUser?.email ?? '-';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: const Text('Login sebagai'),
        subtitle: Text(email),
      ),
    );
  }
}
