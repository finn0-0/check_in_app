// File: `lib/firebase_options.dart`
//
// 由 `flutterfire configure` 自动生成。**当前是占位实现**。
//
// 真接入步骤（详见 README.md）：
//   1. 在 https://console.firebase.google.com 创建项目并注册应用。
//   2. 在项目根目录执行 `flutterfire configure --platforms=android,ios,web`。
//   3. 该工具会用真实配置覆盖本文件。
//
// 当前占位值仅供编译通过；运行时 `Firebase.initializeApp()` 会失败，
// 直到你跑过 flutterfire configure。

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return android;
      default:
        return android;
    }
  }

  // PLACEHOLDER — 全部用占位值；flutterfire configure 会覆盖。
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_REPLACE_WITH_FLUTTERFIRE_CONFIG',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_REPLACE_WITH_FLUTTERFIRE_CONFIG',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
    iosBundleId: 'com.example.myCheckInApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER_REPLACE_WITH_FLUTTERFIRE_CONFIG',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
  );
}