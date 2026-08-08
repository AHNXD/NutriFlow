import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tip.dart';
import '../services/supabase_client_provider.dart';
import '../services/tips_service.dart';

final tipsServiceProvider = Provider<TipsService>((ref) {
  return TipsService(ref.watch(supabaseClientProvider));
});

final tipListProvider = AsyncNotifierProvider<TipListNotifier, List<Tip>>(
  TipListNotifier.new,
);

class TipListNotifier extends AsyncNotifier<List<Tip>> {
  TipsService get _service => ref.read(tipsServiceProvider);

  @override
  Future<List<Tip>> build() => _service.fetchTips();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.fetchTips);
  }

  Future<void> create(Tip tip) async {
    final created = await _service.createTip(tip);
    state = AsyncData([created, ...state.valueOrNull ?? []]);
  }

  Future<void> updateTip(Tip tip) async {
    final updated = await _service.updateTip(tip);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final t in current)
        if (t.id == updated.id) updated else t,
    ]);
  }

  Future<void> delete(String id) async {
    await _service.deleteTip(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
  }
}

final motivationalMessageListProvider =
    AsyncNotifierProvider<
      MotivationalMessageListNotifier,
      List<MotivationalMessage>
    >(MotivationalMessageListNotifier.new);

class MotivationalMessageListNotifier
    extends AsyncNotifier<List<MotivationalMessage>> {
  TipsService get _service => ref.read(tipsServiceProvider);

  @override
  Future<List<MotivationalMessage>> build() =>
      _service.fetchMotivationalMessages();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.fetchMotivationalMessages);
  }

  Future<void> create(MotivationalMessage m) async {
    final created = await _service.createMotivationalMessage(m);
    state = AsyncData([created, ...state.valueOrNull ?? []]);
  }

  Future<void> updateMessage(MotivationalMessage m) async {
    final updated = await _service.updateMotivationalMessage(m);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final x in current)
        if (x.id == updated.id) updated else x,
    ]);
  }

  Future<void> delete(String id) async {
    await _service.deleteMotivationalMessage(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((x) => x.id != id).toList());
  }
}
