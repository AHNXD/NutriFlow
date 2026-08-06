import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food_list_item.dart';
import '../services/food_list_service.dart';
import '../services/supabase_client_provider.dart';

final foodListServiceProvider = Provider<FoodListService>((ref) {
  return FoodListService(ref.watch(supabaseClientProvider));
});

final foodListProvider =
    AsyncNotifierProvider<FoodListNotifier, List<FoodListItem>>(
  FoodListNotifier.new,
);

class FoodListNotifier extends AsyncNotifier<List<FoodListItem>> {
  FoodListService get _service => ref.read(foodListServiceProvider);

  @override
  Future<List<FoodListItem>> build() => _service.fetchAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.fetchAll);
  }

  Future<void> create(FoodListItem item) async {
    final created = await _service.create(item);
    state = AsyncData([created, ...state.valueOrNull ?? []]);
  }

  Future<void> updateItem(FoodListItem item) async {
    final updated = await _service.update(item);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final x in current) if (x.id == updated.id) updated else x,
    ]);
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((x) => x.id != id).toList());
  }
}
