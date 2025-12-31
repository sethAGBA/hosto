class EmergencyBox {
  final String id;
  final String label;
  final String status;
  final String? patientName;
  final String priority;
  final int updatedAt;

  const EmergencyBox({
    required this.id,
    required this.label,
    required this.status,
    this.patientName,
    required this.priority,
    required this.updatedAt,
  });

  factory EmergencyBox.fromMap(Map<String, dynamic> map) {
    return EmergencyBox(
      id: map['id'] as String,
      label: map['label'] as String? ?? '',
      status: map['status'] as String? ?? '',
      patientName: map['patient_name'] as String?,
      priority: map['priority'] as String? ?? '',
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'status': status,
      'patient_name': patientName,
      'priority': priority,
      'updated_at': updatedAt,
    };
  }
}
