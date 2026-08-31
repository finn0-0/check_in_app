import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_check_in_app/models/habit.dart';

void main() {
  group('Habit codec', () {
    test('toMap/fromMap 往返所有字段', () {
      final original = Habit(
        id: 'h1',
        name: '早起',
        iconKey: 'wb_sunny',
        colorValue: 0xFF66BB6A,
        description: '每天 6 点起床',
        createdAt: DateTime(2026, 8, 1, 12),
        archived: false,
        sortOrder: 3,
        targetPerWeek: 5,
        reminderTimeHHmm: '06:00',
      );
      final map = original.toMap();
      final back = Habit.fromMap('h1', map);
      expect(back.id, original.id);
      expect(back.name, original.name);
      expect(back.iconKey, original.iconKey);
      expect(back.colorValue, original.colorValue);
      expect(back.description, original.description);
      expect(back.createdAt, original.createdAt);
      expect(back.archived, original.archived);
      expect(back.sortOrder, original.sortOrder);
      expect(back.targetPerWeek, original.targetPerWeek);
      expect(back.reminderTimeHHmm, original.reminderTimeHHmm);
    });

    test('fromMap 缺失 createdAt 时回退到 now', () {
      final map = {
        'name': '跑步',
        'iconKey': 'directions_run',
        'colorValue': 0xFFEF5350,
        'archived': true,
        'sortOrder': 7,
      };
      final habit = Habit.fromMap('h2', map);
      expect(habit.id, 'h2');
      expect(habit.name, '跑步');
      expect(habit.archived, true);
      expect(habit.description, isNull);
      expect(habit.targetPerWeek, isNull);
      expect(habit.reminderTimeHHmm, isNull);
    });

    test('fromMap 接受 Timestamp 类型 createdAt', () {
      final ts = Timestamp.fromDate(DateTime(2026, 8, 22));
      final habit = Habit.fromMap('h3', {
        'name': '读书',
        'iconKey': 'menu_book',
        'colorValue': 0xFF42A5F5,
        'archived': false,
        'sortOrder': 0,
        'createdAt': ts,
      });
      expect(habit.createdAt, DateTime(2026, 8, 22));
    });

    test('toMap 写入 Timestamp 而非裸 DateTime', () {
      final habit = Habit(
        id: 'h4',
        name: '冥想',
        iconKey: 'spa',
        colorValue: 0xFF7E57C2,
        createdAt: DateTime(2026, 7, 1),
        archived: false,
        sortOrder: 0,
      );
      final map = habit.toMap();
      expect(map['createdAt'], isA<Timestamp>());
    });
  });
}