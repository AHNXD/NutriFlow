import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palette sampled from the NutriFlow mark: the monogram sweeps from aqua
/// through blue into violet, so the app does the same. Blue is the working
/// colour (buttons, links, selection); aqua and violet are the ends of the
/// brand gradient and are used for accents and section identity, never as
/// body text.
class AppColors {
  AppColors._();

  // Brand ramp, aqua → violet, in the order the logo reads.
  static const aqua = Color(0xFF45C7D8);
  static const sky = Color(0xFF1E93C8);
  static const blue = Color(0xFF1A6FB8);
  static const navy = Color(0xFF0C4A80);
  static const indigo = Color(0xFF6B57BE);
  static const violet = Color(0xFF8B72D6);

  // Neutrals, biased cool so they sit under the brand ramp rather than
  // fighting it — a pure grey next to this blue reads as dirty.
  static const background = Color(0xFFF4F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEDF2F8);
  static const outline = Color(0xFFE0E8F1);
  static const ink = Color(0xFF0F1E2E);
  static const inkMuted = Color(0xFF5B6B7F);

  // Semantic — deliberately outside the brand ramp so state never reads as
  // decoration.
  static const danger = Color(0xFFE14C5A);
  static const success = Color(0xFF16A97C);
  static const warning = Color(0xFFE09A3B);

  /// The full three-stop sweep. For large surfaces only (hero, cover
  /// cards) — on a small control three stops turn to mud.
  static const brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [aqua, blue, violet],
    stops: [0.0, 0.55, 1.0],
  );

  /// Two-stop variants for smaller surfaces.
  static const blueGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [sky, blue],
  );

  static const violetGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [indigo, violet],
  );

  /// Kept for compatibility with older call sites that referenced the
  /// previous emerald identity.
  static const gradient = brandGradient;
}

/// One spacing scale, so padding is chosen rather than guessed.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Corner radii. Cards and sheets are generously rounded; controls less so,
/// which keeps the interface soft without looking like a toy.
class AppRadius {
  AppRadius._();

  static const control = 14.0;
  static const card = 20.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.blue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCEBF9),
      onPrimaryContainer: AppColors.navy,
      secondary: AppColors.violet,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEAE3FA),
      onSecondaryContainer: Color(0xFF3B2C73),
      tertiary: AppColors.aqua,
      onTertiary: Color(0xFF06333B),
      tertiaryContainer: Color(0xFFD6F2F7),
      onTertiaryContainer: Color(0xFF06333B),
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: Color(0xFFFCE4E6),
      onErrorContainer: Color(0xFF7A1F28),
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFAFCFE),
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: AppColors.surfaceMuted,
      surfaceContainerHighest: Color(0xFFE6EDF5),
      onSurfaceVariant: AppColors.inkMuted,
      outline: Color(0xFFC3D0DE),
      outlineVariant: AppColors.outline,
      shadow: Color(0xFF0F1E2E),
      scrim: Color(0xFF0F1E2E),
      inverseSurface: AppColors.ink,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF9CCBEE),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
    );

    final text = _textTheme(base.textTheme);

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        labelStyle: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        floatingLabelStyle: text.bodySmall?.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: _inputBorder(AppColors.outline),
        enabledBorder: _inputBorder(AppColors.outline),
        focusedBorder: _inputBorder(AppColors.blue, width: 1.6),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: text.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        extendedTextStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: const Color(0xFFDCEBF9),
        side: BorderSide.none,
        labelStyle: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        iconColor: AppColors.inkMuted,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFFDCEBF9),
        selectedIconTheme: const IconThemeData(color: AppColors.blue),
        unselectedIconTheme: const IconThemeData(color: AppColors.inkMuted),
        selectedLabelTextStyle: text.labelMedium?.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(
          color: AppColors.inkMuted,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.blue,
        unselectedLabelColor: AppColors.inkMuted,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.outline,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.blue, width: 2.5),
          insets: EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        titleTextStyle: text.titleLarge,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: const Color(0xFFDCEBF9),
          selectedForegroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.outline),
          textStyle: text.labelMedium,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue,
        linearTrackColor: AppColors.surfaceMuted,
      ),
      iconTheme: const IconThemeData(color: AppColors.inkMuted),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: color, width: width),
      );

  /// Cairo across the board — the same family the PDF export is set in, so
  /// the app and the document it produces read as one product. Bundled as
  /// an asset (see pubspec) rather than fetched, so it is there on a first
  /// launch with no connection.
  static const _fontFamily = 'Cairo';

  static TextTheme _textTheme(TextTheme base) {
    final cairo = base.apply(fontFamily: _fontFamily);
    return cairo.copyWith(
      displaySmall: cairo.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.ink,
      ),
      headlineMedium: cairo.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: AppColors.ink,
      ),
      headlineSmall: cairo.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: AppColors.ink,
      ),
      titleLarge: cairo.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleMedium: cairo.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleSmall: cairo.titleSmall?.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: cairo.bodyLarge?.copyWith(color: AppColors.ink, height: 1.6),
      bodyMedium: cairo.bodyMedium?.copyWith(color: AppColors.ink, height: 1.6),
      bodySmall: cairo.bodySmall?.copyWith(
        color: AppColors.inkMuted,
        height: 1.55,
      ),
      labelLarge: cairo.labelLarge?.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: cairo.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: cairo.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.inkMuted,
      ),
    );
  }
}
