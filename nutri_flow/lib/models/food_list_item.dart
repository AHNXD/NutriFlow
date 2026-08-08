enum FoodListType {
  allowed('allowed', 'مسموح'),
  forbidden('forbidden', 'ممنوع');

  final String value;
  final String labelAr;
  const FoodListType(this.value, this.labelAr);

  static FoodListType fromValue(String value) => FoodListType.values.firstWhere(
    (e) => e.value == value,
    orElse: () => FoodListType.allowed,
  );
}

class FoodListItem {
  final String id;
  final FoodListType listType;
  final String category;
  final String item;

  const FoodListItem({
    required this.id,
    required this.listType,
    required this.category,
    required this.item,
  });

  factory FoodListItem.fromMap(Map<String, dynamic> map) => FoodListItem(
    id: map['id'] as String,
    listType: FoodListType.fromValue(map['list_type'] as String? ?? 'allowed'),
    category: map['category'] as String? ?? '',
    item: map['item'] as String? ?? '',
  );

  Map<String, dynamic> toInsertMap() => {
    'list_type': listType.value,
    'category': category,
    'item': item,
  };
}
