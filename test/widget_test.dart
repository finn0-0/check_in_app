import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_check_in_app/app.dart';
import 'package:my_check_in_app/controllers/auth_controller.dart';

class _FakeAuthController extends AuthController {
  @override
  Stream<User?> build() => Stream.value(null);
}

void main() {
  testWidgets('未登录时自动跳转到 Login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('登录'), findsWidgets);
  });
}