import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_key.dart';

/// 一日一条打卡。文档 ID == dateKey（"YYYY-MM-DD"）。
class CheckIn {
  const CheckIn({
    required this.id,
    required this.date,
    required this.createdAt,
    this.note,
    this.moodScore,
  });

  final String id; // = dateKey "YYYY-MM-DD"
  final DateTime date; // 本地午夜
  final DateTime createdAt;
  final String? note;
  final int? moodScore;

  String get dateKey => id;

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'note': note,
      'moodScore': moodScore,
    };
  }

  factory CheckIn.fromMap(String id, Map<String, dynamic> map) {
    final dateRaw = map['date'];
    DateTime date;
    if (dateRaw is Timestamp) {
      date = DateTime(dateRaw.toDate().year, dateRaw.toDate().month, dateRaw.toDate().day);
    } else if (dateRaw is DateTime) {
      date = DateTime(dateRaw.year, dateRaw.month, dateRaw.day);
    } else {
      date = DateKey.parse(id);
    }
    final created = map['createdAt'];
    DateTime createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    } else {
      createdAt = DateTime.now();
    }
    return CheckIn(
      id: id,
      date: date,
      createdAt: createdAt,
      note: map['note'] as String?,
      moodScore: (map['moodScore'] as num?)?.toInt(),
    );
  }
}