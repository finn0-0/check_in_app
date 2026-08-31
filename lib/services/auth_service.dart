import 'package:firebase_auth/firebase_auth.dart';

/// 仅邮箱+密码登录 v1。
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Firebase Auth 的状态流。未登录时为 null。
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  /// 把 Firebase Auth 异常翻译成给用户看的中文短句。
  String describeError(Object error) {
    final code = _extractCode(error);
    switch (code) {
      case 'invalid-email':
        return '邮箱格式不正确';
      case 'email-already-in-use':
        return '该邮箱已被注册';
      case 'weak-password':
        return '密码至少需要 6 位';
      case 'wrong-password':
      case 'invalid-credential':
        return '邮箱或密码错误';
      case 'user-not-found':
        return '账号不存在';
      case 'user-disabled':
        return '账号已被禁用';
      case 'too-many-requests':
        return '尝试次数过多，请稍后再试';
      case 'network-request-failed':
        return '网络异常，请检查连接';
      default:
        return '登录失败，请稍后再试';
    }
  }

  String _extractCode(Object error) {
    try {
      // FirebaseAuthException has .code property
      final dyn = error as dynamic;
      return (dyn.code as String?) ?? '';
    } catch (_) {
      return '';
    }
  }
}