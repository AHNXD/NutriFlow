import 'ingredient.dart';
import 'meal_type.dart';

class Recipe {
  final String id;
  final String name;
  final MealType mealType;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String? tip;
  final List<String> tags;
  final DateTime? createdAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.mealType,
    this.imageUrl,
    this.ingredients = const [],
    this.steps = const [],
    this.tip,
    this.tags = const [],
    this.createdAt,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) => Recipe(
    id: map['id'] as String,
    name: map['name'] as String? ?? '',
    mealType: MealType.fromValue(map['meal_type'] as String? ?? 'snack'),
    imageUrl: map['image_url'] as String?,
    ingredients: Ingredient.listFromJson(map['ingredients']),
    steps:
        (map['steps'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    tip: map['tip'] as String?,
    tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'] as String)
        : null,
  );

  /// Fields to send on insert/update. `id`/`created_at` are DB-managed.
  Map<String, dynamic> toInsertMap() => {
    'name': name,
    'meal_type': mealType.value,
    'image_url': imageUrl,
    'ingredients': Ingredient.listToJson(ingredients),
    'steps': steps,
    'tip': tip,
    'tags': tags,
  };

  Recipe copyWith({
    String? id,
    String? name,
    MealType? mealType,
    String? imageUrl,
    bool clearImageUrl = false,
    List<Ingredient>? ingredients,
    List<String>? steps,
    String? tip,
    List<String>? tags,
  }) => Recipe(
    id: id ?? this.id,
    name: name ?? this.name,
    mealType: mealType ?? this.mealType,
    imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
    ingredients: ingredients ?? this.ingredients,
    steps: steps ?? this.steps,
    tip: tip ?? this.tip,
    tags: tags ?? this.tags,
    createdAt: createdAt,
  );
}
