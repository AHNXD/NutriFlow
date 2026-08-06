import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_type.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/supabase_client_provider.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService(ref.watch(supabaseClientProvider));
});

final recipeListProvider =
    AsyncNotifierProvider<RecipeListNotifier, List<Recipe>>(
  RecipeListNotifier.new,
);

class RecipeListNotifier extends AsyncNotifier<List<Recipe>> {
  RecipeService get _service => ref.read(recipeServiceProvider);

  @override
  Future<List<Recipe>> build() => _service.fetchAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.fetchAll);
  }

  Future<Recipe> createRecipe(Recipe recipe) async {
    final created = await _service.create(recipe);
    state = AsyncData([created, ...state.valueOrNull ?? []]);
    return created;
  }

  Future<Recipe> updateRecipe(Recipe recipe) async {
    final updated = await _service.update(recipe);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final r in current) if (r.id == updated.id) updated else r,
    ]);
    return updated;
  }

  Future<void> deleteRecipe(String id) async {
    await _service.delete(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((r) => r.id != id).toList());
  }

  Future<String> uploadImage({
    required String recipeId,
    required Uint8List bytes,
  }) {
    return _service.uploadImage(recipeId: recipeId, bytes: bytes);
  }
}

/// UI filter state for the recipe bank list (search text + meal type).
class RecipeBankFilter {
  final String query;
  final MealType? mealType;
  const RecipeBankFilter({this.query = '', this.mealType});

  RecipeBankFilter copyWith({String? query, MealType? mealType, bool clearMealType = false}) =>
      RecipeBankFilter(
        query: query ?? this.query,
        mealType: clearMealType ? null : (mealType ?? this.mealType),
      );
}

final recipeBankFilterProvider =
    StateProvider<RecipeBankFilter>((ref) => const RecipeBankFilter());

final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipes = ref.watch(recipeListProvider);
  final filter = ref.watch(recipeBankFilterProvider);
  return recipes.whenData((list) {
    return list.where((r) {
      final matchesType = filter.mealType == null || r.mealType == filter.mealType;
      final matchesQuery = filter.query.trim().isEmpty ||
          r.name.toLowerCase().contains(filter.query.trim().toLowerCase()) ||
          r.tags.any((t) => t.toLowerCase().contains(filter.query.trim().toLowerCase()));
      return matchesType && matchesQuery;
    }).toList();
  });
});
