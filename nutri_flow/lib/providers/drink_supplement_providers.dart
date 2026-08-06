import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/helper_drink.dart';
import '../models/supplement.dart';
import '../services/drink_supplement_service.dart';
import '../services/supabase_client_provider.dart';

final helperDrinkServiceProvider = Provider<HelperDrinkService>((ref) {
  return HelperDrinkService(ref.watch(supabaseClientProvider));
});

final helperDrinkListProvider =
    AsyncNotifierProvider<HelperDrinkListNotifier, List<HelperDrink>>(
  HelperDrinkListNotifier.new,
);

class HelperDrinkListNotifier extends AsyncNotifier<List<HelperDrink>> {
  HelperDrinkService get _service => ref.read(helperDrinkServiceProvider);

  @override
  Future<List<HelperDrink>> build() => _service.fetchAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.fetchAll);
  }

  Future<void> create(HelperDrink drink) async {
    final created = await _service.create(drink);
    state = AsyncData([created, ...state.valueOrNull ?? []]);
  }

  Future<void> updateDrink(HelperDrink drink) async {
    final updated = await _service.update(drink);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final d in current) if (d.id == updated.id) updated else d,
    ]);
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((d) => d.id != id).toList());
  }
}

final supplementServiceProvider = Provider<SupplementService>((ref) {
  return SupplementService(ref.watch(supabaseClientProvider));
});

final supplementListProvider =
    AsyncNotifierProvider<SupplementListNotifier, List<Supplement>>(
  SupplementListNotifier.new,
);

class SupplementListNotifier extends AsyncNotifier<List<Supplement>> {
  SupplementService get _service => ref.read(supplementServiceProvider);

  @override
  Future<List<Supplement>> build() => _service.fetchAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.fetchAll);
  }

  Future<void> create(Supplement s) async {
    final created = await _service.create(s);
    state = AsyncData([created, ...state.valueOrNull ?? []]);
  }

  Future<void> updateSupplement(Supplement s) async {
    final updated = await _service.update(s);
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
