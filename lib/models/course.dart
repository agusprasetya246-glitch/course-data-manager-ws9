// NIM: 2415051039 | Nama: Agus Prasetya

class Course {
  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
    this.ownerId,
  });

  static const List<String> statuses = ['planned', 'active', 'done'];

  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;

  final String? ownerId;

  /// Label status untuk ditampilkan di UI.
  static String labelOf(String status) {
    return switch (status) {
      'active' => 'Active',
      'done' => 'Done',
      _ => 'Planned',
    };
  }

  String get statusLabel => labelOf(status);

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: (json['id'] as num?)?.toInt(),
      code: json['code'] as String,
      title: json['title'] as String,
      credits: (json['credits'] as num).toInt(),
      status: (json['status'] as String?) ?? 'planned',
      ownerId: json['owner_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'title': title,
    'credits': credits,
    'status': status,
  };
}
