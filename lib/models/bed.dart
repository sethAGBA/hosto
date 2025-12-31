class Bed {
  final String id;
  final String roomId;
  final String number;
  final String status;
  final int createdAt;
  final int updatedAt;

  const Bed({
    required this.id,
    required this.roomId,
    required this.number,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'bed_number': number,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static Bed fromMap(Map<String, Object?> map) {
    return Bed(
      id: map['id'] as String,
      roomId: map['room_id'] as String? ?? '',
      number: map['bed_number'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: map['created_at'] as int? ?? 0,
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }
}
