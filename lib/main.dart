// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_info.dart';
import 'config/app_keys.dart';
import 'config/supabase_config.dart';
import 'providers/course_provider.dart';
import 'providers/profile_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/login_page.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';
import 'services/profile_service.dart';
import 'utils/app_snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );
  _listenAuthChanges();

  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(ProfileService()),
        ),
        ChangeNotifierProvider(create: (_) => CourseProvider(repository)),
      ],
      child: const MyApp(),
    ),
  );
}

void _listenAuthChanges() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint('Auth event: ${data.event}');
    if (data.event != AuthChangeEvent.signedOut) return;

    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.read<ProfileProvider>().clear();
      context.read<CourseProvider>().clear();
    }
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );

    final messenger = messengerKey.currentState;
    if (messenger != null) showAppSnackBar(messenger, 'Anda telah logout');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      title: AppInfo.appName,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: AuthService.instance.isLoggedIn
          ? const MainScreen()
          : const LoginPage(),
    );
  }
}
