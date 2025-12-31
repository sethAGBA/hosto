class ExamAnalysis {
  final String id;
  final String patientName;
  final String requesterName;
  final String examType;
  final String priority;
  final String status;
  final int scheduledAt;
  final int? completedAt;
  final String resultSummary;
  final String notes;
  final int createdAt;
  final int updatedAt;

  const ExamAnalysis({
    required this.id,
    required this.patientName,
    required this.requesterName,
    required this.examType,
    required this.priority,
    required this.status,
    required this.scheduledAt,
    this.completedAt,
    required this.resultSummary,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamAnalysis.fromMap(Map<String, dynamic> map) {
    final scheduled = map['scheduled_at'] as int?;
    final requested = map['requested_at'] as int?;
    return ExamAnalysis(
      id: map['id'] as String,
      patientName: map['patient_id'] as String? ?? '',
      requesterName: map['requester_id'] as String? ?? '',
      examType: map['exam_type'] as String? ?? '',
      priority: map['priority'] as String? ?? '',
      status: map['status'] as String? ?? '',
      scheduledAt: scheduled ?? requested ?? 0,
      completedAt: map['completed_at'] as int?,
      resultSummary: map['result_summary'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: map['created_at'] as int? ?? 0,
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientName,
      'requester_id': requesterName,
      'exam_type': examType,
      'priority': priority,
      'status': status,
      'scheduled_at': scheduledAt,
      'requested_at': scheduledAt,
      'completed_at': completedAt,
      'result_summary': resultSummary,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
