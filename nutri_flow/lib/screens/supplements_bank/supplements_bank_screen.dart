import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/supplement.dart';
import '../../providers/drink_supplement_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/empty_state.dart';

class SupplementsBankScreen extends ConsumerWidget {
  const SupplementsBankScreen({super.key});

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {Supplement? existing}) async {
    final result = await showDialog<Supplement>(
      context: context,
      builder: (context) => _SupplementEditorDialog(existing: existing),
    );
    if (result == null) return;
    final notifier = ref.read(supplementListProvider.notifier);
    if (existing == null) {
      await notifier.create(result);
    } else {
      await notifier.updateSupplement(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplements = ref.watch(supplementListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('بنك المكملات الغذائية')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('مكمّل جديد'),
      ),
      body: AsyncValueView<Supplement>(
        value: supplements,
        onRetry: () => ref.read(supplementListProvider.notifier).refresh(),
        emptyBuilder: (context) => const EmptyState(
          icon: Icons.medication_outlined,
          title: 'لا توجد مكملات غذائية بعد',
        ),
        data: (context, list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final s = list[i];
            final subtitleParts = [
              if (s.defaultDose != null && s.defaultDose!.isNotEmpty) 'الجرعة: ${s.defaultDose}',
              if (s.defaultTiming != null && s.defaultTiming!.isNotEmpty) 'التوقيت: ${s.defaultTiming}',
            ];
            return Card(
              child: ListTile(
                title: Text(s.name),
                subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
                onTap: () => _openEditor(context, ref, existing: s),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirmDelete(context, title: 'حذف "${s.name}"؟')) {
                      await ref.read(supplementListProvider.notifier).delete(s.id);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SupplementEditorDialog extends StatefulWidget {
  const _SupplementEditorDialog({this.existing});
  final Supplement? existing;

  @override
  State<_SupplementEditorDialog> createState() => _SupplementEditorDialogState();
}

class _SupplementEditorDialogState extends State<_SupplementEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _dose;
  late final TextEditingController _timing;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _dose = TextEditingController(text: s?.defaultDose ?? '');
    _timing = TextEditingController(text: s?.defaultTiming ?? '');
    _notes = TextEditingController(text: s?.defaultNotes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _timing.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'مكمّل جديد' : 'تعديل المكمّل'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dose,
                decoration: const InputDecoration(labelText: 'الجرعة الافتراضية'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timing,
                decoration: const InputDecoration(labelText: 'التوقيت الافتراضي'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'ملاحظات افتراضية'),
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              Supplement(
                id: widget.existing?.id ?? const Uuid().v4(),
                name: _name.text.trim(),
                defaultDose: _dose.text.trim().isEmpty ? null : _dose.text.trim(),
                defaultTiming: _timing.text.trim().isEmpty ? null : _timing.text.trim(),
                defaultNotes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              ),
            );
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
