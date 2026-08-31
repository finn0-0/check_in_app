import 'package:flutter/material.dart';

/// 习惯可用的 Material icon 注册表。
/// key 持久化到 iconKey 字段，重命名 / 重排 icon 不会影响已存数据。
class HabitIcon {
  const HabitIcon({required this.key, required this.icon});

  final String key;
  final IconData icon;
}

class HabitIcons {
  HabitIcons._();

  static const List<HabitIcon> all = <HabitIcon>[
    HabitIcon(key: 'self_improvement', icon: Icons.self_improvement),
    HabitIcon(key: 'fitness_center', icon: Icons.fitness_center),
    HabitIcon(key: 'menu_book', icon: Icons.menu_book),
    HabitIcon(key: 'directions_run', icon: Icons.directions_run),
    HabitIcon(key: 'water_drop', icon: Icons.water_drop),
    HabitIcon(key: 'bedtime', icon: Icons.bedtime),
    HabitIcon(key: 'restaurant', icon: Icons.restaurant),
    HabitIcon(key: 'medication', icon: Icons.medication),
    HabitIcon(key: 'code', icon: Icons.code),
    HabitIcon(key: 'brush', icon: Icons.brush),
    HabitIcon(key: 'music_note', icon: Icons.music_note),
    HabitIcon(key: 'pets', icon: Icons.pets),
    HabitIcon(key: 'smoke_free', icon: Icons.smoke_free),
    HabitIcon(key: 'savings', icon: Icons.savings),
    HabitIcon(key: 'eco', icon: Icons.eco),
    HabitIcon(key: 'spa', icon: Icons.spa),
    HabitIcon(key: 'phone_disabled', icon: Icons.phone_disabled),
    HabitIcon(key: 'school', icon: Icons.school),
    HabitIcon(key: 'favorite', icon: Icons.favorite),
    HabitIcon(key: 'wb_sunny', icon: Icons.wb_sunny),
  ];

  static IconData byKey(String key) {
    for (final entry in all) {
      if (entry.key == key) return entry.icon;
    }
    return Icons.check_circle_outline;
  }

  static int get defaultIndex => 0;
}