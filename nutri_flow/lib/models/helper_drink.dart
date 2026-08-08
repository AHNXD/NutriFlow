import 'ingredient.dart';

class HelperDrink {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String? timing;

  const HelperDrink({
    required this.id,
    required this.name,
    this.ingredients = const [],
    this.steps = const [],
    this.timing,
  });

  factory HelperDrink.fromMap(Map<String, dynamic> map) => HelperDrink(
    id: map['id'] as String,
    name: map['name'] as String? ?? '',
    ingredients: Ingredient.listFromJson(map['ingredients']),
    steps:
        (map['steps'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    timing: map['timing'] as String?,
  );

  Map<String, dynamic> toInsertMap() => {
    'name': name,
    'ingredients': Ingredient.listToJson(ingredients),
    'steps': steps,
    'timing': timing,
  };
}
