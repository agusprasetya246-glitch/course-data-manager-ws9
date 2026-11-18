// NIM: 2415051039 | Nama: Agus Prasetya

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final String id;
  final String email;
  final String name;
  final String role;

  static const signUpRoles = ['seeker', 'owner'];

  static String labelOf(String role) => switch (role) {
    'owner' => 'Pengajar',
    'admin' => 'Admin',
    _ => 'Mahasiswa',
  };

  String get roleLabel => labelOf(role);
  bool get isSeeker => role == 'seeker';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';

  String get displayName => name.trim().isEmpty ? email : name.trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'seeker',
    );
  }
}
