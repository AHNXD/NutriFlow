import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Call once from `main()` before `runApp`. No-ops (throws) if the app was
/// built without `--dart-define=SUPABASE_URL=...` — callers should check
/// `Env.isSupabaseConfigured` first and show the setup screen instead.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    // Named `anonKey` in the Supabase dashboard's older "API keys" UI;
    // supabase_flutter's parameter is `publishableKey` in newer versions —
    // same value, new name (see Env.supabaseAnonKey doc comment).
    publishableKey: Env.supabaseAnonKey,
  );
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
