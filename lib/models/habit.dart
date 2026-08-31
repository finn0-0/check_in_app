import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.createdAt,
    required this.archived,
    required this.sortOrder,
    this.description,
    this.targetPerWeek,
    this.reminderTimeHHmm,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final DateTime createdAt;
  final bool archived;
  final int sortOrder;
  final String? description;
  final int? targetPerWeek;
  final String? reminderTimeHHmm;

  Habit copyWith({
    String? name,
    String? iconKey,
    int? colorValue,
    bool? archived,
    int? sortOrder,
    String? description,
    int? targetPerWeek,
    String? reminderTimeHHmm,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      description: description ?? this.description,
      targetPerWeek: targetPerWeek ?? this.targetPerWeek,
      reminderTimeHHmm: reminderTimeHHmm ?? this.reminderTimeHHmm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'archived': archived,
      'sortOrder': sortOrder,
      'targetPerWeek': targetPerWeek,
      'reminderTimeHHmm': reminderTimeHHmm,
    };
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    DateTime createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    } else {
      createdAt = DateTime.now();
    }
    return Habit(
      id: id,
      name: (map['name'] as String?) ?? '',
      iconKey: (map['iconKey'] as String?) ?? 'self_improvement',
      colorValue: (map['colorValue'] as num?)?.toInt() ?? 0xFF66BB6A,
      description: map['description'] as String?,
      createdAt: createdAt,
      archived: (map['archived'] as bool?) ?? false,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      targetPerWeek: (map['targetPerWeek'] as num?)?.toInt(),
      reminderTimeHHmm: map['reminderTimeHHmm'] as String?,
    );
  }
}