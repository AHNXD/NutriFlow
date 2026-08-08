import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/env.dart';

class PdfServiceNotConfiguredException implements Exception {}

class PdfExportService {
  /// Calls the FastAPI PDF service (spec §6: `POST /generate-plan-pdf`) and
  /// returns the raw PDF bytes. Throws [PdfServiceNotConfiguredException] if
  /// the app wasn't built with `--dart-define=PDF_SERVICE_URL=...`, and
  /// throws [http.ClientException]/[Exception] on network/HTTP failure —
  /// callers should surface those as retryable errors.
  Future<Uint8List> generatePlanPdf(String planId) async {
    if (!Env.isPdfServiceConfigured) {
      throw PdfServiceNotConfiguredException();
    }
    final uri = Uri.parse('${Env.pdfServiceUrl}/generate-plan-pdf');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: '{"plan_id": "$planId"}',
    );
    if (response.statusCode != 200) {
      throw Exception(
        'فشل توليد الملف (${response.statusCode}): ${response.body}',
      );
    }
    return response.bodyBytes;
  }
}
