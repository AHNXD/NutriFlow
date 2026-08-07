import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plan.dart';
import '../models/plan_day.dart';
import '../models/plan_meal.dart';
import '../models/plan_supplement.dart';
import '../services/plan_service.dart';
import '../services/supabase_client_provider.dart';

final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService(ref.watch(supabaseClientProvider));
});

final planListProvider =
    AsyncNotifierProvider<PlanListNotifier, List<Plan>>(PlanListNotifier.new);

class PlanListNotifier extends AsyncNotifier<List<Plan>> {
  PlanService get _service => ref.read(planServiceProvider);

  @override
  Future<List<Plan>> build() => _service.fetchPlans();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.fetchPlans);
  }

  Future<Plan> create(Plan plan) async {
    final created = await _service.createPlan(plan);
    state = AsyncData([created, ...state.valueOrNull ?? []]);
    return created;
  }

  Future<void> delete(String id) async {
    await _service.deletePlan(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((p) => p.id != id).toList());
  }
}

/// Aggregate view-model for the plan detail / day-builder screen: the plan,
/// its days (each carrying its own meals), the attached helper-drink ids,
/// and the attached supplements.
class PlanDetailState {
  final Plan plan;
  final List<PlanDay> days;
  final List<String> drinkIds;
  final List<PlanSupplement> supplements;

  const PlanDetailState({
    required this.plan,
    required this.days,
    required this.drinkIds,
    required this.supplements,
  });

  PlanDetailState copyWith({
    Plan? plan,
    List<PlanDay>? days,
    List<String>? drinkIds,
    List<PlanSupplement>? supplements,
  }) =>
      PlanDetailState(
        plan: plan ?? this.plan,
        days: days ?? this.days,
        drinkIds: drinkIds ?? this.drinkIds,
        supplements: supplements ?? this.supplements,
      );
}

final planDetailProvider = AsyncNotifierProviderFamily<PlanDetailNotifier,
    PlanDetailState, String>(PlanDetailNotifier.new);

class PlanDetailNotifier extends FamilyAsyncNotifier<PlanDetailState, String> {
  PlanService get _service => ref.read(planServiceProvider);
  String get _planId => arg;

  @override
  Future<PlanDetailState> build(String arg) => _load();

  Future<PlanDetailState> _load() async {
    final plan = await _service.fetchPlanById(_planId);
    final days = await _service.fetchPlanDays(_planId);
    final withMeals = <PlanDay>[];
    for (final day in days) {
      final meals = await _service.fetchMealsForDay(day.id);
      withMeals.add(PlanDay.fromMap(
        {
          'id': day.id,
          'plan_id': day.planId,
          'day_number': day.dayNumber,
          'motivational_text': day.motivationalText,
        },
        meals: meals,
      ));
    }
    final drinkIds = await _service.fetchPlanDrinkIds(_planId);
    final supplements = await _service.fetchPlanSupplements(_planId);
    return PlanDetailState(
      plan: plan,
      days: withMeals,
      drinkIds: drinkIds,
      supplements: supplements,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> updateTheme(String theme) async {
    final updated = await _service.updateTheme(_planId, theme);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(plan: updated));
  }

  Future<void> setDayMotivationalText(String dayId, String? text) async {
    await _service.updatePlanDayMotivationalText(dayId, text);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(days: [
      for (final d in current.days)
        if (d.id == dayId)
          PlanDay(id: d.id, planId: d.planId, dayNumber: d.dayNumber, motivationalText: text, meals: d.meals)
        else
          d,
    ]));
  }

  Future<void> saveMeal(PlanMeal meal) async {
    final saved = meal.id.isEmpty || meal.id.startsWith('new-')
        ? await _service.createMeal(meal)
        : await _service.updateMeal(meal);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(days: [
      for (final d in current.days)
        if (d.id == meal.planDayId)
          PlanDay(
            id: d.id,
            planId: d.planId,
            dayNumber: d.dayNumber,
            motivationalText: d.motivationalText,
            meals: [
              for (final m in d.meals) if (m.id == saved.id) saved else m,
              if (!d.meals.any((m) => m.id == saved.id)) saved,
            ],
          )
        else
          d,
    ]));
  }

  Future<void> deleteMeal(String planDayId, String mealId) async {
    await _service.deleteMeal(mealId);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(days: [
      for (final d in current.days)
        if (d.id == planDayId)
          PlanDay(
            id: d.id,
            planId: d.planId,
            dayNumber: d.dayNumber,
            motivationalText: d.motivationalText,
            meals: d.meals.where((m) => m.id != mealId).toList(),
          )
        else
          d,
    ]));
  }

  Future<void> setDrinks(List<String> drinkIds) async {
    await _service.setPlanDrinks(_planId, drinkIds);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(drinkIds: drinkIds));
  }

  Future<void> addSupplement(PlanSupplement s) async {
    final created = await _service.createPlanSupplement(s);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(supplements: [...current.supplements, created]));
  }

  Future<void> updateSupplement(PlanSupplement s) async {
    final updated = await _service.updatePlanSupplement(s);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(supplements: [
      for (final x in current.supplements) if (x.id == updated.id) updated else x,
    ]));
  }

  Future<void> removeSupplement(String id) async {
    await _service.deletePlanSupplement(id);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      supplements: current.supplements.where((s) => s.id != id).toList(),
    ));
  }
}
