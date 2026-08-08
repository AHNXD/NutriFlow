/// Meal types used by `recipes.meal_type` and `plan_meals.meal_type`.
/// Recipes additionally allow `drink`, which plan meals do not (drinks live
/// in `helper_drinks` / `plan_drinks` instead — see schema.sql).
enum MealType {
  breakfast('breakfast', 'فطور'),
  lunch('lunch', 'غداء'),
  dinner('dinner', 'عشاء'),
  salad('salad', 'سلطة'),
  snack('snack', 'سناك'),
  drink('drink', 'مشروب');

  final String value;
  final String labelAr;

  const MealType(this.value, this.labelAr);

  static MealType fromValue(String value) => MealType.values.firstWhere(
    (e) => e.value == value,
    orElse: () => MealType.snack,
  );

  /// Meal types valid for `plan_meals` (excludes `drink`).
  static const planMealTypes = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
    MealType.salad,
    MealType.snack,
  ];
}
