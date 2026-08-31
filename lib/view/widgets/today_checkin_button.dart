import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/checkin_controller.dart';
import '../../l10n/strings_zh.dart';

class TodayCheckInButton extends ConsumerWidget {
  const TodayCheckInButton({
    super.key,
    required this.habitId,
    required this.color,
  });

  final String habitId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChecked = ref.watch(isTodayCheckedInProvider(habitId));
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: FilledButton.icon(
        onPressed: () =>
            ref.read(checkInsProvider(habitId).notifier).toggleToday(),
        icon: Icon(
          isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
        ),
        label: Text(isChecked ? S.checkedIn : S.checkInNow),
        style: FilledButton.styleFrom(
          backgroundColor: isChecked ? color : scheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}