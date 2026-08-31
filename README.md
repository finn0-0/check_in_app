# my_check_in_app

个人习惯打卡 App —— 多习惯管理、日历视图、连续天数、云端同步（Firebase）。

## 当前状态

v1.0 MVP 已完成。架构、主题、Firebase 接入、6 个页面、单元测试与 widget smoke test 均已就绪。**Firebase 项目配置**需按下方"Firebase 接入"小节手动完成后才能跑通完整流程；`lib/firebase_options.dart` 当前是占位实现。

## 技术栈

- Flutter 3.44+ / Dart 3.12+
- **状态管理**：Riverpod 3（`flutter_riverpod`）
- **路由**：GoRouter（带 auth 重定向）
- **后端**：Firebase Auth（仅邮箱+密码） + Cloud Firestore
- **本地缓存**：Firestore 内置离线持久化（默认开启）
- **主题**：Material 3（`ColorScheme.fromSeed`）
- **测试**：flutter_test + mocktail + fake_cloud_firestore
- **日历**：table_calendar

## 目录结构

```
lib/
├── main.dart                  # Firebase 初始化 + runApp(ProviderScope(MyApp))
├── app.dart                   # MaterialApp.router + 主题
├── controllers/               # Riverpod notifier
│   ├── auth_controller.dart
│   ├── habit_list_controller.dart
│   ├── habit_form_controller.dart
│   └── checkin_controller.dart
├── models/                    # 纯 Dart 数据类
│   ├── habit.dart
│   ├── checkin.dart
│   ├── streak.dart
│   └── habit_icon.dart
├── services/                  # Firebase 业务层（唯一 import firebase_* 的层）
│   ├── firebase_bootstrap.dart
│   ├── auth_service.dart
│   ├── habit_repository.dart
│   └── checkin_repository.dart
├── view/
│   ├── screens/               # 6 个页面
│   └── widgets/               # 可复用 widgets
├── routing/
│   ├── app_router.dart        # GoRouter 配置 + auth redirect
│   └── route_paths.dart
├── theme/
│   ├── app_theme.dart         # M3 ColorScheme.fromSeed
│   └── habit_palette.dart
├── utils/
│   ├── date_key.dart          # YYYY-MM-DD 工具
│   ├── result.dart
│   └── extensions.dart
├── l10n/
│   └── strings_zh.dart        # 集中文案（v1 仅中文）
└── firebase_options.dart      # 占位 / flutterfire 生成
```

## Firebase 接入步骤

应用代码已完成所有 Firebase 调用，但运行时需要真实配置。下面是手动接入步骤：

### 1. 创建 Firebase 项目

1. 浏览器打开 https://console.firebase.google，Google 账号登录。
2. **Add project** → 项目名（例如 `my-check-in-app`）→ 一路下一步，**关掉** Google Analytics。
3. 项目主页 → **Add app** → 选 **Android**（先以 Android 跑通）：
   - Android 包名：`com.example.my_check_in_app`（先用 scaffold 默认值）
   - **下载 `google-services.json`** → 放到 `android/app/google-services.json`
   - 跳过"Verify app install"和"Add Firebase SDK"步骤向导（Flutter 用 FlutterFire CLI 替代）

### 2. 启用 Authentication + Firestore

1. 左侧栏 **Authentication → Sign-in method → Email/Password → Enable**
2. 左侧栏 **Firestore Database → Create database → Production mode → 选区域（asia-east1 或 asia-northeast2）**

### 3. 部署安全规则

将项目根目录的 `firestore.rules` 部署到 Firebase 控制台：
- Firestore → Rules → 粘贴 `firestore.rules` 内容 → Publish

或者用 Firebase CLI：
```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

### 4. FlutterFire CLI 生成配置

```bash
dart pub global activate flutterfire_cli
cd my_check_in_app
flutterfire configure --platforms=android,ios,web
```

该工具会：
- 生成 `lib/firebase_options.dart`（覆盖占位实现）
- 生成 `firebase.json`、`.firebaserc`
- 修改 `android/app/build.gradle.kts` 注入 `google-services` 插件

### 5. 跑起来

```bash
flutter pub get
flutter run
```

## 开发命令

```bash
flutter pub get          # 装包
flutter analyze          # 静态分析
flutter test             # 单元 + widget 测试
flutter run -d <device>  # 模拟器/真机
flutter build apk       # Android APK
flutter build ios --no-codesign  # iOS（需 Xcode）
flutter build web       # Web（注意 Web 上需手动 enablePersistence）
```

## 数据模型（Firestore）

```
users/{uid}
  email: string
  displayName: string?

users/{uid}/habits/{habitId}
  name: string
  iconKey: string            # 来自 HabitIcons 注册表
  colorValue: number        # ARGB int
  description: string?
  createdAt: timestamp
  archived: boolean
  sortOrder: number
  targetPerWeek: number?
  reminderTimeHHmm: string? # v1 预留字段

users/{uid}/habits/{habitId}/checkins/{dateKey}    # dateKey = "YYYY-MM-DD"
  date: timestamp          # 本地午夜
  createdAt: timestamp
  note: string?
  moodScore: number?       # 1..5
```

**为什么打卡用子集合**：单日写入不用读/写整个数组；离线缓存按集合分片。

## v1 范围 vs 推迟

**v1 已完成**：邮箱密码登录、Firestore CRUD、多习惯、日历视图、连续天数（客户端计算）、历史列表、归档/恢复、Material 3 主题、路由 + auth 重定向。

**推迟到 v1.1+**：
- 提醒通知（`flutter_local_notifications` + timezone）
- 完整 i18n（`flutter_localizations` + `.arb`）
- 周目标执行与进度条
- 连续天数徽章 / 分享图片
- Apple 登录
- 拖拽排序
- 平板自适应布局
- 习惯导入/导出