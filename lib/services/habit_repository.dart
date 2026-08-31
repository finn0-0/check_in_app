import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit.dart';

class HabitRepository {
  HabitRepository({FirebaseFirestore? firestore})
      : _fs = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.collection('users').doc(uid).collection('habits');

  /// 订阅某个用户的所有习惯，按 sortOrder 升序，再按 createdAt 升序。
  Stream<List<Habit>> watchHabits(String uid) {
    final query = _col(uid).orderBy('archived').orderBy('sortOrder');
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => Habit.fromMap(d.id, d.data())).toList(),
        );
  }

  /// 仅订阅未归档的习惯（Home 用）。
  Stream<List<Habit>> watchActiveHabits(String uid) {
    return watchHabits(uid)
        .map((list) => list.where((h) => !h.archived).toList());
  }

  /// 仅订阅已归档的（Settings 用）。
  Stream<List<Habit>> watchArchivedHabits(String uid) {
    return watchHabits(uid)
        .map((list) => list.where((h) => h.archived).toList());
  }

  Future<Habit?> getById(String uid, String habitId) async {
    final doc = await _col(uid).doc(habitId).get();
    if (!doc.exists) return null;
    return Habit.fromMap(doc.id, doc.data()!);
  }

  /// 创建新习惯。返回 doc id。
  Future<String> create({
    required String uid,
    required String name,
    required String iconKey,
    required int colorValue,
    String? description,
    int? targetPerWeek,
    String? reminderTimeHHmm,
  }) async {
    final col = _col(uid);
    final existing = await col.count().get();
    final sortOrder = existing.count ?? 0;
    final habit = Habit(
      id: '',
      name: name,
      iconKey: iconKey,
      colorValue: colorValue,
      description: description,
      createdAt: DateTime.now(),
      archived: false,
      sortOrder: sortOrder,
      targetPerWeek: targetPerWeek,
      reminderTimeHHmm: reminderTimeHHmm,
    );
    final ref = await col.add(habit.toMap());
    return ref.id;
  }

  Future<void> update(String uid, Habit habit) async {
    await _col(uid).doc(habit.id).set(habit.toMap(), SetOptions(merge: true));
  }

  Future<void> setArchived(String uid, String habitId, bool archived) async {
    await _col(uid).doc(habitId).update({'archived': archived});
  }

  Future<void> delete(String uid, String habitId) async {
    await _col(uid).doc(habitId).delete();
  }
}