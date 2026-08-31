import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/habit_form_controller.dart';
import '../../controllers/habit_list_controller.dart';
import '../../l10n/strings_zh.dart';
import '../../models/habit_icon.dart';
import '../../theme/habit_palette.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});

  final String? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habitId != null;
    final stateAsync = ref.watch(habitFormControllerProvider);

    // 编辑模式：第一次进来加载
    ref.listen(habitFormControllerProvider, (prev, next) {
      if (!_loaded && isEdit && next.hasValue && next.value!.name.isEmpty) {
        ref.read(habitFormControllerProvider.notifier).loadFor(widget.habitId!);
        _loaded = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? S.editHabitTitle : S.createHabitTitle),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('出错了: $e')),
        data: (state) {
          // 同步 controller -> 文本框（仅在初次填充）
          if (_nameCtrl.text.isEmpty && state.name.isNotEmpty) {
            _nameCtrl.text = state.name;
          }
          if (_descCtrl.text.isEmpty && (state.description ?? '').isNotEmpty) {
            _descCtrl.text = state.description!;
          }
          return _buildForm(context, state);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, HabitFormState state) {
    final controller = ref.read(habitFormControllerProvider.notifier);
    final selectedColor = HabitPalette.byValue(state.colorValue);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _nameCtrl,
          onChanged: controller.setName,
          decoration: InputDecoration(
            labelText: S.nameLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          onChanged: controller.setDescription,
          maxLines: 3,
          maxLength: 140,
          decoration: InputDecoration(
            labelText: S.descriptionLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(S.iconLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HabitIcons.all.map((entry) {
            final selected = entry.key == state.iconKey;
            return GestureDetector(
              onTap: () => controller.setIcon(entry.key),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected
                      ? selectedColor.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? Border.all(color: selectedColor, width: 2)
                      : null,
                ),
                child: Icon(
                  entry.icon,
                  color: selected
                      ? selectedColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(S.colorLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HabitPalette.colors.map((c) {
            final argb = c.toARGB32();
            final selected = argb == state.colorValue;
            return GestureDetector(
              onTap: () => controller.setColor(argb),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 3,
                        )
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        FilledButton(
          onPressed: state.busy
              ? null
              : () async {
                  try {
                    final id = await controller.submit();
                    if (context.mounted) context.pop(id);
                  } catch (_) {
                    // error already in state.error
                  }
                },
          child: state.busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : const Text(S.save),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.confirmDeleteTitle),
        content: const Text(S.confirmDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.delete),
          ),
        ],
      ),
    );
    if (ok == true && widget.habitId != null) {
      await ref.read(habitActionsProvider.notifier).delete(widget.habitId!);
      if (context.mounted) {
        // 删除后回到 home（可能来自 /habit/:id）
        context.go('/home');
      }
    }
  }
}