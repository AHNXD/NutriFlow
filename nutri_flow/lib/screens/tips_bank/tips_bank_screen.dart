import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/tip.dart';
import '../../providers/tips_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/text_field_dialog.dart';

class TipsBankScreen extends StatelessWidget {
  const TipsBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بنك النصائح'),
          bottom: const TabBar(tabs: [
            Tab(text: 'نصائح'),
            Tab(text: 'رسائل تحفيزية'),
          ]),
        ),
        body: const TabBarView(
          children: [_TipsTab(), _MotivationalTab()],
        ),
      ),
    );
  }
}

class _TipsTab extends ConsumerWidget {
  const _TipsTab();

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {Tip? existing}) async {
    final result = await showDialog<(String, TipCategory)>(
      context: context,
      builder: (context) => _TipEditorDialog(existing: existing),
    );
    if (result == null) return;
    final notifier = ref.read(tipListProvider.notifier);
    if (existing == null) {
      await notifier.create(Tip(id: const Uuid().v4(), text: result.$1, category: result.$2));
    } else {
      await notifier.updateTip(Tip(id: existing.id, text: result.$1, category: result.$2));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(tipListProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('نصيحة جديدة'),
      ),
      body: AsyncValueView<Tip>(
        value: tips,
        onRetry: () => ref.read(tipListProvider.notifier).refresh(),
        emptyBuilder: (context) => const EmptyState(
          icon: Icons.lightbulb_outline,
          title: 'لا توجد نصائح بعد',
        ),
        data: (context, list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final tip = list[i];
            return Card(
              child: ListTile(
                title: Text(tip.text),
                subtitle: Text(tip.category.labelAr),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openEditor(context, ref, existing: tip),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (await confirmDelete(context, title: 'حذف هذه النصيحة؟')) {
                          await ref.read(tipListProvider.notifier).delete(tip.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TipEditorDialog extends StatefulWidget {
  const _TipEditorDialog({this.existing});
  final Tip? existing;

  @override
  State<_TipEditorDialog> createState() => _TipEditorDialogState();
}

class _TipEditorDialogState extends State<_TipEditorDialog> {
  late final TextEditingController _controller;
  late TipCategory _category;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.text ?? '');
    _category = widget.existing?.category ?? TipCategory.general;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'نصيحة جديدة' : 'تعديل النصيحة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'نص النصيحة'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TipCategory>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'التصنيف'),
            items: TipCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.labelAr)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(context, (text, _category));
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class _MotivationalTab extends ConsumerWidget {
  const _MotivationalTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(motivationalMessageListProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final text = await showTextFieldDialog(
            context,
            title: 'رسالة تحفيزية جديدة',
            hint: 'مثال: بداية جديدة = فرصة جديدة',
          );
          if (text != null) {
            await ref
                .read(motivationalMessageListProvider.notifier)
                .create(MotivationalMessage(id: const Uuid().v4(), text: text));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('رسالة جديدة'),
      ),
      body: AsyncValueView(
        value: messages,
        onRetry: () => ref.read(motivationalMessageListProvider.notifier).refresh(),
        emptyBuilder: (context) => const EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'لا توجد رسائل تحفيزية بعد',
        ),
        data: (context, list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final m = list[i];
            return Card(
              child: ListTile(
                title: Text(m.text),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final text = await showTextFieldDialog(
                          context,
                          title: 'تعديل الرسالة',
                          initial: m.text,
                        );
                        if (text != null) {
                          await ref
                              .read(motivationalMessageListProvider.notifier)
                              .updateMessage(MotivationalMessage(id: m.id, text: text));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (await confirmDelete(context, title: 'حذف هذه الرسالة؟')) {
                          await ref
                              .read(motivationalMessageListProvider.notifier)
                              .delete(m.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
