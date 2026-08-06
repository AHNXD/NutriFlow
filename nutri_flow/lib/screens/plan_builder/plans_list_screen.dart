import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/plan.dart';
import '../../providers/plan_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/empty_state.dart';
import 'create_plan_screen.dart';
import 'plan_detail_screen.dart';

class PlansListScreen extends ConsumerWidget {
  const PlansListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(planListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('خطط المريضات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<Plan>(
            context,
            MaterialPageRoute(builder: (_) => const CreatePlanScreen()),
          );
          if (created != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: created.id)),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('خطة جديدة'),
      ),
      body: AsyncValueView<Plan>(
        value: plans,
        onRetry: () => ref.read(planListProvider.notifier).refresh(),
        emptyBuilder: (context) => const EmptyState(
          icon: Icons.calendar_month_outlined,
          title: 'لا توجد خطط بعد',
          subtitle: 'اضغطي على "خطة جديدة" لبدء أول خطة لمريضة',
        ),
        data: (context, list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final plan = list[i];
            return Card(
              child: ListTile(
                title: Text(plan.patientName),
                subtitle: Text(
                  '${plan.durationDays} أيام'
                  '${plan.createdAt != null ? ' • ${DateFormat('yyyy/MM/dd').format(plan.createdAt!)}' : ''}',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: plan.id)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirmDelete(context, title: 'حذف خطة "${plan.patientName}"؟')) {
                      await ref.read(planListProvider.notifier).delete(plan.id);
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
