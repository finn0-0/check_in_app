import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/checkin.dart';
import '../utils/date_key.dart';

class CheckInRepository {
  CheckInRepository({FirebaseFirestore? firestore})
      : _fs = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> _col(
    String uid,
    String habitId,
  ) =>
      _fs
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(habitId)
          .collection('checkins');

  /// 订阅某习惯的所有打卡，按 date 降序。
  Stream<List<CheckIn>> watchCheckIns(String uid, String habitId) {
    final query = _col(uid, habitId).orderBy('date', descending: true);
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => CheckIn.fromMap(d.id, d.data())).toList(),
        );
  }

  /// 在某日打卡。幂等：同日重复 set 只覆盖字段，不创建重复文档。
  Future<void> writeCheckIn({
    required String uid,
    required String habitId,
    required DateTime date,
    String? note,
    int? moodScore,
  }) async {
    final dayOnly = DateKey.dayOnly(date);
    final doc = _col(uid, habitId).doc(DateKey.format(dayOnly));
    await doc.set({
      'date': Timestamp.fromDate(dayOnly),
      'createdAt': FieldValue.serverTimestamp(),
      'note': note,
      'moodScore': moodScore,
    }, SetOptions(merge: true));
  }

  /// 删除某日打卡。幂等。
  Future<void> deleteCheckIn({
    required String uid,
    required String habitId,
    required DateTime date,
  }) async {
    final doc = _col(uid, habitId).doc(DateKey.format(date));
    await doc.delete();
  }
}