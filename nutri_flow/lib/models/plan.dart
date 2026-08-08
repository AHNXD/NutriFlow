class Plan {
  final String id;
  final String patientName;
  final String dietitianName;
  final int durationDays;
  final int? fastingHours;
  final String? fastingNotes;
  final String? generalNotes;
  /// PDF colour palette id — see `lib/theme/pdf_themes.dart`.
  final String theme;

  /// PDF design template id — see `lib/theme/pdf_layouts.dart`. Independent
  /// of [theme]: any design renders in any palette.
  final String pdfLayout;
  final DateTime? createdAt;

  const Plan({
    required this.id,
    required this.patientName,
    required this.dietitianName,
    this.durationDays = 7,
    this.fastingHours,
    this.fastingNotes,
    this.generalNotes,
    this.theme = 'emerald',
    this.pdfLayout = 'aurora',
    this.createdAt,
  });

  factory Plan.fromMap(Map<String, dynamic> map) => Plan(
        id: map['id'] as String,
        patientName: map['patient_name'] as String? ?? '',
        dietitianName: map['dietitian_name'] as String? ?? '',
        durationDays: (map['duration_days'] as num?)?.toInt() ?? 7,
        fastingHours: (map['fasting_hours'] as num?)?.toInt(),
        fastingNotes: map['fasting_notes'] as String?,
        generalNotes: map['general_notes'] as String?,
        theme: map['theme'] as String? ?? 'emerald',
        pdfLayout: map['pdf_layout'] as String? ?? 'aurora',
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toInsertMap() => {
        'patient_name': patientName,
        'dietitian_name': dietitianName,
        'duration_days': durationDays,
        'fasting_hours': fastingHours,
        'fasting_notes': fastingNotes,
        'general_notes': generalNotes,
        'theme': theme,
        'pdf_layout': pdfLayout,
      };
}
