import 'package:flutter/material.dart';

import '../models/ingredient.dart';

/// Dynamic "add/remove ingredient row" editor shared by the recipe form and
/// the helper-drink form (both store ingredients the same way, see
/// schema.sql `ingredients jsonb`).
class IngredientListEditor extends StatefulWidget {
  const IngredientListEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final List<Ingredient> initial;
  final ValueChanged<List<Ingredient>> onChanged;

  @override
  State<IngredientListEditor> createState() => _IngredientListEditorState();
}

class _IngredientListEditorState extends State<IngredientListEditor> {
  late List<_Row> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initial.isEmpty
        ? [_Row()]
        : widget.initial.map(_Row.fromIngredient).toList();
  }

  void _emit() {
    widget.onChanged(_rows
        .where((r) => r.item.text.trim().isNotEmpty)
        .map((r) => Ingredient(
              item: r.item.text.trim(),
              amount: r.amount.text.trim(),
              unit: r.unit.text.trim(),
            ))
        .toList());
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('المكونات', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => _rows.add(_Row())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة مكوّن'),
            ),
          ],
        ),
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _rows[i].item,
                    decoration: const InputDecoration(hintText: 'المكوّن'),
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _rows[i].amount,
                    decoration: const InputDecoration(hintText: 'الكمية'),
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _rows[i].unit,
                    decoration: const InputDecoration(hintText: 'الوحدة'),
                    onChanged: (_) => _emit(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _rows.length == 1
                      ? null
                      : () => setState(() {
                            _rows[i].dispose();
                            _rows.removeAt(i);
                            _emit();
                          }),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Row {
  final TextEditingController item;
  final TextEditingController amount;
  final TextEditingController unit;

  _Row()
      : item = TextEditingController(),
        amount = TextEditingController(),
        unit = TextEditingController();

  factory _Row.fromIngredient(Ingredient i) {
    final row = _Row();
    row.item.text = i.item;
    row.amount.text = i.amount;
    row.unit.text = i.unit;
    return row;
  }

  void dispose() {
    item.dispose();
    amount.dispose();
    unit.dispose();
  }
}
