/// "YYYY-MM-DD" 日期键工具。一天 = 一个文档 ID。
class DateKey {
  DateKey._();

  /// 把任意 DateTime 归零到本地午夜。
  static DateTime dayOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// 把任意 DateTime 格式化为 "YYYY-MM-DD"（基于本地时区）。
  static String format(DateTime dt) {
    final d = dayOnly(dt);
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  /// 从 "YYYY-MM-DD" 解析出本地午夜 DateTime。
  static DateTime parse(String key) {
    final parts = key.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid dateKey: $key', key);
    }
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);
    return DateTime(y, m, d);
  }

  /// 今天的 dateKey。
  static String today() => format(DateTime.now());

  /// 昨天 / 明天 等相对日期。
  static String daysFromNow(int delta) =>
      format(DateTime.now().add(Duration(days: delta)));
}