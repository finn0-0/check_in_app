import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../view/screens/habit_detail_screen.dart';
import '../view/screens/habit_form_screen.dart';
import '../view/screens/home_screen.dart';
import '../view/screens/login_screen.dart';
import '../view/screens/settings_screen.dart';
import '../view/screens/splash_screen.dart';
import 'route_paths.dart';

/// GoRouter 根据 auth state 自动重定向：
///   - AsyncLoading → 仍在 splash
///   - user == null → /login
///   - user != null 且当前在 /login 或 / → /home
GoRouter buildAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final user = auth.value;
      final loc = state.matchedLocation;

      // 还在初始化：停留在 splash
      if (auth.isLoading) {
        return RoutePaths.splash;
      }

      // 未登录：除 /login 外都踢回 /login
      if (user == null) {
        return loc == RoutePaths.login ? null : RoutePaths.login;
      }

      // 已登录：在 /login 或 / 跳转 /home
      if (loc == RoutePaths.login || loc == RoutePaths.splash) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.habitNew,
        builder: (context, state) => const HabitFormScreen(),
      ),
      GoRoute(
        path: '/habit/:habitId',
        builder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          return HabitDetailScreen(habitId: habitId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final habitId = state.pathParameters['habitId']!;
              return HabitFormScreen(habitId: habitId);
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('出错了')),
      body: Center(child: Text('找不到页面: ${state.uri}')),
    ),
  );
}

/// 把 Riverpod 的 auth provider 包装成 ChangeNotifier，让 GoRouter 知道何时刷新 redirect。
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}