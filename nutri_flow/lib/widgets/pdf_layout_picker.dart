import 'package:flutter/material.dart';

import '../theme/pdf_layouts.dart';
import '../theme/pdf_themes.dart';

/// Picker for a plan's PDF design template.
///
/// Each option shows a miniature of that design's cover page, painted in the
/// currently selected colour palette — the layout and the palette are
/// independent choices, and seeing them combined is the only way to tell the
/// five designs apart at a glance.
class PdfLayoutPicker extends StatelessWidget {
  const PdfLayoutPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.theme = PdfThemes.emerald,
  });

  /// Currently selected layout id (see [PdfLayouts]).
  final String selected;
  final ValueChanged<String> onChanged;

  /// Palette the miniatures are drawn in, so the preview matches what the
  /// exported PDF will actually look like.
  final PdfTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تصميم قالب PDF', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'اختاري شكل الصفحات — يعمل أي تصميم مع أي لون.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: PdfLayouts.all.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final layout = PdfLayouts.all[i];
              return _LayoutOption(
                layout: layout,
                theme: theme,
                isSelected: layout.id == selected,
                onTap: () => onChanged(layout.id),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          PdfLayouts.byId(selected).descriptionAr,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LayoutOption extends StatelessWidget {
  const _LayoutOption({
    required this.layout,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final PdfLayout layout;
  final PdfTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? theme.primary.withValues(alpha: 0.06) : null,
          border: Border.all(
            color: isSelected ? theme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  // A4 portrait, so the miniature reads as a sheet of paper.
                  aspectRatio: 210 / 297,
                  child: _CoverMiniature(layoutId: layout.id, theme: theme),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle, size: 14, color: theme.primary),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    layout.labelAr,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A stylised thumbnail of each design's cover page. Deliberately abstract —
/// bars stand in for text — so the shapes and colour blocking do the
/// distinguishing, which is what actually differs between the templates.
class _CoverMiniature extends StatelessWidget {
  const _CoverMiniature({required this.layoutId, required this.theme});

  final String layoutId;
  final PdfTheme theme;

  static const _noirInk = Color(0xFF14181E);

  Widget _bar(double widthFactor, Color color, {double height = 3}) =>
      FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: switch (layoutId) {
          'editorial' => _editorial(),
          'minimal' => _minimal(),
          'bloom' => _bloom(),
          'noir' => _noir(),
          _ => _aurora(),
        },
      ),
    );
  }

  // Full-bleed gradient, white badge, centred stack.
  Widget _aurora() => Container(
        decoration: BoxDecoration(gradient: theme.gradient),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 7),
            _bar(0.7, Colors.white, height: 5),
            const SizedBox(height: 4),
            _bar(0.35, Colors.white70),
            const SizedBox(height: 9),
            Container(
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      );

  // White sheet, accent spine down the binding edge, big display type.
  Widget _editorial() => Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bar(0.55, Colors.black26, height: 2),
                    const Spacer(),
                    _bar(0.85, Colors.black87, height: 8),
                    const SizedBox(height: 3),
                    _bar(0.6, theme.primary, height: 8),
                    const SizedBox(height: 6),
                    _bar(0.3, Colors.black54, height: 2),
                    const Spacer(),
                    _bar(1, Colors.black26, height: 1),
                    const SizedBox(height: 4),
                    _bar(0.9, Colors.black38, height: 2),
                  ],
                ),
              ),
            ),
            Container(width: 5, color: theme.primary),
          ],
        ),
      );

  // Lots of white, one hairline, small centred marks.
  Widget _minimal() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(height: 10),
            _bar(0.8, Colors.black45, height: 4),
            const SizedBox(height: 8),
            _bar(0.25, theme.primary, height: 1),
            const SizedBox(height: 8),
            _bar(0.5, Colors.black26, height: 3),
            const SizedBox(height: 12),
            _bar(0.7, Colors.black12, height: 1),
            const SizedBox(height: 5),
            _bar(0.7, Colors.black12, height: 1),
          ],
        ),
      );

  // Tinted ground with a floating white rounded card.
  Widget _bloom() => Container(
        decoration: BoxDecoration(gradient: theme.gradient),
        padding: const EdgeInsets.all(9),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 7),
                _bar(0.85, theme.primary, height: 4),
                const SizedBox(height: 4),
                _bar(0.5, Colors.black26, height: 2),
                const SizedBox(height: 7),
                Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        child: Container(
                          height: 9,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  // Near-black sheet inside a hairline frame.
  Widget _noir() => Container(
        color: _noirInk,
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                ),
              ),
              const SizedBox(height: 9),
              _bar(0.7, Colors.white70, height: 4),
              const SizedBox(height: 3),
              _bar(0.55, Colors.white, height: 4),
              const SizedBox(height: 7),
              _bar(0.22, theme.secondary, height: 1),
              const SizedBox(height: 7),
              _bar(0.45, Colors.white38, height: 2),
            ],
          ),
        ),
      );
}
