import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shown when a list has nothing in it yet. Carries an optional action so
/// the empty state is a way forward rather than a dead end.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 34, color: AppColors.blue),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (action != null) ...[const SizedBox(height: 22), action!],
            ],
          ),
        ),
      ),
    );
  }
}
