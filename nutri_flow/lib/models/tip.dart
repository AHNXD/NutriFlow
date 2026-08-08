enum TipCategory {
  general('general', 'عام'),
  hunger('hunger', 'الجوع'),
  hydration('hydration', 'الترطيب'),
  motivation('motivation', 'تحفيز');

  final String value;
  final String labelAr;
  const TipCategory(this.value, this.labelAr);

  static TipCategory fromValue(String? value) => TipCategory.values.firstWhere(
    (e) => e.value == value,
    orElse: () => TipCategory.general,
  );
}

class Tip {
  final String id;
  final String text;
  final TipCategory category;

  const Tip({
    required this.id,
    required this.text,
    this.category = TipCategory.general,
  });

  factory Tip.fromMap(Map<String, dynamic> map) => Tip(
    id: map['id'] as String,
    text: map['text'] as String? ?? '',
    category: TipCategory.fromValue(map['category'] as String?),
  );

  Map<String, dynamic> toInsertMap() => {
    'text': text,
    'category': category.value,
  };
}

class MotivationalMessage {
  final String id;
  final String text;

  const MotivationalMessage({required this.id, required this.text});

  factory MotivationalMessage.fromMap(Map<String, dynamic> map) =>
      MotivationalMessage(
        id: map['id'] as String,
        text: map['text'] as String? ?? '',
      );

  Map<String, dynamic> toInsertMap() => {'text': text};
}
