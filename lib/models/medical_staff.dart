class MedicalStaff {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String specialty;
  final String department;
  final String status;
  final String phone;
  final String email;
  final int? hiredAt;
  final int createdAt;
  final int updatedAt;

  const MedicalStaff({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.specialty,
    required this.department,
    required this.status,
    required this.phone,
    required this.email,
    this.hiredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'specialty': specialty,
      'department_id': department,
      'phone': phone,
      'email': email,
      'status': status,
      'hired_at': hiredAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static MedicalStaff fromMap(Map<String, Object?> map) {
    return MedicalStaff(
      id: map['id'] as String,
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      department: map['department_id'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      status: map['status'] as String? ?? '',
      hiredAt: map['hired_at'] as int?,
      createdAt: map['created_at'] as int? ?? 0,
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }
}
