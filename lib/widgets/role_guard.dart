// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({super.key, required this.allowed, required this.child});

  final List<String> allowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final role = context.select<ProfileProvider, String>((p) => p.role);
    return allowed.contains(role) ? child : const SizedBox.shrink();
  }
}
