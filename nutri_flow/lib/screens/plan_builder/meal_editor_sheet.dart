import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ingredient.dart';
import '../../models/meal_type.dart';
import '../../models/plan_meal.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_providers.dart';
import '../../widgets/ingredient_list_editor.dart';
import '../../widgets/steps_list_editor.dart';

/// Bottom sheet to add/edit one `plan_meals` row: either a bank recipe
/// (optionally with per-patient quantity overrides) or a fully hand-written
/// meal — see schema.sql comment on `plan_meals` for why both can coexist.
Future<PlanMeal?> showMealEditorSheet(
  BuildContext context, {
  required String planDayId,
  required MealType mealType,
  PlanMeal? existing,
}) {
  return showModalBottomSheet<PlanMeal>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => _MealEditorContent(
        planDayId: planDayId,
        mealType: mealType,
        existing: existing,
        scrollController: scrollController,
      ),
    ),
  );
}

class _MealEditorContent extends ConsumerStatefulWidget {
  const _MealEditorContent({
    required this.planDayId,
    required this.mealType,
    required this.existing,
    required this.scrollController,
  });

  final String planDayId;
  final MealType mealType;
  final PlanMeal? existing;
  final ScrollController scrollController;

  @override
  ConsumerState<_MealEditorContent> createState() => _MealEditorContentState();
}

class _MealEditorContentState extends ConsumerState<_MealEditorContent> {
  late bool _fromBank;
  String? _recipeId;
  bool _overrideQuantities = false;
  late final TextEditingController _nameCtrl;
  List<Ingredient> _ingredients = [];
  List<String> _steps = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _fromBank = m == null ? true : m.recipeId != null;
    _recipeId = m?.recipeId;
    _overrideQuantities = m?.customIngredients != null || m?.customSteps != null;
    _nameCtrl = TextEditingController(text: m?.customName ?? '');
    _ingredients = m?.customIngredients ?? [];
    _steps = m?.customSteps ?? [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _applyRecipeDefaults(Recipe recipe) {
    if (_ingredients.isEmpty) _ingredients = recipe.ingredients;
    if (_steps.isEmpty) _steps = recipe.steps;
  }

  void _submit() {
    if (_fromBank && _recipeId == null) return;
    if (!_fromBank && _nameCtrl.text.trim().isEmpty) return;

    final meal = PlanMeal(
      id: widget.existing?.id ?? 'new-${DateTime.now().microsecondsSinceEpoch}',
      planDayId: widget.planDayId,
      mealType: widget.mealType,
      recipeId: _fromBank ? _recipeId : null,
      customName: _fromBank ? null : _nameCtrl.text.trim(),
      customIngredients: (_fromBank && !_overrideQuantities) ? null : _ingredients,
      customSteps: (_fromBank && !_overrideQuantities) ? null : _steps,
      sortOrder: widget.existing?.sortOrder ?? 0,
    );
    Navigator.pop(context, meal);
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipeListProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.mealType.labelAr} — ${widget.existing == null ? 'إضافة' : 'تعديل'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('من البنك')),
                ButtonSegment(value: false, label: Text('إدخال يدوي')),
              ],
              selected: {_fromBank},
              onSelectionChanged: (s) => setState(() => _fromBank = s.first),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                if (_fromBank) ...[
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'ابحث عن أكلة...',
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                  const SizedBox(height: 8),
                  recipesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('تعذّر تحميل بنك الأكلات: $e'),
                    ),
                    data: (recipes) {
                      final filtered = recipes
                          .where((r) => _search.trim().isEmpty ||
                              r.name.toLowerCase().contains(_search.trim().toLowerCase()))
                          .toList();
                      if (filtered.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('لا توجد نتائج'),
                        );
                      }
                      return Column(
                        children: [
                          for (final recipe in filtered)
                            ListTile(
                              selected: _recipeId == recipe.id,
                              selectedTileColor: Colors.black.withValues(alpha: 0.04),
                              leading: Icon(
                                _recipeId == recipe.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                              ),
                              title: Text(recipe.name),
                              subtitle: Text(recipe.mealType.labelAr),
                              onTap: () => setState(() {
                                _recipeId = recipe.id;
                                _applyRecipeDefaults(recipe);
                              }),
                            ),
                        ],
                      );
                    },
                  ),
                  if (_recipeId != null) ...[
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _overrideQuantities,
                      title: const Text('تعديل الكمية لهذه الحالة'),
                      subtitle: const Text('بدون تغيير الوصفة الأصلية في البنك'),
                      onChanged: (v) {
                        setState(() {
                          _overrideQuantities = v;
                          if (v && _ingredients.isEmpty) {
                            final recipe =
                                recipesAsync.valueOrNull?.firstWhere((r) => r.id == _recipeId);
                            if (recipe != null) _applyRecipeDefaults(recipe);
                          }
                        });
                      },
                    ),
                    if (_overrideQuantities) ...[
                      const SizedBox(height: 8),
                      IngredientListEditor(
                        initial: _ingredients,
                        onChanged: (v) => _ingredients = v,
                      ),
                      const SizedBox(height: 16),
                      StepsListEditor(initial: _steps, onChanged: (v) => _steps = v),
                    ],
                  ],
                ] else ...[
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم الوجبة'),
                  ),
                  const SizedBox(height: 16),
                  IngredientListEditor(
                    initial: _ingredients,
                    onChanged: (v) => _ingredients = v,
                  ),
                  const SizedBox(height: 16),
                  StepsListEditor(initial: _steps, onChanged: (v) => _steps = v),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: FilledButton(
                onPressed: _submit,
                child: const Text('حفظ الوجبة'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
