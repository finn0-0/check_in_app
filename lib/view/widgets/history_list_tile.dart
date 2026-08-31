import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryListTile extends StatelessWidget {
  const HistoryListTile({
    super.key,
    required this.date,
    this.note,
    this.onDelete,
  });

  final DateTime date;
  final String? note;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formatted = DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_CN').format(date);
    return Dismissible(
      key: ValueKey(date.toIso8601String()),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: scheme.errorContainer,
        child: Icon(Icons.delete, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            Icons.check,
            color: scheme.onPrimaryContainer,
            size: 18,
          ),
        ),
        title: Text(formatted),
        subtitle: note != null && note!.isNotEmpty ? Text(note!) : null,
      ),
    );
  }
}