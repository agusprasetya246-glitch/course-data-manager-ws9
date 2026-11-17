// NIM: 2415051039 | Nama: Agus Prasetya
import 'package:flutter/material.dart';

/// Foto profil mahasiswa dengan bingkai putih (Home dan Profile).
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, this.radius = 35, this.borderWidth = 3});

  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundImage: const AssetImage('assets/images/profile.jpg'),
      ),
    );
  }
}
