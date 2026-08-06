import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tip.dart';

class TipsService {
  TipsService(this._client);
  final SupabaseClient _client;

  Future<List<Tip>> fetchTips() async {
    final rows =
        await _client.from('tips').select().order('category');
    return (rows as List)
        .map((r) => Tip.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<Tip> createTip(Tip tip) async {
    final row =
        await _client.from('tips').insert(tip.toInsertMap()).select().single();
    return Tip.fromMap(row);
  }

  Future<Tip> updateTip(Tip tip) async {
    final row = await _client
        .from('tips')
        .update(tip.toInsertMap())
        .eq('id', tip.id)
        .select()
        .single();
    return Tip.fromMap(row);
  }

  Future<void> deleteTip(String id) =>
      _client.from('tips').delete().eq('id', id);

  Future<List<MotivationalMessage>> fetchMotivationalMessages() async {
    final rows = await _client
        .from('motivational_messages')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) =>
            MotivationalMessage.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<MotivationalMessage> createMotivationalMessage(
      MotivationalMessage m) async {
    final row = await _client
        .from('motivational_messages')
        .insert(m.toInsertMap())
        .select()
        .single();
    return MotivationalMessage.fromMap(row);
  }

  Future<MotivationalMessage> updateMotivationalMessage(
      MotivationalMessage m) async {
    final row = await _client
        .from('motivational_messages')
        .update(m.toInsertMap())
        .eq('id', m.id)
        .select()
        .single();
    return MotivationalMessage.fromMap(row);
  }

  Future<void> deleteMotivationalMessage(String id) =>
      _client.from('motivational_messages').delete().eq('id', id);
}
