import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/helper_drink.dart';
import '../../providers/drink_supplement_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/empty_state.dart';
import 'drink_form_screen.dart';

class DrinksBankScreen extends ConsumerWidget {
  const DrinksBankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drinks = ref.watch(helperDrinkListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('بنك المشروبات المساعدة')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DrinkFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('مشروب جديد'),
      ),
      body: AsyncValueView<HelperDrink>(
        value: drinks,
        onRetry: () => ref.read(helperDrinkListProvider.notifier).refresh(),
        emptyBuilder: (context) => const EmptyState(
          icon: Icons.local_drink_outlined,
          title: 'لا توجد مشروبات مساعدة بعد',
        ),
        data: (context, list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final drink = list[i];
            return Card(
              child: ListTile(
                title: Text(drink.name),
                subtitle: drink.timing != null ? Text(drink.timing!) : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DrinkFormScreen(existing: drink)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirmDelete(context, title: 'حذف "${drink.name}"؟')) {
                      await ref.read(helperDrinkListProvider.notifier).delete(drink.id);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
