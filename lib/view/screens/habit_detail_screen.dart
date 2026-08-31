import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controllers/checkin_controller.dart';
import '../../controllers/habit_list_controller.dart';
import '../../l10n/strings_zh.dart';
import '../../models/habit.dart';
import '../../models/streak.dart';
import '../../routing/route_paths.dart';
import '../../theme/habit_palette.dart';
import '../widgets/history_list_tile.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider);
    final checkIns = ref.watch(checkInsProvider(habitId));
    final habit = habits.maybeWhen(
      data: (list) => list.cast<Habit?>().firstWhere(
            (h) => h?.id == habitId,
            orElse: () => null,
          ),
      orElse: () => null,
    );

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(S.habitDetailTitle)),
        body: const Center(child: Text('习惯不存在')),
      );
    }
    final color = HabitPalette.byValue(habit.colorValue);
    final stats = StreakCalculator.compute(checkIns, today: DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name.isEmpty ? S.habitDetailTitle : habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RoutePaths.habitEdit(habitId)),
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => _confirmArchive(context, ref, habit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (habit.description != null && habit.description!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(habit.description!),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _StatTile(
                label: S.currentStreak,
                value: stats.current,
                suffix: S.daysUnit,
                color: color,
              ),
              const SizedBox(width: 12),
              _StatTile(
                label: S.longestStreak,
                value: stats.longest,
                suffix: S.daysUnit,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: DateTime.now(),
                locale: 'zh_CN',
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableGestures: AvailableGestures.horizontalSwipe,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: color.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  final key = _ymd(day);
                  return checkIns.where((c) => c.id == key).toList();
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            S.historySection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (checkIns.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  '还没有打卡记录',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...checkIns.map((c) => HistoryListTile(
                  date: c.date,
                  note: c.note,
                  onDelete: () => ref
                      .read(checkInsProvider(habitId).notifier)
                      .deleteDay(c.date),
                )),
        ],
      ),
    );
  }

  static String _ymd(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('归档这个习惯？'),
        content: const Text('归档后可在「设置」中恢复。历史打卡会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.archiveHabit),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(habitActionsProvider.notifier).archive(habit.id);
      if (context.mounted) context.pop();
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
  });

  final String label;
  final int value;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(suffix),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}