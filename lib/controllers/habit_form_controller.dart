import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../models/habit_icon.dart';
import '../theme/habit_palette.dart';
import 'auth_controller.dart';
import 'habit_list_controller.dart';

class HabitFormState {
  const HabitFormState({
    required this.name,
    required this.iconKey,
    required this.colorValue,
    this.description,
    this.targetPerWeek,
    this.reminderTimeHHmm,
    this.busy = false,
    this.error,
  });

  final String name;
  final String iconKey;
  final int colorValue;
  final String? description;
  final int? targetPerWeek;
  final String? reminderTimeHHmm;
  final bool busy;
  final String? error;

  HabitFormState copyWith({
    String? name,
    String? iconKey,
    int? colorValue,
    String? description,
    int? targetPerWeek,
    String? reminderTimeHHmm,
    bool? busy,
    String? error,
    bool clearError = false,
  }) {
    return HabitFormState(
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      description: description ?? this.description,
      targetPerWeek: targetPerWeek ?? this.targetPerWeek,
      reminderTimeHHmm: reminderTimeHHmm ?? this.reminderTimeHHmm,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static HabitFormState empty() => HabitFormState(
        name: '',
        iconKey: HabitIcons.all[HabitIcons.defaultIndex].key,
        colorValue:
            HabitPalette.colors[HabitPalette.defaultIndex].toARGB32(),
      );
}

/// 创建/编辑习惯的 form controller。
/// 传 null = 创建模式，传 habitId = 编辑模式（外部调用 loadFor 切换）。
final habitFormControllerProvider =
    AsyncNotifierProvider<HabitFormController, HabitFormState>(
  HabitFormController.new,
);

class HabitFormController extends AsyncNotifier<HabitFormState> {
  String? _habitId;
  Habit? _original;

  @override
  Future<HabitFormState> build() async {
    _habitId = null;
    _original = null;
    return HabitFormState.empty();
  }

  /// 编辑模式：预填现有习惯。
  Future<void> loadFor(String habitId) async {
    state = const AsyncLoading();
    _habitId = habitId;
    final user = ref.read(authControllerProvider).value;
    if (user == null) {
      state = AsyncError('未登录', StackTrace.current);
      return;
    }
    final repo = ref.read(habitRepositoryProvider);
    final habit = await repo.getById(user.uid, habitId);
    if (habit == null) {
      state = AsyncError('习惯不存在', StackTrace.current);
      return;
    }
    _original = habit;
    state = AsyncData(HabitFormState(
      name: habit.name,
      iconKey: habit.iconKey,
      colorValue: habit.colorValue,
      description: habit.description,
      targetPerWeek: habit.targetPerWeek,
      reminderTimeHHmm: habit.reminderTimeHHmm,
    ));
  }

  void setName(String v) => _update((s) => s.copyWith(name: v, clearError: true));
  void setIcon(String key) => _update((s) => s.copyWith(iconKey: key));
  void setColor(int argb) => _update((s) => s.copyWith(colorValue: argb));
  void setDescription(String? v) =>
      _update((s) => s.copyWith(description: v));
  void setTargetPerWeek(int? v) =>
      _update((s) => s.copyWith(targetPerWeek: v));

  void _update(HabitFormState Function(HabitFormState) fn) {
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(fn(cur));
  }

  /// 返回新习惯/更新后的 habit id；失败抛异常。
  Future<String> submit() async {
    final cur = state.value;
    if (cur == null) throw StateError('Form not initialized');
    if (cur.name.trim().isEmpty) {
      _update((s) => s.copyWith(error: '请填写习惯名称'));
      throw StateError('name required');
    }
    _update((s) => s.copyWith(busy: true, clearError: true));
    final user = ref.read(authControllerProvider).value;
    if (user == null) {
      _update((s) => s.copyWith(busy: false, error: '未登录'));
      throw StateError('not signed in');
    }
    final repo = ref.read(habitRepositoryProvider);
    try {
      if (_habitId == null || _original == null) {
        final id = await repo.create(
          uid: user.uid,
          name: cur.name.trim(),
          iconKey: cur.iconKey,
          colorValue: cur.colorValue,
          description: cur.description?.trim().isEmpty ?? true
              ? null
              : cur.description!.trim(),
          targetPerWeek: cur.targetPerWeek,
          reminderTimeHHmm: cur.reminderTimeHHmm,
        );
        _update((s) => s.copyWith(busy: false));
        return id;
      } else {
        final updated = _original!.copyWith(
          name: cur.name.trim(),
          iconKey: cur.iconKey,
          colorValue: cur.colorValue,
          description: cur.description?.trim().isEmpty ?? true
              ? null
              : cur.description!.trim(),
          targetPerWeek: cur.targetPerWeek,
          reminderTimeHHmm: cur.reminderTimeHHmm,
        );
        await repo.update(user.uid, updated);
        _update((s) => s.copyWith(busy: false));
        return _habitId!;
      }
    } catch (e) {
      _update((s) => s.copyWith(busy: false, error: e.toString()));
      rethrow;
    }
  }
}