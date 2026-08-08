import 'package:flutter/widgets.dart';

/// Window size classes, following Material's own thresholds.
///
/// The app is phone-first, but it is also opened on a laptop — where a
/// single column of full-width controls looks broken. Everything that
/// changes with width goes through these three classes rather than ad-hoc
/// `MediaQuery.of(context).size.width > 700` checks scattered per screen.
enum WindowSize {
  /// Phones, and any narrow window. Single column, navigation by pushing.
  compact,

  /// Large phones in landscape, tablets in portrait, half-screen windows.
  medium,

  /// Tablets in landscape, laptops, desktops. Persistent navigation rail.
  expanded;

  bool get isCompact => this == WindowSize.compact;
  bool get isAtLeastMedium => this != WindowSize.compact;
  bool get isExpanded => this == WindowSize.expanded;
}

class Breakpoints {
  Breakpoints._();

  static const medium = 640.0;
  static const expanded = 1024.0;

  /// Content stops growing past this — a 2000px-wide line of Arabic is
  /// unreadable no matter how much window there is.
  static const maxContentWidth = 1120.0;

  /// Forms are narrower still; a text field the width of a desk is worse
  /// than one the width of a phone.
  static const maxFormWidth = 720.0;

  static WindowSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expanded) return WindowSize.expanded;
    if (width >= medium) return WindowSize.medium;
    return WindowSize.compact;
  }
}

extension WindowSizeContext on BuildContext {
  WindowSize get windowSize => Breakpoints.of(this);

  bool get isCompact => windowSize.isCompact;
  bool get isExpanded => windowSize.isExpanded;

  /// Screen padding grows with the window so content never hugs the edge
  /// of a desktop display.
  double get gutter => switch (windowSize) {
    WindowSize.compact => 16,
    WindowSize.medium => 24,
    WindowSize.expanded => 32,
  };

  /// Column count for a grid of roughly card-sized tiles.
  int gridColumns({int compact = 2, int medium = 3, int expanded = 4}) =>
      switch (windowSize) {
        WindowSize.compact => compact,
        WindowSize.medium => medium,
        WindowSize.expanded => expanded,
      };
}
