// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_info.dart';
import '../models/user_profile.dart';
import '../providers/course_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/stat_card.dart';

/// Tab Home: sapaan, data akun (nama, email, role), dan ringkasan course.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final error = profileProvider.error;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (profile != null) ...[
          _GreetingCard(profile: profile),
          const SizedBox(height: 16),
          _AccountCard(profile: profile),
        ] else if (error != null)
          _ProfileErrorCard(
            message: error,
            onRetry: () => context.read<ProfileProvider>().loadProfile(),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        const SizedBox(height: 32),
        Text(
          'Ringkasan Belajar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.library_books_rounded,
                color: Colors.orange.shade400,
                value: '${courseProvider.courses.length}',
                label: 'Total Course',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                icon: Icons.favorite_rounded,
                color: Colors.pink.shade400,
                value: '${courseProvider.favoriteCount}',
                label: 'Total Favorit',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          '${AppInfo.studentId} · ${AppInfo.studentName}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Sapaan dengan nama dan role pengguna yang sedang login.
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final name = profile.displayName;

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
          CircleAvatar(
            radius: 32,
            backgroundColor: onPrimary.withValues(alpha: 0.2),
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
            ),
          ),
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
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                    profile.roleLabel,
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

/// Informasi akun dari tabel profiles: Nama, Email, dan Role.
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Nama'),
            subtitle: Text(profile.name.trim().isEmpty ? '-' : profile.name),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(profile.email),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Role'),
            subtitle: Text('${profile.roleLabel} (${profile.role})'),
          ),
        ],
      ),
    );
  }
}

/// Ditampilkan kalau profile gagal dimuat, dengan tombol coba lagi.
class _ProfileErrorCard extends StatelessWidget {
  const _ProfileErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
