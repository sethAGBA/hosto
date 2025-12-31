class Patient {
  final String id;
  final String dossierNumber;
  final String firstName;
  final String lastName;
  final int? dateOfBirth;
  final String sex;
  final String phone;
  final String address;
  final String bloodGroup;
  final String allergies;
  final String emergencyContact;
  final String status;
  final String room;
  final String doctor;
  final String service;
  final String insurance;
  final int createdAt;
  final int updatedAt;

  const Patient({
    required this.id,
    required this.dossierNumber,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    required this.sex,
    required this.phone,
    required this.address,
    required this.bloodGroup,
    required this.allergies,
    required this.emergencyContact,
    required this.status,
    required this.room,
    required this.doctor,
    required this.service,
    required this.insurance,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'dossier_number': dossierNumber,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'sex': sex,
      'phone': phone,
      'address': address,
      'blood_group': bloodGroup,
      'allergies': allergies,
      'emergency_contact': emergencyContact,
      'status': status,
      'room': room,
      'doctor': doctor,
      'service': service,
      'insurance': insurance,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static Patient fromMap(Map<String, Object?> map) {
    return Patient(
      id: map['id'] as String,
      dossierNumber: map['dossier_number'] as String? ?? '',
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      dateOfBirth: map['date_of_birth'] as int?,
      sex: map['sex'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      bloodGroup: map['blood_group'] as String? ?? '',
      allergies: map['allergies'] as String? ?? '',
      emergencyContact: map['emergency_contact'] as String? ?? '',
      status: map['status'] as String? ?? '',
      room: map['room'] as String? ?? '',
      doctor: map['doctor'] as String? ?? '',
      service: map['service'] as String? ?? '',
      insurance: map['insurance'] as String? ?? '',
      createdAt: map['created_at'] as int? ?? 0,
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }
}
