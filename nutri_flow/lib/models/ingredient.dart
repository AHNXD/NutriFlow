/// One line item of a recipe/drink ingredient list, stored as jsonb:
/// `{ "item": "زبادي يوناني", "amount": "300", "unit": "غ" }`
class Ingredient {
  final String item;
  final String amount;
  final String unit;

  const Ingredient({required this.item, this.amount = '', this.unit = ''});

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    item: map['item'] as String? ?? '',
    amount: map['amount']?.toString() ?? '',
    unit: map['unit'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'item': item,
    'amount': amount,
    'unit': unit,
  };

  Ingredient copyWith({String? item, String? amount, String? unit}) =>
      Ingredient(
        item: item ?? this.item,
        amount: amount ?? this.amount,
        unit: unit ?? this.unit,
      );

  static List<Ingredient> listFromJson(dynamic raw) {
    if (raw == null) return [];
    return (raw as List)
        .map((e) => Ingredient.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static List<Map<String, dynamic>> listToJson(List<Ingredient> list) =>
      list.map((e) => e.toMap()).toList();
}
