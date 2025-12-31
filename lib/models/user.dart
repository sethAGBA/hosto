enum UserRole {
  admin,
  medecin,
  infirmier,
  pharmacien,
  comptable,
  secretaire,
  laborantin,
  radiologue,
  staff,
}

class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final UserRole role;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
    required this.isActive,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'role': role.name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_login': lastLogin.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  static User fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      passwordHash: map['password_hash'] as String? ?? '',
      role: _roleFromString(map['role'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int?) ?? 0),
      lastLogin: DateTime.fromMillisecondsSinceEpoch((map['last_login'] as int?) ?? 0),
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }

  static UserRole _roleFromString(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'medecin':
        return UserRole.medecin;
      case 'infirmier':
        return UserRole.infirmier;
      case 'pharmacien':
        return UserRole.pharmacien;
      case 'comptable':
        return UserRole.comptable;
      case 'secretaire':
        return UserRole.secretaire;
      case 'laborantin':
        return UserRole.laborantin;
      case 'radiologue':
        return UserRole.radiologue;
      case 'staff':
      default:
        return UserRole.staff;
    }
  }
}
