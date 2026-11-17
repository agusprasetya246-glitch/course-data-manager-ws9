// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_info.dart';
import '../config/breakpoints.dart';
import '../providers/course_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/error_message.dart';
import 'course_form_page.dart';
import 'course_list_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _coursesTab = 1;

  static const _destinations = [
    (icon: Icons.home_outlined, selected: Icons.home_rounded, label: 'Home'),
    (
      icon: Icons.school_outlined,
      selected: Icons.school_rounded,
      label: 'Courses',
    ),
    (
      icon: Icons.favorite_outline,
      selected: Icons.favorite_rounded,
      label: 'Favorites',
    ),
    (
      icon: Icons.person_outline,
      selected: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  int _currentIndex = 0;
  final _pagesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CourseProvider>().loadCourses();
    });
  }

  void _selectTab(int index) => setState(() => _currentIndex = index);

  void _openAddForm() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CourseFormPage()));
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService.instance.logout();
    } catch (error) {
      showAppSnackBar(messenger, readableError(error), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = IndexedStack(
      key: _pagesKey,
      index: _currentIndex,
      children: const [
        HomePage(),
        CourseListPage(),
        FavoritesPage(),
        ProfilePage(),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = Breakpoints.isExpanded(constraints.maxWidth);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              AppInfo.appName,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_rounded),
                onPressed: _confirmLogout,
              ),
            ],
          ),
          floatingActionButton: _currentIndex == _coursesTab
              ? FloatingActionButton.extended(
                  onPressed: _openAddForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Course'),
                )
              : null,
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _selectTab,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final d in _destinations)
                          NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selected),
                            label: Text(d.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: pages),
                  ],
                )
              : pages,
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _selectTab,
                  destinations: [
                    for (final d in _destinations)
                      NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selected),
                        label: d.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}
