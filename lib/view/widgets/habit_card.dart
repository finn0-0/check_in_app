import 'package:flutter/material.dart';

import '../../models/habit.dart';
import '../../models/habit_icon.dart';
import '../../theme/habit_palette.dart';
import 'streak_chip.dart';
import 'today_checkin_button.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.streakDays,
    required this.onTap,
  });

  final Habit habit;
  final int streakDays;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = HabitPalette.byValue(habit.colorValue);
    final icon = HabitIcons.byKey(habit.iconKey);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name.isEmpty ? '未命名' : habit.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        StreakChip(days: streakDays, color: color),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TodayCheckInButton(habitId: habit.id, color: color),
            ],
          ),
        ),
      ),
    );
  }
}