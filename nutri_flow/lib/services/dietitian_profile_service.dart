import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/dietitian_profile.dart';

const _bucket = 'dietitian-logo';
const _logoPath = 'logo.jpg';

bool get _compressionSupported =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

/// Single-row profile (name + clinic logo) embedded in every exported PDF —
/// see schema.sql's `dietitian_profile` table comment.
class DietitianProfileService {
  DietitianProfileService(this._client);
  final SupabaseClient _client;

  Future<DietitianProfile?> fetch() async {
    final rows = await _client.from('dietitian_profile').select().limit(1);
    if ((rows as List).isEmpty) return null;
    return DietitianProfile.fromMap(Map<String, dynamic>.from(rows.first as Map));
  }

  /// Creates the single row on first save, updates it on every save after.
  Future<DietitianProfile> save(DietitianProfile profile) async {
    if (profile.id.isEmpty) {
      final row = await _client
          .from('dietitian_profile')
          .insert(profile.toInsertMap())
          .select()
          .single();
      return DietitianProfile.fromMap(row);
    }
    final row = await _client
        .from('dietitian_profile')
        .update(profile.toInsertMap())
        .eq('id', profile.id)
        .select()
        .single();
    return DietitianProfile.fromMap(row);
  }

  Future<String> uploadLogo(Uint8List bytes) async {
    Uint8List toUpload = bytes;
    if (_compressionSupported) {
      try {
        toUpload = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 800,
          minHeight: 800,
          quality: 85,
          format: CompressFormat.jpeg,
        );
      } catch (e) {
        debugPrint('logo compression failed, uploading original: $e');
      }
    }

    await _client.storage.from(_bucket).uploadBinary(
          _logoPath,
          toUpload,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    final publicUrl = _client.storage.from(_bucket).getPublicUrl(_logoPath);
    return '$publicUrl?v=${const Uuid().v4()}';
  }
}
