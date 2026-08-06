import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/recipe.dart';

const _bucket = 'recipe-images';

/// flutter_image_compress only ships native codecs for Android/iOS/macOS/Web.
/// On Windows/Linux desktop we skip compression and upload the original
/// bytes rather than crash — the spec's storage budget concern (§4) is a
/// nice-to-have, not a hard requirement, and this app targets desktop too.
bool get _compressionSupported =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

class RecipeService {
  RecipeService(this._client);
  final SupabaseClient _client;

  Future<List<Recipe>> fetchAll() async {
    final rows = await _client
        .from('recipes')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Recipe.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<Recipe> create(Recipe recipe) async {
    final row = await _client
        .from('recipes')
        .insert(recipe.toInsertMap())
        .select()
        .single();
    return Recipe.fromMap(row);
  }

  Future<Recipe> update(Recipe recipe) async {
    final row = await _client
        .from('recipes')
        .update(recipe.toInsertMap())
        .eq('id', recipe.id)
        .select()
        .single();
    return Recipe.fromMap(row);
  }

  Future<void> delete(String id) async {
    // Best-effort image cleanup; do not block the row delete on it.
    try {
      await _client.storage.from(_bucket).remove(['$id.jpg']);
    } catch (e) {
      debugPrint('recipe image cleanup failed for $id: $e');
    }
    await _client.from('recipes').delete().eq('id', id);
  }

  /// Compresses (where supported) and uploads [bytes] as the image for
  /// [recipeId], returning a fresh public URL (cache-busted so the UI
  /// refreshes immediately instead of showing a stale cached image).
  Future<String> uploadImage({
    required String recipeId,
    required Uint8List bytes,
  }) async {
    Uint8List toUpload = bytes;
    if (_compressionSupported) {
      try {
        toUpload = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 78,
          format: CompressFormat.jpeg,
        );
      } catch (e) {
        debugPrint('image compression failed, uploading original: $e');
      }
    }

    final path = '$recipeId.jpg';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          toUpload,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);
    // Cache-bust so widgets keyed on URL (cached_network_image) reload after
    // a re-upload to the same recipe id.
    return '$publicUrl?v=${const Uuid().v4()}';
  }
}
