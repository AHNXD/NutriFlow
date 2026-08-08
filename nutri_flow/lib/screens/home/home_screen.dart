import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/layout.dart';
import '../plan_builder/create_plan_screen.dart';
import '../plan_builder/plan_detail_screen.dart';
import '../settings/settings_screen.dart';

/// The phone/tablet home hub. On a laptop this is replaced by the rail in
/// [AppShell], so everything here can assume a narrow-ish window.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final banks = appDestinations.where((d) => !d.primary).toList();
    final plans = appDestinations.firstWhere((d) => d.primary);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _BrandHeader()),
          SliverPageBody(
            padding: EdgeInsets.fromLTRB(
              context.gutter,
              20,
              context.gutter,
              32,
            ),
            sliver: SliverList.list(
              children: [
                _SectionLabel('الخطط'),
                const SizedBox(height: 12),
                _PrimaryCard(destination: plans),
                const SizedBox(height: 28),
                _SectionLabel('البنوك'),
                const SizedBox(height: 12),
                AdaptiveGrid(
                  compact: 2,
                  medium: 3,
                  expanded: 3,
                  aspectRatio: context.isCompact ? 1.28 : 1.5,
                  children: [for (final d in banks) _BankCard(destination: d)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient masthead carrying the mark. The decorative discs echo the
/// logo's circular sweep rather than being generic blobs.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -46,
            left: -34,
            child: _Disc(size: 150, opacity: 0.13),
          ),
          Positioned(
            bottom: -62,
            right: 26,
            child: _Disc(size: 120, opacity: 0.10),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.gutter,
              top + 20,
              context.gutter,
              26,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Text(
                        'NF',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NutriFlow',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'كل شيء بمكان واحد',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'الإعدادات',
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 17,
          decoration: BoxDecoration(
            gradient: AppColors.blueGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 9),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

/// The plans card — full width, gradient, with the "new plan" action on it
/// so the most common task is one tap from launch.
class _PrimaryCard extends StatelessWidget {
  const _PrimaryCard({required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(gradient: AppColors.blueGradient),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: destination.builder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          destination.selectedIcon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.label,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            if (destination.subtitle != null)
                              Text(
                                destination.subtitle!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_left,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: context.isCompact ? double.infinity : 0,
                      ),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                        ),
                        onPressed: () => _createPlan(context),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('خطة جديدة'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPlan(BuildContext context) async {
    final created = await Navigator.push(
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

class _BankCard extends StatelessWidget {
  const _BankCard({required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: destination.builder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: destination.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  destination.icon,
                  color: destination.accent,
                  size: 22,
                ),
              ),
              const Spacer(),
              Text(
                destination.label,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (destination.subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  destination.subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
