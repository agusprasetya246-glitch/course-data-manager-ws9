// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_info.dart';
import 'config/supabase_config.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/login_page.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  // Data source aktif. Untuk REST API: CourseApiService(baseUrl).
  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(repository)..loadCourses(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppInfo.appName,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const LoginPage(),
    );
  }
}
