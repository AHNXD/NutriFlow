import 'package:flutter/material.dart';

import '../theme/breakpoints.dart';

/// Centres content and caps how wide it can grow, with gutters that scale
/// with the window. Every screen body goes through this — without it, a
/// laptop window stretches lists and text fields edge to edge.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding,
    this.scrollable = false,
  });

  const PageBody.form({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
  }) : maxWidth = Breakpoints.maxFormWidth;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  /// Wraps the child in a scroll view. Off by default so a screen that
  /// already owns a ListView doesn't nest two scrollables.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final resolved =
        padding ?? EdgeInsets.fromLTRB(context.gutter, 8, context.gutter, 24);

    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: resolved, child: child),
      ),
    );

    if (scrollable) content = SingleChildScrollView(child: content);
    return content;
  }
}

/// Sliver form of [PageBody], for screens built out of a CustomScrollView.
class SliverPageBody extends StatelessWidget {
  const SliverPageBody({
    super.key,
    required this.sliver,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding,
  });

  final Widget sliver;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Convert the centring into horizontal padding, since a sliver can't
    // be wrapped in Align without losing its sliver-ness.
    final overflow = ((width - maxWidth) / 2).clamp(0.0, double.infinity);
    final base =
        padding ?? EdgeInsets.fromLTRB(context.gutter, 8, context.gutter, 24);

    return SliverPadding(
      padding: base.add(EdgeInsets.symmetric(horizontal: overflow)),
      sliver: sliver,
    );
  }
}

/// A grid whose column count follows the window size rather than being
/// pinned at two.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.compact = 2,
    this.medium = 3,
    this.expanded = 4,
    this.aspectRatio = 1.15,
    this.spacing = 12,
  });

  final List<Widget> children;
  final int compact;
  final int medium;
  final int expanded;
  final double aspectRatio;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: context.gridColumns(
        compact: compact,
        medium: medium,
        expanded: expanded,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: aspectRatio,
      children: children,
    );
  }
}

/// Two columns side by side on a wide window, stacked on a narrow one.
/// Used where a screen has a primary pane and a secondary one that would
/// otherwise sit far below the fold on a laptop.
class ResponsiveColumns extends StatelessWidget {
  const ResponsiveColumns({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 3,
    this.secondaryFlex = 2,
    this.spacing = 20,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (!context.isExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          SizedBox(height: spacing),
          secondary,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: primaryFlex, child: primary),
        SizedBox(width: spacing),
        Expanded(flex: secondaryFlex, child: secondary),
      ],
    );
  }
}
