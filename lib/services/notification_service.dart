// NIM: 2415051039 | Nama: Agus Prasetya
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_keys.dart';
import '../firebase_options.dart';
import '../utils/app_snackbar.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[BACKGROUND] Notification received');
  debugPrint('[BACKGROUND] title: ${message.notification?.title}');
  debugPrint('[BACKGROUND] body : ${message.notification?.body}');
  debugPrint('[BACKGROUND] data : ${message.data}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _tokenTable = 'device_tokens';

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  SupabaseClient get _supabase => Supabase.instance.client;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  final ValueNotifier<AuthorizationStatus?> permissionStatus = ValueNotifier(
    null,
  );

  final ValueNotifier<String?> currentToken = ValueNotifier(null);

  Future<void> init() async {
    await requestPermission();
    await registerDevice();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundSub ??= FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    debugPrint('Notification listener aktif');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notifikasi';
    final body = message.notification?.body ?? '';

    debugPrint('[FOREGROUND] Notification received');
    debugPrint('[FOREGROUND] title: $title');
    debugPrint('[FOREGROUND] body : $body');
    debugPrint('[FOREGROUND] data : ${message.data}');

    final messenger = messengerKey.currentState;
    if (messenger != null) {
      showNotificationSnackBar(messenger, title: title, body: body);
    }
  }

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final status = settings.authorizationStatus;
    permissionStatus.value = status;
    debugPrint('Notification permission: ${status.name}');
    return status;
  }

  Future<String?> getToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      currentToken.value = token;
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Gagal mengambil FCM token: $e');
      return null;
    }
  }

  Future<void> registerDevice() async {
    final token = await getToken();
    if (token != null) await saveTokenToSupabase(token);

    // ignore: deprecated_member_use
    _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui');
      currentToken.value = newToken;
      saveTokenToSupabase(newToken);
    });
  }

  Future<void> saveTokenToSupabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from(_tokenTable).upsert({
        'token': token,
        'user_id': user.id,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('FCM token tersimpan di $_tokenTable');
    } catch (e) {
      debugPrint('Gagal menyimpan FCM token: $e');
    }
  }

  Future<void> unregisterDevice() async {
    final token = currentToken.value;
    if (token == null) return;

    try {
      await _supabase.from(_tokenTable).delete().eq('token', token);
      debugPrint('FCM token dihapus dari $_tokenTable');
    } catch (e) {
      debugPrint('Gagal menghapus FCM token: $e');
    }
  }

  static String mask(String token) {
    if (token.length <= 20) return token;
    return '${token.substring(0, 12)}…${token.substring(token.length - 6)}';
  }

  static bool isAllowed(AuthorizationStatus? status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  static String labelOf(AuthorizationStatus? status) {
    return switch (status) {
      null => 'Belum diperiksa',
      AuthorizationStatus.authorized => 'Diizinkan (authorized)',
      AuthorizationStatus.provisional => 'Sementara (provisional)',
      AuthorizationStatus.denied => 'Ditolak (denied)',
      AuthorizationStatus.deniedPermanently =>
        'Ditolak permanen (deniedPermanently)',
      AuthorizationStatus.notDetermined => 'Belum ditentukan (notDetermined)',
    };
  }
}
