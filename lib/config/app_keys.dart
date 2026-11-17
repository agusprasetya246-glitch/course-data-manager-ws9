// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

/// Key global agar navigasi dan SnackBar bisa dipanggil dari luar widget,
/// misalnya dari listener auth (Tahap 2) dan handler notifikasi (Tahap 10).
final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();
