// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../utils/error_message.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._service);

  final ProfileService _service;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get role => _profile?.role ?? 'seeker';

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getMyProfile();
      if (_profile == null) {
        _error = 'Profile akun ini belum ada di database.';
      }
    } catch (e) {
      _error = readableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
