extension DateOnly on DateTime {
  DateTime get dayOnly => DateTime(year, month, day);
  bool isSameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
  int daysBetween(DateTime other) {
    final a = DateTime(year, month, day);
    final b = DateTime(other.year, other.month, other.day);
    return a.difference(b).inDays;
  }
}