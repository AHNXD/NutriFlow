import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/meal_type.dart';
import '../../models/plan_day.dart';
import '../../models/plan_meal.dart';
import '../../providers/plan_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../providers/tips_providers.dart';
import '../../widgets/confirm_delete_dialog.dart';
import 'meal_editor_sheet.dart';

/// One tab's content in [PlanDetailScreen]: the day's motivational message
/// and its meal-type sections (breakfast/lunch/dinner/salad/snack), each
/// backed by zero or more `plan_meals` rows.
class DayBuilderView extends ConsumerWidget {
  const DayBuilderView({super.key, required this.planId, required this.day});

  final String planId;
  final PlanDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _MotivationalPicker(planId: planId, day: day),
        const SizedBox(height: 20),
        for (final type in MealType.planMealTypes) ...[
          _MealTypeSection(planId: planId, day: day, mealType: type),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _MotivationalPicker extends ConsumerWidget {
  const _MotivationalPicker({required this.planId, required this.day});
  final String planId;
  final PlanDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رسالة اليوم التحفيزية', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.motivationalText?.isNotEmpty == true
                        ? day.motivationalText!
                        : 'لم تُحدَّد بعد',
                    style: TextStyle(
                      color: day.motivationalText?.isNotEmpty == true
                          ? null
                          : Colors.black38,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final messages = await ref.read(motivationalMessageListProvider.future);
                    if (!context.mounted) return;
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (context) => _MotivationalDialog(
                        initial: day.motivationalText ?? '',
                        bankMessages: messages.map((m) => m.text).toList(),
                      ),
                    );
                    if (selected != null) {
                      await ref
                          .read(planDetailProvider(planId).notifier)
                          .setDayMotivationalText(day.id, selected);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationalDialog extends StatefulWidget {
  const _MotivationalDialog({required this.initial, required this.bankMessages});
  final String initial;
  final List<String> bankMessages;

  @override
  State<_MotivationalDialog> createState() => _MotivationalDialogState();
}

class _MotivationalDialogState extends State<_MotivationalDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('رسالة اليوم التحفيزية'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'اكتبي رسالة مخصصة...'),
            ),
            if (widget.bankMessages.isNotEmpty) ...[
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 6),
                  child: Text('أو اختاري من البنك:'),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final m in widget.bankMessages)
                      ListTile(
                        dense: true,
                        title: Text(m),
                        onTap: () => setState(() => _controller.text = m),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class _MealTypeSection extends ConsumerWidget {
  const _MealTypeSection({required this.planId, required this.day, required this.mealType});
  final String planId;
  final PlanDay day;
  final MealType mealType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = day.meals.where((m) => m.mealType == mealType).toList();
    final notifier = ref.read(planDetailProvider(planId).notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(mealType.labelAr, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final meal = await showMealEditorSheet(
                      context,
                      planDayId: day.id,
                      mealType: mealType,
                    );
                    if (meal != null) await notifier.saveMeal(meal);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            if (meals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('لم تُضَف وجبة بعد', style: TextStyle(color: Colors.black38)),
              )
            else
              for (final meal in meals) _MealTile(planId: planId, day: day, meal: meal),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends ConsumerWidget {
  const _MealTile({required this.planId, required this.day, required this.meal});
  final String planId;
  final PlanDay day;
  final PlanMeal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(planDetailProvider(planId).notifier);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(meal.customName ?? _recipeNameOf(ref, meal.recipeId) ?? 'وصفة من البنك'),
      subtitle: (meal.customIngredients != null)
          ? const Text('كميات معدّلة لهذه الحالة', style: TextStyle(fontSize: 12))
          : null,
      onTap: () async {
        final updated = await showMealEditorSheet(
          context,
          planDayId: day.id,
          mealType: meal.mealType,
          existing: meal,
        );
        if (updated != null) await notifier.saveMeal(updated);
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: () async {
          if (await confirmDelete(context, title: 'حذف هذه الوجبة؟')) {
            await notifier.deleteMeal(day.id, meal.id);
          }
        },
      ),
    );
  }

  String? _recipeNameOf(WidgetRef ref, String? recipeId) {
    if (recipeId == null) return null;
    final recipes = ref.read(recipeListProvider).valueOrNull;
    return recipes?.where((r) => r.id == recipeId).firstOrNull?.name;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
