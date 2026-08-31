import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_check_in_app/models/checkin.dart';
import 'package:my_check_in_app/models/streak.dart';

CheckIn _ci(String dateKey) {
  final d = _parse(dateKey);
  return CheckIn(
    id: dateKey,
    date: d,
    createdAt: Timestamp.fromDate(d).toDate(),
  );
}

DateTime _parse(String key) {
  final p = key.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

void main() {
  final today = DateTime(2026, 8, 22);

  group('StreakCalculator', () {
    test('空历史 -> 全 0', () {
      final s = StreakCalculator.compute([], today: today);
      expect(s.current, 0);
      expect(s.longest, 0);
      expect(s.lastCheckInDate, isNull);
    });

    test('今日已打卡 -> current=1', () {
      final s = StreakCalculator.compute([_ci('2026-08-22')], today: today);
      expect(s.current, 1);
      expect(s.longest, 1);
    });

    test('三日连击到今日 -> current=3, longest=3', () {
      final list = [
        _ci('2026-08-22'),
        _ci('2026-08-21'),
        _ci('2026-08-20'),
      ];
      final s = StreakCalculator.compute(list, today: today);
      expect(s.current, 3);
      expect(s.longest, 3);
    });

    test('三日连击到昨日，今日未打卡 -> current 仍=3（streak 仍在）', () {
      final list = [
        _ci('2026-08-21'),
        _ci('2026-08-20'),
        _ci('2026-08-19'),
      ];
      final s = StreakCalculator.compute(list, today: today);
      expect(s.current, 3);
      expect(s.longest, 3);
    });

    test('断链（gap > 1）-> current 从最新段起算，longest 取历史最大', () {
      // 较老：3 天连击（8/16, 8/17, 8/18）
      // 然后断开
      // 最新：2 天连击（8/21, 8/22）
      final list = [
        _ci('2026-08-22'),
        _ci('2026-08-21'),
        _ci('2026-08-18'),
        _ci('2026-08-17'),
        _ci('2026-08-16'),
      ];
      final s = StreakCalculator.compute(list, today: today);
      expect(s.current, 2);
      expect(s.longest, 3);
    });

    test('longest 早于 current', () {
      // 早期 5 天连击（7/30, 7/31, 8/1, 8/2, 8/3），然后断开。
      // 然后 1 天打卡（8/22）
      final list = [
        _ci('2026-08-22'),
        _ci('2026-08-03'),
        _ci('2026-08-02'),
        _ci('2026-08-01'),
        _ci('2026-07-31'),
        _ci('2026-07-30'),
      ];
      final s = StreakCalculator.compute(list, today: today);
      expect(s.current, 1);
      expect(s.longest, 5);
    });

    test('重复日期去重幂等', () {
      final list = [
        _ci('2026-08-22'),
        _ci('2026-08-22'),
        _ci('2026-08-21'),
        _ci('2026-08-21'),
      ];
      final s = StreakCalculator.compute(list, today: today);
      expect(s.current, 2);
      expect(s.longest, 2);
    });

    test('最后一次打卡是两天前 -> current = 0（streak 已断）', () {
      final list = [
        _ci('2026-08-20'),
        _ci('2026-08-19'),
        _ci('2026-08-18'),
      ];
      final s = StreakCalculator.compute(list, today: today);
      expect(s.current, 0);
      expect(s.longest, 3);
    });
  });
}