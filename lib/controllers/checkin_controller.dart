import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkin.dart';
import '../services/checkin_repository.dart';
import '../utils/date_key.dart';
import 'auth_controller.dart';

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (ref) => CheckInRepository(),
);

/// 订阅某习惯的所有打卡（按日期降序）。
final checkInsProvider =
    NotifierProvider.family<CheckInsController, List<CheckIn>, String>(
  (habitId) => CheckInsController(habitId),
);

class CheckInsController extends Notifier<List<CheckIn>> {
  CheckInsController(this.habitId);
  final String habitId;

  @override
  List<CheckIn> build() {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return const <CheckIn>[];
    final repo = ref.read(checkInRepositoryProvider);
    final sub = repo.watchCheckIns(user.uid, habitId).listen((data) {
      state = data;
    });
    ref.onDispose(sub.cancel);
    return const <CheckIn>[];
  }

  Future<void> toggleToday() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    final repo = ref.read(checkInRepositoryProvider);
    final today = DateTime.now();
    final todayKey = DateKey.format(today);
    final has = state.any((c) => c.id == todayKey);
    if (has) {
      await repo.deleteCheckIn(uid: user.uid, habitId: habitId, date: today);
    } else {
      await repo.writeCheckIn(uid: user.uid, habitId: habitId, date: today);
    }
  }

  Future<void> deleteDay(DateTime day) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    await ref
        .read(checkInRepositoryProvider)
        .deleteCheckIn(uid: user.uid, habitId: habitId, date: day);
  }
}

/// 今日是否已打卡的便捷 selector。
final isTodayCheckedInProvider = Provider.family<bool, String>((ref, habitId) {
  final list = ref.watch(checkInsProvider(habitId));
  final todayKey = DateKey.today();
  return list.any((c) => c.id == todayKey);
});