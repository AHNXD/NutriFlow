import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/food_list_item.dart';
import '../../providers/food_list_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/empty_state.dart';

class FoodListsScreen extends StatelessWidget {
  const FoodListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأطعمة المسموحة / الممنوعة'),
          bottom: const TabBar(tabs: [
            Tab(text: 'مسموح'),
            Tab(text: 'ممنوع'),
          ]),
        ),
        body: const TabBarView(children: [
          _FoodListTab(type: FoodListType.allowed),
          _FoodListTab(type: FoodListType.forbidden),
        ]),
      ),
    );
  }
}

class _FoodListTab extends ConsumerWidget {
  const _FoodListTab({required this.type});
  final FoodListType type;

  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => _FoodItemDialog(defaultType: type),
    );
    if (result == null) return;
    await ref.read(foodListProvider.notifier).create(
          FoodListItem(
            id: const Uuid().v4(),
            listType: type,
            category: result.$1,
            item: result.$2,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(foodListProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('إضافة عنصر'),
      ),
      body: AsyncValueView<FoodListItem>(
        value: all,
        onRetry: () => ref.read(foodListProvider.notifier).refresh(),
        isEmpty: (items) => items.where((i) => i.listType == type).isEmpty,
        emptyBuilder: (context) => EmptyState(
          icon: type == FoodListType.allowed ? Icons.check_circle_outline : Icons.block,
          title: type == FoodListType.allowed
              ? 'لا توجد عناصر مسموحة بعد'
              : 'لا توجد عناصر ممنوعة بعد',
        ),
        data: (context, all) {
          final items = all.where((i) => i.listType == type).toList();
          final byCategory = <String, List<FoodListItem>>{};
          for (final item in items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }
          final categories = byCategory.keys.toList()..sort();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final category = categories[i];
              final categoryItems = byCategory[category]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text(category, style: Theme.of(context).textTheme.titleSmall),
                  initiallyExpanded: true,
                  children: [
                    for (final item in categoryItems)
                      ListTile(
                        dense: true,
                        title: Text(item.item),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () async {
                            if (await confirmDelete(context, title: 'حذف "${item.item}"؟')) {
                              await ref.read(foodListProvider.notifier).delete(item.id);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FoodItemDialog extends StatefulWidget {
  const _FoodItemDialog({required this.defaultType});
  final FoodListType defaultType;

  @override
  State<_FoodItemDialog> createState() => _FoodItemDialogState();
}

class _FoodItemDialogState extends State<_FoodItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryCtrl = TextEditingController();
  final _itemCtrl = TextEditingController();

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _itemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.defaultType == FoodListType.allowed
          ? 'إضافة عنصر مسموح'
          : 'إضافة عنصر ممنوع'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'التصنيف',
                hintText: 'مثال: بروتينات، دهون صحية، خضار',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _itemCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'العنصر'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, (_categoryCtrl.text.trim(), _itemCtrl.text.trim()));
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
