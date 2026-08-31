import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Firebase 初始化。main.dart 在 runApp 之前调用。
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}