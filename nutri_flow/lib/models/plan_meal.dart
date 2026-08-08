import 'ingredient.dart';
import 'meal_type.dart';

/// A single meal slot inside a plan day. Either points at a bank `Recipe`
/// (`recipeId` set) or is fully hand-written (`customName`/`customIngredients`
/// /`customSteps` set, `recipeId` null) — see schema.sql comment on
/// `plan_meals`. `customIngredients`/`customSteps` may also be set *together*
/// with `recipeId` when the dietitian pulled a bank recipe and tweaked the
/// quantities for this specific patient, without touching the original.
class PlanMeal {
  final String id;
  final String planDayId;
  final MealType mealType;
  final String? recipeId;
  final String? customName;
  final List<Ingredient>? customIngredients;
  final List<String>? customSteps;
  final int sortOrder;

  const PlanMeal({
    required this.id,
    required this.planDayId,
    required this.mealType,
    this.recipeId,
    this.customName,
    this.customIngredients,
    this.customSteps,
    this.sortOrder = 0,
  });

  factory PlanMeal.fromMap(Map<String, dynamic> map) => PlanMeal(
    id: map['id'] as String,
    planDayId: map['plan_day_id'] as String,
    mealType: MealType.fromValue(map['meal_type'] as String? ?? 'snack'),
    recipeId: map['recipe_id'] as String?,
    customName: map['custom_name'] as String?,
    customIngredients: map['custom_ingredients'] != null
        ? Ingredient.listFromJson(map['custom_ingredients'])
        : null,
    customSteps: (map['custom_steps'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toInsertMap() => {
    'plan_day_id': planDayId,
    'meal_type': mealType.value,
    'recipe_id': recipeId,
    'custom_name': customName,
    'custom_ingredients': customIngredients != null
        ? Ingredient.listToJson(customIngredients!)
        : null,
    'custom_steps': customSteps,
    'sort_order': sortOrder,
  };
}
