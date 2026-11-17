// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

import '../config/app_info.dart';
import '../config/breakpoints.dart';
import 'course_form_page.dart';
import 'course_list_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

/// Kerangka navigasi: NavigationBar di layar sempit, NavigationRail di
/// layar lebar (>= 840 dp). Isi tiap tab ada di file screen masing-masing.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _coursesTab = 1;

  static const _destinations = [
    (icon: Icons.home_outlined, selected: Icons.home_rounded, label: 'Home'),
    (icon: Icons.school_outlined, selected: Icons.school_rounded, label: 'Courses'),
    (icon: Icons.favorite_outline, selected: Icons.favorite_rounded, label: 'Favorites'),
    (icon: Icons.person_outline, selected: Icons.person_rounded, label: 'Profile'),
  ];

  int _currentIndex = 0;

  // GlobalKey menjaga state tiap tab (misalnya posisi scroll) saat layout
  // berganti antara NavigationBar dan NavigationRail ketika layar diputar.
  final _pagesKey = GlobalKey();

  void _selectTab(int index) => setState(() => _currentIndex = index);

  void _openAddForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CourseFormPage()),
    );
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
