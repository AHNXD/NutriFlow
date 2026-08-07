import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dietitian_profile.dart';
import '../services/dietitian_profile_service.dart';
import '../services/supabase_client_provider.dart';

final dietitianProfileServiceProvider = Provider<DietitianProfileService>((ref) {
  return DietitianProfileService(ref.watch(supabaseClientProvider));
});

final dietitianProfileProvider =
    AsyncNotifierProvider<DietitianProfileNotifier, DietitianProfile?>(
  DietitianProfileNotifier.new,
);

class DietitianProfileNotifier extends AsyncNotifier<DietitianProfile?> {
  DietitianProfileService get _service => ref.read(dietitianProfileServiceProvider);

  @override
  Future<DietitianProfile?> build() => _service.fetch();

  Future<void> save({required String? name, required String? logoUrl}) async {
    final current = state.valueOrNull;
    final saved = await _service.save(
      DietitianProfile(id: current?.id ?? '', name: name, logoUrl: logoUrl),
    );
    state = AsyncData(saved);
  }

  Future<String> uploadLogo(Uint8List bytes) => _service.uploadLogo(bytes);
}
