class Room {
  final String id;
  final String number;
  final String floor;
  final String wing;
  final String type;
  final int bedCount;
  final String status;
  final double pricePerDay;
  final int createdAt;
  final int updatedAt;

  const Room({
    required this.id,
    required this.number,
    required this.floor,
    required this.wing,
    required this.type,
    required this.bedCount,
    required this.status,
    required this.pricePerDay,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'room_number': number,
      'floor': floor,
      'wing': wing,
      'room_type': type,
      'bed_count': bedCount,
      'status': status,
      'price_per_day': pricePerDay,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static Room fromMap(Map<String, Object?> map) {
    return Room(
      id: map['id'] as String,
      number: map['room_number'] as String? ?? '',
      floor: map['floor'] as String? ?? '',
      wing: map['wing'] as String? ?? '',
      type: map['room_type'] as String? ?? '',
      bedCount: map['bed_count'] as int? ?? 0,
      status: map['status'] as String? ?? '',
      pricePerDay: (map['price_per_day'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] as int? ?? 0,
      updatedAt: map['updated_at'] as int? ?? 0,
    );
  }
}
