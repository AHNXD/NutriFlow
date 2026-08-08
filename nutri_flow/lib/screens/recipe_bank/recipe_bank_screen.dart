import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/meal_type.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/layout.dart';
import 'recipe_form_screen.dart';

class RecipeBankScreen extends ConsumerWidget {
  const RecipeBankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredRecipesProvider);
    final filter = ref.watch(recipeBankFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('بنك الأكلات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('أكلة جديدة'),
      ),
      body: PageBody(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'بحث بالاسم أو الوسم...',
                ),
                onChanged: (v) => ref
                    .read(recipeBankFilterProvider.notifier)
                    .update((s) => s.copyWith(query: v)),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                children: [
                  _FilterChip(
                    label: 'الكل',
                    selected: filter.mealType == null,
                    onTap: () => ref
                        .read(recipeBankFilterProvider.notifier)
                        .update((s) => s.copyWith(clearMealType: true)),
                  ),
                  for (final type in MealType.values)
                    _FilterChip(
                      label: type.labelAr,
                      selected: filter.mealType == type,
                      onTap: () => ref
                          .read(recipeBankFilterProvider.notifier)
                          .update((s) => s.copyWith(mealType: type)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView<Recipe>(
                value: filtered,
                onRetry: () => ref.read(recipeListProvider.notifier).refresh(),
                emptyBuilder: (context) => const EmptyState(
                  icon: Icons.restaurant_menu,
                  title: 'لا توجد أكلات بعد',
                  subtitle: 'يمكن إضافة أول وصفة من زر "أكلة جديدة"',
                ),
                data: (context, recipes) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(recipeListProvider.notifier).refresh(),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                    itemCount: recipes.length,
                    itemBuilder: (context, i) =>
                        _RecipeCard(recipe: recipes[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeFormScreen(existing: recipe)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                    Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _ImageFallback(),
                    )
                  else
                    const _ImageFallback(),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: const CircleBorder(),
                      child: IconButton(
                        iconSize: 18,
                        color: Colors.white,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await confirmDelete(
                            context,
                            title: 'حذف "${recipe.name}"؟',
                          );
                          if (confirmed) {
                            await ref
                                .read(recipeListProvider.notifier)
                                .deleteRecipe(recipe.id);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recipe.mealType.labelAr,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.05),
      child: const Icon(Icons.restaurant, color: Colors.black26, size: 40),
    );
  }
}
