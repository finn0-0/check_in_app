/// 用户可见中文字符串集中处。
/// v1 先用 const class；未来切到 flutter_localizations + .arb 时机械替换。
class S {
  S._();

  // App
  static const String appTitle = '习惯打卡';

  // Splash
  static const String splashTitle = '习惯打卡';

  // Login
  static const String loginTitle = '登录';
  static const String registerTitle = '注册';
  static const String emailLabel = '邮箱';
  static const String passwordLabel = '密码';
  static const String loginSubmit = '登录';
  static const String registerSubmit = '创建账号并登录';
  static const String toggleToRegister = '没有账号？立即注册';
  static const String toggleToLogin = '已有账号？去登录';
  static const String authErrorGeneric = '登录失败，请稍后再试';

  // Home
  static const String homeTitle = '今日打卡';
  static const String emptyHomeTitle = '还没有习惯';
  static const String emptyHomeHint = '点右下角的加号，从你的第一个习惯开始。';
  static const String fabNewHabit = '新建习惯';

  // Habit detail
  static const String habitDetailTitle = '习惯详情';
  static const String historySection = '历史记录';
  static const String editHabit = '编辑';
  static const String archiveHabit = '归档';
  static const String restoreHabit = '恢复';

  // Habit form
  static const String createHabitTitle = '新建习惯';
  static const String editHabitTitle = '编辑习惯';
  static const String nameLabel = '习惯名称';
  static const String descriptionLabel = '备注（可选）';
  static const String iconLabel = '图标';
  static const String colorLabel = '颜色';
  static const String save = '保存';
  static const String delete = '删除';
  static const String confirmDeleteTitle = '删除这个习惯？';
  static const String confirmDeleteBody = '历史打卡也会被一并删除，且无法恢复。';

  // Streak
  static const String currentStreak = '当前连击';
  static const String longestStreak = '最长连击';
  static const String daysUnit = '天';

  // Today check-in
  static const String checkInNow = '打卡';
  static const String checkedIn = '今日已打卡';
  static const String uncheck = '取消打卡';

  // Settings
  static const String settingsTitle = '设置';
  static const String sectionAccount = '账号';
  static const String sectionAppearance = '外观';
  static const String themeSystem = '跟随系统';
  static const String themeLight = '浅色';
  static const String themeDark = '深色';
  static const String archivedSection = '已归档';
  static const String signOut = '退出登录';
  static const String signOutConfirm = '确定退出登录？';
  static const String languageLabel = '语言';
  static const String languageZh = '简体中文';
  static const String languageHint = '（当前仅中文）';

  // Common
  static const String cancel = '取消';
  static const String ok = '确定';
  static const String retry = '重试';
  static const String errorTitle = '出错了';
  static const String loadingError = '加载失败，请检查网络';
  static const String offlineBanner = '离线中 — 显示的是缓存数据';
}