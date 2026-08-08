import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders loading/error/empty/data states consistently across every bank
/// screen so each one doesn't reinvent its own spinner/error UI.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.emptyBuilder,
    this.isEmpty,
    this.onRetry,
  });

  final AsyncValue<List<T>> value;
  final Widget Function(BuildContext context, List<T> items) data;
  final WidgetBuilder? emptyBuilder;
  final bool Function(List<T> items)? isEmpty;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                'تعذّر تحميل البيانات\n$err',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
        ),
      ),
      data: (items) {
        final empty = isEmpty?.call(items) ?? items.isEmpty;
        if (empty && emptyBuilder != null) {
          return emptyBuilder!(context);
        }
        return data(context, items);
      },
    );
  }
}
