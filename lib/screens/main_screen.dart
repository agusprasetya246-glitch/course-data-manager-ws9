// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_info.dart';
import '../config/breakpoints.dart';
import '../providers/course_provider.dart';
import '../providers/profile_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/error_message.dart';
import '../widgets/role_guard.dart';
import 'course_form_page.dart';
import 'course_list_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'security_test_page.dart';
import '../services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _coursesTab = 1;
  static const int _myCoursesTab = 4;

  static const _baseDestinations = [
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

  static const _myCoursesDestination = (
    icon: Icons.folder_shared_outlined,
    selected: Icons.folder_shared,
    label: 'My Courses',
  );

  int _currentIndex = 0;

  final _pagesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadProfile();
      context.read<CourseProvider>().loadCourses();
      _setupNotifications();
    });
  }

  Future<void> _setupNotifications() => NotificationService.instance.init();

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
      await NotificationService.instance.unregisterDevice();
      await AuthService.instance.logout();
    } catch (error) {
      showAppSnackBar(messenger, readableError(error), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = context.watch<ProfileProvider>();
    final canManage = access.canAddCourse;
    final roleLabel = access.profile?.roleLabel;

    final destinations = [
      ..._baseDestinations,
      if (canManage) _myCoursesDestination,
    ];
    // Jaga-jaga kalau tab My Courses hilang (misalnya role berubah).
    final index = _currentIndex < destinations.length ? _currentIndex : 0;
    final showAddButton = index == _coursesTab || index == _myCoursesTab;

    final pages = IndexedStack(
      key: _pagesKey,
      index: index,
      children: [
        const HomePage(),
        const CourseListPage(),
        const FavoritesPage(),
        const ProfilePage(),
        if (canManage) const CourseListPage(onlyMine: true),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = Breakpoints.isExpanded(constraints.maxWidth);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppInfo.appName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                if (roleLabel != null)
                  Text(
                    'Masuk sebagai $roleLabel',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
            actions: [
              // Hanya untuk pengujian Praktik 6; tidak muncul di build release.
              if (kDebugMode)
                IconButton(
                  tooltip: 'Uji keamanan RLS',
                  icon: const Icon(Icons.security_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SecurityTestPage()),
                  ),
                ),
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_rounded),
                onPressed: _confirmLogout,
              ),
            ],
          ),
          // Tombol Tambah hanya untuk Pengajar dan Admin.
          floatingActionButton: showAddButton
              ? RoleGuard(
                  allowed: const ['owner', 'admin'],
                  child: FloatingActionButton.extended(
                    onPressed: _openAddForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Course'),
                  ),
                )
              : null,
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: _selectTab,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final d in destinations)
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
                  selectedIndex: index,
                  onDestinationSelected: _selectTab,
                  destinations: [
                    for (final d in destinations)
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
