import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/layout.dart';

import '../../models/plan_supplement.dart';
import '../../models/supplement.dart';
import '../../providers/drink_supplement_providers.dart';
import '../../providers/plan_providers.dart';
import '../../widgets/confirm_delete_dialog.dart';

/// Second tab of [PlanDetailScreen]: helper drinks and supplements attached
/// to the whole plan (schema: `plan_drinks` / `plan_supplements`, both keyed
/// by `plan_id` directly rather than per-day — see schema.sql).
class PlanExtrasView extends ConsumerWidget {
  const PlanExtrasView({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(planDetailProvider(planId));
    final drinksAsync = ref.watch(helperDrinkListProvider);
    final supplementsBankAsync = ref.watch(supplementListProvider);

    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('تعذّر التحميل: $e')),
      data: (state) => PageBody(
        padding: EdgeInsets.zero,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text(
              'المشروبات المساعدة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            drinksAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('تعذّر تحميل بنك المشروبات: $e'),
              data: (drinks) => drinks.isEmpty
                  ? const Text(
                      'لا توجد مشروبات في البنك بعد',
                      style: TextStyle(color: Colors.black38),
                    )
                  : Card(
                      child: Column(
                        children: [
                          for (final drink in drinks)
                            CheckboxListTile(
                              title: Text(drink.name),
                              subtitle: drink.timing != null
                                  ? Text(drink.timing!)
                                  : null,
                              value: state.drinkIds.contains(drink.id),
                              onChanged: (checked) {
                                final updated = [...state.drinkIds];
                                if (checked == true) {
                                  updated.add(drink.id);
                                } else {
                                  updated.remove(drink.id);
                                }
                                ref
                                    .read(planDetailProvider(planId).notifier)
                                    .setDrinks(updated);
                              },
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'المكملات الغذائية',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: supplementsBankAsync.valueOrNull == null
                      ? null
                      : () async {
                          final result = await showDialog<PlanSupplement>(
                            context: context,
                            builder: (context) => _PlanSupplementDialog(
                              planId: planId,
                              bank: supplementsBankAsync.value!,
                            ),
                          );
                          if (result != null) {
                            await ref
                                .read(planDetailProvider(planId).notifier)
                                .addSupplement(result);
                          }
                        },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            if (state.supplements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'لا توجد مكملات مضافة لهذه الخطة بعد',
                  style: TextStyle(color: Colors.black38),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (final ps in state.supplements)
                      ListTile(
                        title: Text(
                          _supplementName(
                            supplementsBankAsync.valueOrNull,
                            ps.supplementId,
                          ),
                        ),
                        subtitle: Text(
                          [
                            if (ps.dose?.isNotEmpty == true)
                              'الجرعة: ${ps.dose}',
                            if (ps.timing?.isNotEmpty == true)
                              'التوقيت: ${ps.timing}',
                          ].join(' • '),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await confirmDelete(
                              context,
                              title: 'حذف هذا المكمّل من الخطة؟',
                            )) {
                              await ref
                                  .read(planDetailProvider(planId).notifier)
                                  .removeSupplement(ps.id);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _supplementName(List<Supplement>? bank, String? id) {
    if (bank == null || id == null) return 'مكمّل';
    return bank.where((s) => s.id == id).map((s) => s.name).firstOrNull ??
        'مكمّل محذوف من البنك';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _PlanSupplementDialog extends StatefulWidget {
  const _PlanSupplementDialog({required this.planId, required this.bank});
  final String planId;
  final List<Supplement> bank;

  @override
  State<_PlanSupplementDialog> createState() => _PlanSupplementDialogState();
}

class _PlanSupplementDialogState extends State<_PlanSupplementDialog> {
  Supplement? _selected;
  late final TextEditingController _dose;
  late final TextEditingController _timing;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _dose = TextEditingController();
    _timing = TextEditingController();
    _notes = TextEditingController();
  }

  @override
  void dispose() {
    _dose.dispose();
    _timing.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _applyDefaults(Supplement s) {
    _dose.text = s.defaultDose ?? '';
    _timing.text = s.defaultTiming ?? '';
    _notes.text = s.defaultNotes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة مكمّل للخطة'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Supplement>(
              initialValue: _selected,
              decoration: const InputDecoration(labelText: 'من بنك المكملات'),
              items: widget.bank
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (s) => setState(() {
                _selected = s;
                if (s != null) _applyDefaults(s);
              }),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dose,
              decoration: const InputDecoration(labelText: 'الجرعة'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timing,
              decoration: const InputDecoration(labelText: 'التوقيت'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(
                  context,
                  PlanSupplement(
                    id: '',
                    planId: widget.planId,
                    supplementId: _selected!.id,
                    dose: _dose.text.trim().isEmpty ? null : _dose.text.trim(),
                    timing: _timing.text.trim().isEmpty
                        ? null
                        : _timing.text.trim(),
                    notes: _notes.text.trim().isEmpty
                        ? null
                        : _notes.text.trim(),
                  ),
                ),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
