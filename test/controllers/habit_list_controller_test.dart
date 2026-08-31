import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_check_in_app/controllers/auth_controller.dart';
import 'package:my_check_in_app/controllers/habit_list_controller.dart';
import 'package:my_check_in_app/models/habit.dart';
import 'package:my_check_in_app/services/auth_service.dart';
import 'package:my_check_in_app/services/habit_repository.dart';

class _FakeAuthService implements AuthService {
  final StreamController<User?> _ctrl = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> authStateChanges() async* {
    if (_current != null) yield _current;
    yield* _ctrl.stream;
  }

  @override
  User? get currentUser => _current;

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {
    _current = null;
    _ctrl.add(null);
  }

  @override
  String describeError(Object error) => '';

  void login(User user) {
    _current = user;
    _ctrl.add(user);
  }
}

/// 占位 User 假对象：只暴露 uid 和 email，供 repo 内部读取。
class _FakeUser implements User {
  @override
  final String uid;
  @override
  final String email;
  _FakeUser(this.uid, this.email);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// 让 `container.read(provider)` 之后的下一帧内收到第一帧 emit。
Future<List<Habit>> _firstListOf(
  ProviderContainer container,
  dynamic provider,
) async {
  final completer = Completer<List<Habit>>();
  final sub = container.listen<AsyncValue<List<Habit>>>(
    provider,
    (prev, next) {
      final data = next.value;
      if (data != null && !completer.isCompleted) {
        completer.complete(data);
      }
    },
    fireImmediately: true,
  );
  try {
    return await completer.future.timeout(const Duration(seconds: 2));
  } finally {
    sub.close();
  }
}

void main() {
  late FakeFirebaseFirestore fs;
  late _FakeAuthService fakeAuthService;
  late ProviderContainer container;

  setUp(() {
    fs = FakeFirebaseFirestore();
    fakeAuthService = _FakeAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuthService),
        habitRepositoryProvider.overrideWith(
          (ref) => HabitRepository(firestore: fs),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('未登录时 activeHabits 为空', () async {
    final list = await _firstListOf(container, activeHabitsProvider);
    expect(list, isEmpty);
  });

  test('登录后 activeHabits 反映已添加的习惯（排除已归档）', () async {
    final repo = HabitRepository(firestore: fs);
    await repo.create(uid: 'u1', name: 'A', iconKey: 'k', colorValue: 0xFF000000);
    final id = await repo.create(
      uid: 'u1',
      name: 'B',
      iconKey: 'k',
      colorValue: 0xFF000000,
    );
    await repo.setArchived('u1', id, true);

    fakeAuthService.login(_FakeUser('u1', 'a@b.com'));

    // 等 authController 真正拿到 user
    final authReady = Completer<void>();
    final authSub = container.listen<AsyncValue<User?>>(
      authControllerProvider,
      (prev, next) {
        if (next.value != null && !authReady.isCompleted) authReady.complete();
      },
      fireImmediately: true,
    );
    await authReady.future.timeout(const Duration(seconds: 2));
    authSub.close();

    final active = await _firstListOf(container, activeHabitsProvider);
    expect(active.length, 1);
    expect(active.first.name, 'A');

    final archived = await _firstListOf(container, archivedHabitsProvider);
    expect(archived.length, 1);
    expect(archived.first.name, 'B');
  });
}