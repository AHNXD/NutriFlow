class Supplement {
  final String id;
  final String name;
  final String? defaultDose;
  final String? defaultTiming;
  final String? defaultNotes;

  const Supplement({
    required this.id,
    required this.name,
    this.defaultDose,
    this.defaultTiming,
    this.defaultNotes,
  });

  factory Supplement.fromMap(Map<String, dynamic> map) => Supplement(
    id: map['id'] as String,
    name: map['name'] as String? ?? '',
    defaultDose: map['default_dose'] as String?,
    defaultTiming: map['default_timing'] as String?,
    defaultNotes: map['default_notes'] as String?,
  );

  Map<String, dynamic> toInsertMap() => {
    'name': name,
    'default_dose': defaultDose,
    'default_timing': defaultTiming,
    'default_notes': defaultNotes,
  };
}
