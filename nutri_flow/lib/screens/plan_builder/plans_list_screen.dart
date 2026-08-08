import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/plan.dart';
import '../../providers/plan_providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/layout.dart';
import 'create_plan_screen.dart';
import 'plan_detail_screen.dart';

class PlansListScreen extends ConsumerWidget {
  const PlansListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(planListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الخطط الغذائية')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('خطة جديدة'),
      ),
      body: AsyncValueView<Plan>(
        value: plans,
        onRetry: () => ref.read(planListProvider.notifier).refresh(),
        emptyBuilder: (context) => EmptyState(
          icon: Icons.calendar_month_outlined,
          title: 'لا توجد خطط بعد',
          subtitle: 'يمكن إنشاء أول خطة من زر "خطة جديدة"',
          action: FilledButton.icon(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('خطة جديدة'),
          ),
        ),
        data: (context, list) => PageBody(
          scrollable: true,
          padding: EdgeInsets.fromLTRB(context.gutter, 12, context.gutter, 96),
          // One column on a phone; on a laptop a single 1100px-wide row per
          // plan reads as an empty page, so the cards tile instead.
          child: AdaptiveGrid(
            compact: 1,
            medium: 2,
            expanded: 3,
            aspectRatio: context.isCompact ? 4.6 : 2.2,
            children: [
              for (final plan in list)
                _PlanCard(
                  plan: plan,
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlanDetailScreen(planId: plan.id),
                    ),
                  ),
                  onDelete: () async {
                    if (await confirmDelete(
                      context,
                      title: 'حذف خطة "${plan.patientName}"؟',
                    )) {
                      await ref.read(planListProvider.notifier).delete(plan.id);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final created = await Navigator.push<Plan>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePlanScreen()),
    );
    if (created == null || !context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: created.id)),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.onOpen,
    required this.onDelete,
  });

  final Plan plan;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  /// First letter of the patient's name, as a stand-in for an avatar.
  String get _initial =>
      plan.patientName.trim().isEmpty ? '؟' : plan.patientName.trim()[0];

  @override
  Widget build(BuildContext context) {
    final date = plan.createdAt == null
        ? null
        : DateFormat('yyyy/MM/dd').format(plan.createdAt!);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plan.patientName,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MetaChip(
                          icon: Icons.event_note_outlined,
                          label: '${plan.durationDays} أيام',
                        ),
                        if (plan.fastingHours != null)
                          _MetaChip(
                            icon: Icons.schedule,
                            label: 'صيام ${plan.fastingHours} س',
                          ),
                        if (date != null)
                          _MetaChip(icon: Icons.calendar_today, label: date),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'حذف',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.inkMuted),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
