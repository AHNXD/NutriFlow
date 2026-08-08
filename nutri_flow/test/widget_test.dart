// Smoke test: with no --dart-define values (the default under `flutter
// test`), Env.isSupabaseConfigured is false, so the app should show the
// setup-required screen rather than crash trying to reach Supabase.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutri_flow/main.dart';

void main() {
  testWidgets('shows setup-required screen without Supabase config', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NutriFlowApp()));
    await tester.pumpAndSettle();

    expect(find.text('إعداد الاتصال بقاعدة البيانات مطلوب'), findsOneWidget);
  });
}
