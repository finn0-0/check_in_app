import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/checkin_controller.dart';
import '../../controllers/habit_list_controller.dart';
import '../../l10n/strings_zh.dart';
import '../../models/habit.dart';
import '../../models/streak.dart';
import '../../routing/route_paths.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/habit_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RoutePaths.settings),
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(S.loadingError, textAlign: TextAlign.center),
          ),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return EmptyStateView(
              title: S.emptyHomeTitle,
              hint: S.emptyHomeHint,
              icon: Icons.checklist_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: habits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final h = habits[i];
              return _HabitCardWithStreak(habit: h);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.habitNew),
        icon: const Icon(Icons.add),
        label: const Text(S.fabNewHabit),
      ),
    );
  }
}

class _HabitCardWithStreak extends ConsumerWidget {
  const _HabitCardWithStreak({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(checkInsProvider(habit.id));
    final stats = StreakCalculator.compute(
      list,
      today: DateTime.now(),
    );
    return HabitCard(
      habit: habit,
      streakDays: stats.current,
      onTap: () => context.push(RoutePaths.habitDetail(habit.id)),
    );
  }
}