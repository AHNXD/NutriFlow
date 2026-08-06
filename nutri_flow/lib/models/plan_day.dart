import 'plan_meal.dart';

class PlanDay {
  final String id;
  final String planId;
  final int dayNumber;
  final String? motivationalText;
  final List<PlanMeal> meals;

  const PlanDay({
    required this.id,
    required this.planId,
    required this.dayNumber,
    this.motivationalText,
    this.meals = const [],
  });

  factory PlanDay.fromMap(Map<String, dynamic> map, {List<PlanMeal> meals = const []}) =>
      PlanDay(
        id: map['id'] as String,
        planId: map['plan_id'] as String,
        dayNumber: (map['day_number'] as num?)?.toInt() ?? 1,
        motivationalText: map['motivational_text'] as String?,
        meals: meals,
      );

  Map<String, dynamic> toInsertMap() => {
        'plan_id': planId,
        'day_number': dayNumber,
        'motivational_text': motivationalText,
      };
}
