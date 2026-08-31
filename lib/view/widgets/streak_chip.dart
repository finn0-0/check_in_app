import 'package:flutter/material.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.days, this.color});

  final int days;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = color ?? scheme.primaryContainer;
    final fg = color != null
        ? Colors.white
        : Theme.of(context).colorScheme.onPrimaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: fg),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}