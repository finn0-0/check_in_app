import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/habit_list_controller.dart';
import '../../l10n/strings_zh.dart';
import '../../models/habit.dart';
import '../../models/habit_icon.dart';
import '../../theme/habit_palette.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final archivedAsync = ref.watch(archivedHabitsProvider);
    final archived = archivedAsync.value ?? const <Habit>[];
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text(S.sectionAccount),
            subtitle: Text(user?.email ?? '未登录'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text(S.languageLabel),
            subtitle: Text('${S.languageZh}${S.languageHint}'),
          ),
          const Divider(height: 1),
          if (archived.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                S.archivedSection,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ...archived.map(
              (h) => _ArchivedTile(habit: h, ref: ref),
            ),
            const Divider(height: 1),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.logout),
              label: const Text(S.signOut),
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _confirmSignOut(context, ref),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.signOut),
        content: const Text(S.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.ok),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) context.go('/login');
    }
  }
}

class _ArchivedTile extends StatelessWidget {
  const _ArchivedTile({required this.habit, required this.ref});
  final Habit habit;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final color = HabitPalette.byValue(habit.colorValue);
    final icon = HabitIcons.byKey(habit.iconKey);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(habit.name),
      trailing: TextButton(
        onPressed: () =>
            ref.read(habitActionsProvider.notifier).restore(habit.id),
        child: const Text(S.restoreHabit),
      ),
    );
  }
}