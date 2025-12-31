class Consultation {
  final String id;
  final String patientName;
  final String doctorName;
  final String reason;
  final String status;
  final String location;
  final int scheduledAt;
  final String notes;
  final int createdAt;
  final int updatedAt;

  const Consultation({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.reason,
    required this.status,
    required this.location,
    required this.scheduledAt,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'patient_name': patientName,
      'doctor_name': doctorName,
      'reason': reason,
      'status': status,
      'location': location,
      'scheduled_at': scheduledAt,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static Consultation fromMap(Map<String, Object?> map) {
    return Consultation(
      id: map['id'] as String,
      patientName: map['patient_name'] as String? ?? '',
      doctorName: map['doctor_name'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? '',
      location: map['location'] as String? ?? '',
      scheduledAt: map['scheduled_at'] as int? ?? 0,
      notes: map['notes'] as String? ?? '',
      createdAt: map['created_at'] as int? ?? 0,
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }
}
