import '../utils/extensions.dart';
import 'checkin.dart';

class StreakStats {
  const StreakStats({
    required this.current,
    required this.longest,
    this.lastCheckInDate,
  });

  /// 当前连击天数。如果最后一次打卡是今天或昨天，仍算"streak 在跑"。
  final int current;

  /// 历史最长连击。
  final int longest;

  /// 最近一次打卡的本地日期（midnight）。
  final DateTime? lastCheckInDate;

  static const empty = StreakStats(current: 0, longest: 0);
}

/// 纯函数：从打卡记录计算 streak。给定"今天"和"打卡集合"（无需排序）。
class StreakCalculator {
  StreakCalculator._();

  static StreakStats compute(
    List<CheckIn> checkIns, {
    DateTime? today,
  }) {
    if (checkIns.isEmpty) return StreakStats.empty;
    final refDay = (today ?? DateTime.now()).dayOnly;

    // 把 date 去重后排序（升序）。
    final days = <DateTime>{}
      ..addAll(checkIns.map((c) => c.date.dayOnly));
    final sorted = days.toList()..sort();

    // 最长连击：扫描全部。
    int longest = 1;
    int runLen = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].daysBetween(sorted[i - 1]);
      if (gap == 1) {
        runLen += 1;
        if (runLen > longest) longest = runLen;
      } else if (gap > 1) {
        runLen = 1;
      }
      // gap == 0: 同日重复（去重后不会发生）
    }

    // 当前连击：只有最后一条是今天或昨天，streak 才"还在"。
    // 否则视为已断（current = 0）。
    DateTime? lastDay = sorted.last;
    int current = 0;
    if (lastDay.daysBetween(refDay) >= -1) {
      current = 1;
      DateTime cursor = lastDay;
      for (var i = sorted.length - 2; i >= 0; i--) {
        if (sorted[i].daysBetween(cursor) == -1) {
          current += 1;
          cursor = sorted[i];
        } else {
          break;
        }
      }
    }

    return StreakStats(
      current: current,
      longest: longest,
      lastCheckInDate: lastDay,
    );
  }
}

/// 辅助：给习惯页面用，给定"今天是否打卡 + streak"展示用文案。
String streakLabel(StreakStats stats) {
  if (stats.current == 0) return '尚未开始';
  if (stats.current == 1) return '已打卡 1 天';
  return '已连续 ${stats.current} 天';
}