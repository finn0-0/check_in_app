class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String habitNew = '/habit/new';
  static const String settings = '/settings';

  static String habitDetail(String habitId) => '/habit/$habitId';
  static String habitEdit(String habitId) => '/habit/$habitId/edit';
}