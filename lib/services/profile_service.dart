// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class ProfileService {
  ProfileService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _table = 'profiles';

  Future<UserProfile?> getMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from(_table)
        .select()
        .eq('id', user.id)
        .maybeSingle();
    return data == null ? null : UserProfile.fromJson(data);
  }
}
