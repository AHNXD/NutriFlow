import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/env.dart';
import 'screens/home/setup_required_screen.dart';
import 'services/supabase_client_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Env.isSupabaseConfigured) {
    await initSupabase();
  }
  runApp(const ProviderScope(child: NutriFlowApp()));
}

class NutriFlowApp extends StatelessWidget {
  const NutriFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Env.isSupabaseConfigured
          ? const AppShell()
          : const SetupRequiredScreen(),
    );
  }
}
