import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../services/habit_repository.dart';
import 'auth_controller.dart';

/// Provider：注入 HabitRepository 实例。
final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(),
);

/// 当前用户的活跃习惯流。未登录时为空 list。
final activeHabitsProvider =
    StreamNotifierProvider<ActiveHabitsController, List<Habit>>(
  ActiveHabitsController.new,
);

class ActiveHabitsController extends StreamNotifier<List<Habit>> {
  @override
  Stream<List<Habit>> build() {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return Stream.value(const <Habit>[]);
    final repo = ref.read(habitRepositoryProvider);
    return repo.watchActiveHabits(user.uid);
  }
}

/// 已归档习惯流（Settings 用）。
final archivedHabitsProvider =
    StreamNotifierProvider<ArchivedHabitsController, List<Habit>>(
  ArchivedHabitsController.new,
);

class ArchivedHabitsController extends StreamNotifier<List<Habit>> {
  @override
  Stream<List<Habit>> build() {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return Stream.value(const <Habit>[]);
    final repo = ref.read(habitRepositoryProvider);
    return repo.watchArchivedHabits(user.uid);
  }
}

/// 习惯变更操作的 facade — 归档 / 恢复 / 删除。
final habitActionsProvider =
    NotifierProvider<HabitActionsController, void>(HabitActionsController.new);

class HabitActionsController extends Notifier<void> {
  @override
  void build() {}

  Future<void> archive(String habitId) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    await ref.read(habitRepositoryProvider).setArchived(user.uid, habitId, true);
  }

  Future<void> restore(String habitId) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    await ref.read(habitRepositoryProvider).setArchived(user.uid, habitId, false);
  }

  Future<void> delete(String habitId) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    await ref.read(habitRepositoryProvider).delete(user.uid, habitId);
  }
}