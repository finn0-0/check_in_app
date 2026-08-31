import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Provider：注入 AuthService 实例。测试时可以 override。
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider：当前 Firebase 用户。null = 未登录。loading = 初始化中。
///
/// 底层订阅 `FirebaseAuth.authStateChanges()`，登录/退出/注册成功后自动刷新。
final authControllerProvider =
    StreamNotifierProvider<AuthController, User?>(AuthController.new);

class AuthController extends StreamNotifier<User?> {
  @override
  Stream<User?> build() {
    final auth = ref.read(authServiceProvider);
    return auth.authStateChanges();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = ref.read(authServiceProvider);
    try {
      await auth.signInWithEmail(email: email, password: password);
    } catch (e) {
      throw AuthException(auth.describeError(e));
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = ref.read(authServiceProvider);
    try {
      await auth.registerWithEmail(email: email, password: password);
    } catch (e) {
      throw AuthException(auth.describeError(e));
    }
  }

  Future<void> signOut() async {
    final auth = ref.read(authServiceProvider);
    await auth.signOut();
  }
}

/// 给 UI 用的轻量包装异常，保留原始 message。
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}