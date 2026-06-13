class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.nik,
    this.phone,
    this.status,
    this.assignedZone,
  });

  final int id;
  final String name;
  final String role;
  final String? nik;
  final String? phone;
  final String? status;
  final Map<String, dynamic>? assignedZone;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '-',
      role: json['role'] as String? ?? 'jukir',
      nik: json['nik'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      assignedZone: json['assigned_zone'] as Map<String, dynamic>?,
    );
  }
}
