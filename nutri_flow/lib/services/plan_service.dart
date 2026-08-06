import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plan.dart';
import '../models/plan_day.dart';
import '../models/plan_meal.dart';
import '../models/plan_supplement.dart';

class PlanService {
  PlanService(this._client);
  final SupabaseClient _client;

  Future<List<Plan>> fetchPlans() async {
    final rows = await _client
        .from('plans')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Plan.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  /// Creates the plan row and seeds one `plan_days` row per day (1..duration).
  Future<Plan> createPlan(Plan plan) async {
    final row = await _client
        .from('plans')
        .insert(plan.toInsertMap())
        .select()
        .single();
    final created = Plan.fromMap(row);
    await _client.from('plan_days').insert([
      for (var day = 1; day <= created.durationDays; day++)
        {'plan_id': created.id, 'day_number': day},
    ]);
    return created;
  }

  Future<void> deletePlan(String id) =>
      _client.from('plans').delete().eq('id', id);

  Future<Plan> fetchPlanById(String id) async {
    final row = await _client.from('plans').select().eq('id', id).single();
    return Plan.fromMap(row);
  }

  Future<List<PlanDay>> fetchPlanDays(String planId) async {
    final rows = await _client
        .from('plan_days')
        .select()
        .eq('plan_id', planId)
        .order('day_number');
    return (rows as List)
        .map((r) => PlanDay.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<void> updatePlanDayMotivationalText(String dayId, String? text) =>
      _client
          .from('plan_days')
          .update({'motivational_text': text}).eq('id', dayId);

  Future<List<PlanMeal>> fetchMealsForDay(String planDayId) async {
    final rows = await _client
        .from('plan_meals')
        .select()
        .eq('plan_day_id', planDayId)
        .order('sort_order');
    return (rows as List)
        .map((r) => PlanMeal.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<PlanMeal> createMeal(PlanMeal meal) async {
    final row = await _client
        .from('plan_meals')
        .insert(meal.toInsertMap())
        .select()
        .single();
    return PlanMeal.fromMap(row);
  }

  Future<PlanMeal> updateMeal(PlanMeal meal) async {
    final row = await _client
        .from('plan_meals')
        .update(meal.toInsertMap())
        .eq('id', meal.id)
        .select()
        .single();
    return PlanMeal.fromMap(row);
  }

  Future<void> deleteMeal(String id) =>
      _client.from('plan_meals').delete().eq('id', id);

  Future<List<String>> fetchPlanDrinkIds(String planId) async {
    final rows =
        await _client.from('plan_drinks').select('drink_id').eq('plan_id', planId);
    return (rows as List).map((r) => r['drink_id'] as String).toList();
  }

  /// Replaces the full set of attached drinks for [planId] with [drinkIds].
  Future<void> setPlanDrinks(String planId, List<String> drinkIds) async {
    await _client.from('plan_drinks').delete().eq('plan_id', planId);
    if (drinkIds.isEmpty) return;
    await _client.from('plan_drinks').insert([
      for (final id in drinkIds) {'plan_id': planId, 'drink_id': id},
    ]);
  }

  Future<List<PlanSupplement>> fetchPlanSupplements(String planId) async {
    final rows =
        await _client.from('plan_supplements').select().eq('plan_id', planId);
    return (rows as List)
        .map((r) => PlanSupplement.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<PlanSupplement> createPlanSupplement(PlanSupplement s) async {
    final row = await _client
        .from('plan_supplements')
        .insert(s.toInsertMap())
        .select()
        .single();
    return PlanSupplement.fromMap(row);
  }

  Future<PlanSupplement> updatePlanSupplement(PlanSupplement s) async {
    final row = await _client
        .from('plan_supplements')
        .update(s.toInsertMap())
        .eq('id', s.id)
        .select()
        .single();
    return PlanSupplement.fromMap(row);
  }

  Future<void> deletePlanSupplement(String id) =>
      _client.from('plan_supplements').delete().eq('id', id);
}
