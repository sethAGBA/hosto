class EmergencyVisit {
  final String id;
  final String patientName;
  final int age;
  final String reason;
  final String priority;
  final String status;
  final int arrivalAt;
  final String? boxLabel;
  final int createdAt;
  final int updatedAt;

  const EmergencyVisit({
    required this.id,
    required this.patientName,
    required this.age,
    required this.reason,
    required this.priority,
    required this.status,
    required this.arrivalAt,
    this.boxLabel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencyVisit.fromMap(Map<String, dynamic> map) {
    return EmergencyVisit(
      id: map['id'] as String,
      patientName: map['patient_name'] as String? ?? '',
      age: map['age'] is int ? map['age'] as int : int.tryParse('${map['age']}') ?? 0,
      reason: map['reason'] as String? ?? '',
      priority: map['priority'] as String? ?? '',
      status: map['status'] as String? ?? '',
      arrivalAt: map['arrival_at'] as int? ?? 0,
      boxLabel: map['box_label'] as String?,
      createdAt: map['created_at'] as int? ?? 0,
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_name': patientName,
      'age': age,
      'reason': reason,
      'priority': priority,
      'status': status,
      'arrival_at': arrivalAt,
      'box_label': boxLabel,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
