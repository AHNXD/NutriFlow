import 'package:flutter/material.dart';

/// One PDF color theme. Keep this catalog in sync with the Python side —
/// `NutriFlow-backend/app/themes.py` — same `id`s, same hex values, since
/// the `id` is what gets stored in `plans.theme` and sent to the PDF
/// service to pick the matching CSS palette.
class PdfTheme {
  final String id;
  final String labelAr;
  final Color primary;
  final Color secondary;

  const PdfTheme({
    required this.id,
    required this.labelAr,
    required this.primary,
    required this.secondary,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [primary, secondary],
      );
}

class PdfThemes {
  PdfThemes._();

  static const emerald = PdfTheme(
    id: 'emerald',
    labelAr: 'زمردي',
    primary: Color(0xFF0F9D75),
    secondary: Color(0xFF14B8A6),
  );

  static const ocean = PdfTheme(
    id: 'ocean',
    labelAr: 'محيطي',
    primary: Color(0xFF0284C7),
    secondary: Color(0xFF38BDF8),
  );

  static const sunset = PdfTheme(
    id: 'sunset',
    labelAr: 'غروب',
    primary: Color(0xFFEA580C),
    secondary: Color(0xFFF472B6),
  );

  static const orchid = PdfTheme(
    id: 'orchid',
    labelAr: 'بنفسجي',
    primary: Color(0xFF4F46E5),
    secondary: Color(0xFFA855F7),
  );

  static const rose = PdfTheme(
    id: 'rose',
    labelAr: 'وردي',
    primary: Color(0xFFE11D48),
    secondary: Color(0xFFFB7185),
  );

  static const gold = PdfTheme(
    id: 'gold',
    labelAr: 'ذهبي',
    primary: Color(0xFFD97706),
    secondary: Color(0xFFFBBF24),
  );

  static const all = [emerald, ocean, sunset, orchid, rose, gold];

  static PdfTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => emerald);
}
