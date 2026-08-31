# CLAUDE.md

> 本文件供 Claude / AI 协作者快速理解 Flutter 项目上下文。每次新会话开始时会被自动加载。
>
> 最后更新：2026-08-31（基于实际代码 + pubspec.lock + flutter test 实测）

---

## 1. 项目概述

**my_check_in_app** 是一个**个人习惯打卡 App**（多习惯、日历视图、连续天数、云端同步）。每个用户可以创建若干习惯，每天一键打卡，自动统计"当前连击 / 历史最长连击"，并提供日历视图 + 历史记录列表。

**核心特性**：
- 多习惯管理（图标 / 颜色 / 备注）
- 一日一卡（幂等，文档 ID = `YYYY-MM-DD`）
- 客户端计算 streak（`StreakCalculator` 纯函数）
- 日历视图（`table_calendar`）+ 历史记录（`Dismissible` 滑动删除）
- 归档（保留数据）/ 删除（连同打卡一起清除）二选一
- 邮箱密码登录（`Firebase Auth`）
- Firestore 离线持久化（默认开启）

**目标用户**：个人自用，强调**离线可用 + 跨设备同步**（云端优先，离线缓存兜底）。

**运行方式**：
```bash
flutter pub get
flutter run -d chrome    # 跑 Web（最快）
flutter run -d android   # 跑 Android 模拟器
```

⚠️ **当前 `lib/firebase_options.dart` 是占位**，直接 `flutter run` 会卡在 `Firebase.initializeApp()`。要走 `flutterfire configure` 或临时绕过（见 §4）。

---

## 2. 技术栈

### 核心运行时

| 技术 | 版本 | 来源 |
|---|---|---|
| Flutter | 3.44.4（stable channel） | 本机 `D:\Flutter_SDK\flutter` |
| Dart | 3.12.2 | 随 Flutter |
| SDK 约束 | `^3.12.2` | [pubspec.yaml](pubspec.yaml#L22) |

### 依赖（全部从 [pubspec.yaml](pubspec.yaml) 锁定）

| 包 | 版本 | 作用 |
|---|---|---|
| `flutter_riverpod` | ^3.4.2 | 状态管理（`StreamNotifier` / `Notifier`） |
| `go_router` | ^17.5.0 | 路由 + auth redirect |
| `firebase_core` | ^4.13.0 | Firebase 初始化 |
| `firebase_auth` | ^6.5.7 | 邮箱密码登录 |
| `cloud_firestore` | ^6.8.0 | 云端数据库 |
| `table_calendar` | ^3.2.1 | 习惯详情页日历 |
| `intl` | ^0.20.3 | 日期格式化（`zh_CN` locale） |
| `shared_preferences` | ^2.5.5 | 未来本地配置项（v1 未启用） |
| `cupertino_icons` | ^1.0.8 | iOS 风格图标 |

### 开发依赖

| 包 | 版本 | 作用 |
|---|---|---|
| `flutter_lints` | ^6.0.0 | 静态分析规则 |
| `mocktail` | ^1.0.5 | mock 工具（备用） |
| `fake_cloud_firestore` | ^4.2.0 | 替代真 Firestore 跑测试 |

### 测试栈

- **单元测试**：纯函数 + Repository（用 `fake_cloud_firestore`）
- **Widget 测试**：`flutter_test` + `pumpWidget` + ProviderScope override
- **Riverpod 测试模式**：`ProviderContainer` + `authServiceProvider.overrideWith` + `habitRepositoryProvider.overrideWith`
- **当前状态**：22 个测试全绿（`flutter test` 输出 `+22: All tests passed!`）

### 明确**不**使用

- ❌ BLoC / Redux / 任何其他状态管理
- ❌ Drift / sqflite / Hive（**纯本地方案**未启用，数据全在 Firestore）
- ❌ flutter_local_notifications（v1.1 待办）
- ❌ flutter_localizations / .arb（v1 仅中文，集中于 [strings_zh.dart](lib/l10n/strings_zh.dart)）

---

## 3. 项目结构

```
my_check_in_app/
├── CLAUDE.md                       # 本文件
├── README.md                       # 用户文档 + Firebase 接入步骤
├── pubspec.yaml                    # 依赖锁定
├── pubspec.lock                    # 实际版本解析结果
├── analysis_options.yaml           # flutter_lints 规则
├── firestore.rules                 # Firestore 安全规则（部署到 Firebase 控制台）
│
├── lib/
│   ├── main.dart                   # 入口：WidgetsFlutterBinding + Firebase init + ProviderScope
│   ├── app.dart                    # MaterialApp.router + 主题
│   ├── firebase_options.dart       # ⚠️ 占位文件，真接入需 flutterfire configure
│   │
│   ├── controllers/                # Riverpod notifier（业务逻辑编排层）
│   │   ├── auth_controller.dart        # StreamNotifier<User?>：authStateChanges
│   │   ├── habit_list_controller.dart  # StreamNotifier<List<Habit>>：active / archived
│   │   ├── habit_form_controller.dart  # AsyncNotifier<HabitFormState>：创建/编辑表单
│   │   └── checkin_controller.dart     # Notifier<List<CheckIn>> family<habitId>：打卡 toggle
│   │
│   ├── models/                     # 纯 Dart 数据类（无 Flutter 依赖，除 habit_icon）
│   │   ├── habit.dart                  # 习惯：name / iconKey / colorValue / archived / sortOrder
│   │   ├── checkin.dart                # 一日一卡：id=dateKey / date / note / moodScore
│   │   ├── streak.dart                 # StreakStats + StreakCalculator 纯函数
│   │   └── habit_icon.dart             # HabitIcons 注册表（20 个 Material icon）
│   │
│   ├── services/                   # ⚠️ Firebase 唯一进口层
│   │   ├── firebase_bootstrap.dart     # Firebase.initializeApp
│   │   ├── auth_service.dart           # FirebaseAuth 包装 + 中文错误码映射
│   │   ├── habit_repository.dart       # habits CRUD + watchHabits + sortOrder 计数
│   │   └── checkin_repository.dart     # checkins 幂等写入 + 删除
│   │
│   ├── view/
│   │   ├── screens/                 # 6 个页面
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart           # 邮箱密码登录 + 切换注册
│   │   │   ├── home_screen.dart            # 习惯列表 + streak
│   │   │   ├── habit_detail_screen.dart    # 日历 + 历史 + 归档入口
│   │   │   ├── habit_form_screen.dart      # 创建/编辑（共用，按 habitId null/非区分）
│   │   │   └── settings_screen.dart        # 账号 / 归档列表 / 退出
│   │   └── widgets/
│   │       ├── habit_card.dart             # Home 用：图标 + 名字 + streak + 打卡按钮
│   │       ├── today_checkin_button.dart   # 今日打卡按钮（toggle 动画）
│   │       ├── streak_chip.dart            # streak 数字徽章
│   │       ├── history_list_tile.dart      # 历史记录（可滑动删除）
│   │       ├── empty_state_view.dart       # 空状态
│   │       └── habit_color_dot.dart        # 小圆点（备用）
│   │
│   ├── routing/
│   │   ├── app_router.dart             # GoRouter + _AuthRefreshListenable
│   │   └── route_paths.dart            # 路径常量
│   │
│   ├── theme/
│   │   ├── app_theme.dart              # M3 ColorScheme.fromSeed(seed: 0xFF6750A4)
│   │   └── habit_palette.dart          # 习惯色板（10 个固定 Color）
│   │
│   ├── utils/
│   │   ├── date_key.dart               # YYYY-MM-DD 工具（dayOnly / format / parse）
│   │   ├── extensions.dart             # DateTime 的 dayOnly / isSameDayAs / daysBetween
│   │   └── result.dart                 # sealed Result<T,E>（v1 预留，未使用）
│   │
│   └── l10n/
│       └── strings_zh.dart             # 用户可见中文文案集中处
│
├── test/                          # 22 个测试
│   ├── widget_test.dart                       # 未登录 → /login
│   ├── models/
│   │   ├── streak_test.dart                   # StreakCalculator 8 例
│   │   └── habit_codec_test.dart              # Habit 序列化 4 例
│   ├── services/
│   │   ├── habit_repository_test.dart         # CRUD + archive + sortOrder 4 例
│   │   └── checkin_repository_test.dart       # 幂等 + 排序 + 删除 3 例
│   └── controllers/
│       └── habit_list_controller_test.dart    # 未登录空 + 登录过滤归档 2 例
│
└── build/                         # Flutter 构建产物（已在 .gitignore）
```

### 分层规则（硬性）

```
view/  ──►  controllers/  ──►  services/  ──►  Firebase SDK
                                  ▲
                                  │ import firebase_* 的唯一层
```

- `models/` 不依赖任何层
- `controllers/` 只依赖 `models/` + `services/`
- `view/` 只依赖 `controllers/` + `models/`（**不直接** import `firebase_*`）

---

## 4. 常用命令

### 依赖

```bash
flutter pub get              # 拉依赖
flutter pub outdated         # 看升级
flutter pub upgrade          # 升级（保守）
flutter pub upgrade --major-versions  # 升 major（慎重）
```

### 静态检查

```bash
flutter analyze              # 全项目 lint
dart analyze lib/            # 只查 lib/
```

### 测试

```bash
flutter test                          # 跑全部（当前 22 个全绿）
flutter test test/models/             # 跑某个目录
flutter test test/models/streak_test.dart    # 跑单个文件
flutter test --plain-name "断链"      # 按用例名过滤
flutter test --reporter expanded      # 详细输出
flutter test --coverage               # 生成 coverage/lcov.info
flutter test --update-goldens         # 金标截图（widget_test 用得到）
```

### 跑应用

```bash
flutter run -d chrome         # Web（最快）
flutter run -d edge           # Edge
flutter run -d windows        # Windows 桌面
flutter run -d android        # Android（需模拟器或真机）
flutter devices               # 列出可用设备
flutter emulators             # 列出 / 启动模拟器
```

�️ **当前 `firebase_options.dart` 是占位**，`flutter run` 会卡在 Firebase init。三种绕过：

```bash
# 方案 A：临时改 main.dart（注释掉 FirebaseBootstrap.initialize）
# 方案 B：flutterfire configure 真接入（README 第 59-90 行）
# 方案 C：跑测试看 UI（flutter test 已验证 widget 流程）
```

### 构建

```bash
flutter build apk             # Android APK
flutter build appbundle       # Android App Bundle（AAB，上 Google Play）
flutter build ios --no-codesign   # iOS（需 macOS + Xcode）
flutter build web             # Web
flutter build windows         # Windows
```

### 覆盖率可视化

```bash
flutter test --coverage
# VS Code 装 Coverage Gutters 插件看高亮
# 或 genhtml coverage/lcov.info -o coverage/html
```

---

## 5. 代码规范

### 通用

- **缩进：2 空格**
- **文件编码：UTF-8**
- **行尾：LF**
- **注释：中文**（项目里已有代码全是中文注释，AI 生成代码也要跟）
- **每文件职责单一**：UI / 业务 / 数据分离

### Dart 命名

| 类型 | 风格 | 例 |
|---|---|---|
| 类 | `PascalCase` | `HabitFormController` |
| 方法 / 变量 / 参数 | `camelCase` | `compute`, `today`, `habitId` |
| 常量 | `lowerCamelCase`（Dart 约定） | `defaultIndex`, `empty` |
| 私有成员 | `_camelCase` 前缀 | `_build`, `_routerProvider` |
| 文件名 | `snake_case.dart` | `habit_form_controller.dart` |
| 字符串常量集中处 | `strings_zh.dart` 用 `S.xxx` | `S.homeTitle` |

### Flutter / Riverpod 约定

- **Provider 暴露给 override**：`authServiceProvider`、`habitRepositoryProvider`、`checkInRepositoryProvider` 是注入点，测试时 `overrideWithValue` / `overrideWith`
- **状态类用 `copyWith`**：见 [HabitFormState](lib/controllers/habit_form_controller.dart#L9)
- **Widget 拆分**：复用组件放 `view/widgets/`，页面放 `view/screens/`
- **ConsumerWidget vs ConsumerStatefulWidget**：无本地 state 用前者；表单 / 动画用后者

### CSS / 颜色

- **不写硬编码颜色**：习惯颜色从 [HabitPalette](lib/theme/habit_palette.dart)（10 色）+ [AppTheme](lib/theme/app_theme.dart)（M3 seed `0xFF6750A4`）
- **`ColorScheme.fromSeed`**：所有 M3 颜色走种子色派生
- **`withValues(alpha:)`**：Flutter 3.5+ 推荐写法（不要用 `withOpacity`）

### 测试约定

- **文件名**：`test/<被测层>/<被测类>_test.dart`
- **描述**：`test('场景描述', () { ... })` 用中文
- **断言**：`expect(actual, matcher)` 必须包含具体 matcher（不要 `expect(x, isNotNull)` 后再隐式判定）
- **Fake 模式**：构造注入 `FakeFirebaseFirestore` / `_FakeAuthService`
- **每个 `testWidgets` 必须有 `await tester.pumpAndSettle()`**

### Git 提交（建议）

```bash
# 格式：<type>(scope): <中文描述>
git commit -m "feat(habits): 支持拖拽排序"
git commit -m "fix(streak): 修复跨年 streak 计算"
git commit -m "test(checkin): 补 toggleToday 用例"
```

---

## 6. 重要约束（硬性）

### 不要做的事

| ❌ 禁止 | 原因 |
|---|---|
| 在 `view/` 或 `controllers/` 直接 `import 'package:firebase_*/...'` | 破坏分层；测试无法用 fake 替代 |
| 改 `services/` 的方法签名（参数列表） | 测试和 controller 都依赖 |
| 把 `firebase_options.dart` 提交真值到 git | 暴露 apiKey |
| 删 `firestore.rules` 或放宽规则 | 数据隔离是核心安全保证 |
| 用 `withOpacity()` 替代 `withValues(alpha:)` | Flutter 3.5+ 已废弃 |
| 在 widget 里 hardcode 字符串（中文 / 英文） | 文案集中在 `strings_zh.dart`，未来切 i18n |
| 把打卡文档 ID 写成非 `YYYY-MM-DD` 格式 | `firestore.rules` 已用正则校验，违规会写入失败 |
| 用 `DateTime.now()` 算 streak 时不传 `today` 参数到 `StreakCalculator.compute` | 测试无法注入"今天"，永远只能跑当前时间 |
| 引入新依赖不更新 `pubspec.yaml` | 违反依赖管理 |

### Firestore 数据模型（不要随便改）

```
users/{uid}/
  habits/{habitId}/
    name, iconKey, colorValue, createdAt, archived, sortOrder,
    description?, targetPerWeek?, reminderTimeHHmm?
    checkins/{dateKey}/     # dateKey = "YYYY-MM-DD"
      date, createdAt, note?, moodScore?
```

- 打卡用**子集合**而非数组：单日写不用读全数组，离线缓存按集合分片
- **dateKey = doc id**：保证同日幂等
- 修改字段前先看 `models/habit.dart` 和 `models/checkin.dart` 的 `toMap/fromMap`，**两边要同步**

### 安全规则（[firestore.rules](firestore.rules)）

```js
match /users/{uid} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
  match /habits/{habitId} {
    match /checkins/{dateKey} {
      allow create, update: if dateKey.matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}$');
    }
  }
}
```

**关键**：
- 只能读写**自己的**数据（按 `auth.uid` 隔离）
- dateKey 必须匹配 `YYYY-MM-DD`（防乱写）

### 测试覆盖率（建议）

- 改 `services/` 或 `controllers/` 时**必须**带测试
- 新增页面 / widget 必须有 widget test
- 跑 `flutter test --coverage` 自检

---

## 7. 业务背景

### 目标用户

- **主要**：个人用户（自用工具），强调离线可用 + 跨设备
- **次要**：习惯养成类产品的轻度用户

### 核心场景（按使用频率）

1. **每日打开 → 打卡**（高频，30 秒内）：`Home` → 点 `TodayCheckInButton` → 完成
2. **查看连续天数**：Home 每张卡显示 `StreakChip`，点进去 `HabitDetail` 看历史最长
3. **补卡 / 删卡**：`HabitDetail` → 历史列表滑动删除 / 日历点日期
4. **新建习惯**：`Home` 右下角 FAB → `HabitFormScreen`（图标 + 颜色 + 备注）
5. **整理**：`Settings` → 已归档区恢复 / 退出登录

### 关键业务规则

#### Streak 计算（[streak.dart](lib/models/streak.dart)）

- **`current`**：从最近一次打卡**向前**数连续天数。要求最近一次是今天或昨天，否则 `current = 0`（streak 已断）
- **`longest`**：历史任意一段连续打卡的最长长度
- **`lastCheckInDate`**：最近一次打卡的本地日期

> 例：8/20、8/21、8/22 都打卡，**8/23 没打**，`current` 仍是 3（streak 还在跑）；**8/24 仍没打**，`current = 0`（断了）。

#### 打卡幂等

- 同一天重复点 `TodayCheckInButton`：第一次写、第二次删（toggle）
- 写入用 `doc(id).set(..., SetOptions(merge: true))`：保留 `createdAt` 等字段

#### 归档 vs 删除

| 操作 | 习惯 | 打卡 | 可恢复 |
|---|---|---|---|
| **归档** | `archived=true` | 保留 | ✅ 设置页恢复 |
| **删除** | 删 habit 文档 | **级联删 checkins 子集合** | � 不可恢复 |

> 注意：Firestore 默认不级联删除子集合，**当前实现依赖手工调 `delete` 时由客户端确保子集合先清空**——见 [habit_form_screen.dart](lib/view/screens/habit_form_screen.dart) 的删除流程。如要服务端级联，需要 Cloud Functions trigger 或重组数据模型。

#### 排序

- 习惯按 `sortOrder` 升序、再按 `createdAt` 升序
- `create()` 用 `count().get()` 算下一个 sortOrder（**单机 OK，**并发下两个 create 可能拿到同值——可优化但非阻塞）

### 维护节奏

- 季度更新：经历时间线（不适用于此 app）
- **按需**：新建习惯、调色板增色、修复 streak bug
- **v1.1 候选**：本地通知、i18n、周目标、note/mood 编辑、streak 徽章分享
- **v2.0 候选**：纯本地迁移（脱 Firebase）、平板自适应、习惯导入导出

### 后续扩展路径

| 路径 | 工作量 | 适用场景 |
|---|---|---|
| **A. 加 Hive 本地层** | 1-2 天 | 想脱 Firebase、或加 Web 离线优先 |
| **B. 加 Cloud Functions** | 半天 | 想服务端级联删除、推送、数据汇总 |
| **C. 加 i18n** | 1 天 | 出海 / 多语言 |
| **D. 加通知** | 1 天 | `reminderTimeHHmm` 字段已预留 |

---

## 8. AI 协作约定

### 安全性较高的"基本扫描 + 创建内容"操作**不需要确认**，直接执行：

- 读文件 / 搜索代码 / `grep` / `glob`
- 跑 `flutter analyze` / `flutter test` / `flutter pub get`
- 创建 / 编辑项目内的代码文件、测试文件、文档（CLAUDE.md / README.md）
- 创建临时辅助脚本（如 `e:/PersonalWeb/setup_*.ps1`）
- `git add` / `git status` / `git diff`（**不**包括 `git commit` / `git push` / `git reset --hard`）
- 删除临时文件 / 脚本
- 安装项目依赖（`flutter pub add`）

完成后**简短总结做了什么 + 关键结论**即可，不用等用户确认。

### 需要确认的操作

- 任何**修改外部系统**的动作：`flutterfire configure`（会创建 / 覆盖 Firebase 项目配置）、Firebase 控制台操作
- **删除 / 重写**已有功能模块（不是改一两个文件）
- `git commit` / `git push` / `git reset --hard` / `git branch -D`
- 改 `firestore.rules`、改 `firebase_options.dart` 真值
- 引入新的第三方依赖

---

## 附录：当前已知缺口（v1 后续工作）

| 项 | 现状 | 建议 |
|---|---|---|
| `AuthController` 测试 | ❌ 无 | mocktail 补 signIn / register / describeError 路径 |
| `HabitFormController` 测试 | ❌ 无 | 测 loadFor / submit / setName 路径 |
| `CheckInsController` 测试 | ❌ 无 | 测 toggleToday / deleteDay |
| `AuthService.describeError` 测试 | ❌ 无 | 中文错误码映射 8 例 |
| `firebase_options.dart` | ⚠️ 占位 | `flutterfire configure` |
| `Result<T,E>` 工具 | ⚠️ 定义未用 | 接入 repo 层 |
| `moodScore` / `note` 字段 | ⚠️ 模型有 UI 无 | 加打卡编辑入口 |
| `reminderTimeHHmm` 字段 | ⚠️ 模型有 UI 无 | 接 `flutter_local_notifications` |
| 主题切换 UI | ⚠️ 主题有切换器无 | 加 `themeMode` provider |
| Web 持久化 | ⚠️ README 提示需手动开 | `FirebaseBootstrap` 加 Web 分支 |

跑 `flutter test --coverage` 看具体数字。
