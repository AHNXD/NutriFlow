import 'package:flutter/material.dart';

/// Shown instead of the app when it was launched without the required
/// `--dart-define` values — see README.md "تشغيل المشروع".
class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.black38),
              const SizedBox(height: 16),
              Text(
                'إعداد الاتصال بقاعدة البيانات مطلوب',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'شغّلي التطبيق مع متغيرات SUPABASE_URL و SUPABASE_ANON_KEY '
                'عبر --dart-define (راجعي README.md في مجلد nutri_flow).',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
