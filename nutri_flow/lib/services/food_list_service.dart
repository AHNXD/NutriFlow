import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/food_list_item.dart';

class FoodListService {
  FoodListService(this._client);
  final SupabaseClient _client;

  Future<List<FoodListItem>> fetchAll() async {
    final rows = await _client.from('food_lists').select().order('category');
    return (rows as List)
        .map((r) => FoodListItem.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<FoodListItem> create(FoodListItem item) async {
    final row = await _client
        .from('food_lists')
        .insert(item.toInsertMap())
        .select()
        .single();
    return FoodListItem.fromMap(row);
  }

  Future<FoodListItem> update(FoodListItem item) async {
    final row = await _client
        .from('food_lists')
        .update(item.toInsertMap())
        .eq('id', item.id)
        .select()
        .single();
    return FoodListItem.fromMap(row);
  }

  Future<void> delete(String id) =>
      _client.from('food_lists').delete().eq('id', id);
}
