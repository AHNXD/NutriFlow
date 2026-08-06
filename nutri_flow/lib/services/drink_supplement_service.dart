import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/helper_drink.dart';
import '../models/supplement.dart';

class HelperDrinkService {
  HelperDrinkService(this._client);
  final SupabaseClient _client;

  Future<List<HelperDrink>> fetchAll() async {
    final rows = await _client
        .from('helper_drinks')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => HelperDrink.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<HelperDrink> create(HelperDrink drink) async {
    final row = await _client
        .from('helper_drinks')
        .insert(drink.toInsertMap())
        .select()
        .single();
    return HelperDrink.fromMap(row);
  }

  Future<HelperDrink> update(HelperDrink drink) async {
    final row = await _client
        .from('helper_drinks')
        .update(drink.toInsertMap())
        .eq('id', drink.id)
        .select()
        .single();
    return HelperDrink.fromMap(row);
  }

  Future<void> delete(String id) =>
      _client.from('helper_drinks').delete().eq('id', id);
}

class SupplementService {
  SupplementService(this._client);
  final SupabaseClient _client;

  Future<List<Supplement>> fetchAll() async {
    final rows = await _client
        .from('supplements')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Supplement.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<Supplement> create(Supplement s) async {
    final row = await _client
        .from('supplements')
        .insert(s.toInsertMap())
        .select()
        .single();
    return Supplement.fromMap(row);
  }

  Future<Supplement> update(Supplement s) async {
    final row = await _client
        .from('supplements')
        .update(s.toInsertMap())
        .eq('id', s.id)
        .select()
        .single();
    return Supplement.fromMap(row);
  }

  Future<void> delete(String id) =>
      _client.from('supplements').delete().eq('id', id);
}
