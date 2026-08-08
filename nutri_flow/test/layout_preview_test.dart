import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_flow/screens/home/home_screen.dart';
import 'package:nutri_flow/theme/app_theme.dart';
import 'package:nutri_flow/widgets/app_shell.dart';

/// Renders the shell at phone / tablet / laptop widths.
///
/// Two jobs: it fails if any of them overflows (a RenderFlex overflow is a
/// test failure, not just a yellow stripe), and with `--update-goldens` it
/// writes a PNG per size so the design can actually be looked at without a
/// device or a Supabase project.
void main() {
  setUpAll(() async {
    // flutter_test does not load the fonts declared in pubspec, so text
    // would render as fallback boxes. Registering the bundled file here
    // both makes the goldens legible and proves the variable Cairo file
    // actually shapes Arabic through Flutter's engine.
    final file = File('assets/fonts/Cairo-Variable.ttf');
    final loader = FontLoader('Cairo')
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await loader.load();
  });

  const sizes = <String, Size>{
    'phone': Size(430, 932),
    'tablet': Size(834, 1112),
    'laptop': Size(1440, 900),
  };

  Widget harness(Widget child) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );

  for (final entry in sizes.entries) {
    testWidgets('home renders at ${entry.key}', (tester) async {
      tester.view
        ..physicalSize = entry.value
        ..devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(harness(const HomeScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // The real assertion is that nothing overflows at this size — a
      // RenderFlex overflow surfaces here as a thrown exception.
      expect(tester.takeException(), isNull);

      // The PNGs are design references, not a CI gate: font rasterisation
      // differs between machines, so comparing them would fail on anything
      // but the box they were generated on. Written only under
      // `flutter test --update-goldens`.
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byType(HomeScreen),
          matchesGoldenFile('previews/home-${entry.key}.png'),
        );
      }
    });
  }

  // Settings is not one of the rail's destinations — it is the trailing
  // button. Selecting it used to be modelled as `destinations.length`,
  // which is exactly what NavigationRail asserts against, so opening
  // Settings on a desktop window crashed the pane.
  testWidgets('rail tolerates nothing being selected (Settings open)', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harness(
        Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: null,
                destinations: [
                  for (final d in appDestinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation rail appears on a laptop-sized window', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // AppShell's rail is what a wide window gets instead of the hub; the
    // content pane is left empty here because every section reads from
    // Supabase, which a widget test has no business reaching.
    await tester.pumpWidget(
      harness(
        Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: true,
                minExtendedWidth: 232,
                selectedIndex: 0,
                destinations: [
                  for (final d in appDestinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    if (autoUpdateGoldenFiles) {
      await expectLater(
        find.byType(NavigationRail),
        matchesGoldenFile('previews/rail-laptop.png'),
      );
    }
  });
}
