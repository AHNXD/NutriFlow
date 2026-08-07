import 'package:flutter/material.dart';

import '../theme/pdf_themes.dart';

/// Visual swatch grid for picking a plan's PDF color theme.
class PdfThemePicker extends StatelessWidget {
  const PdfThemePicker({super.key, required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('لون قالب PDF', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final theme in PdfThemes.all)
              _Swatch(
                theme: theme,
                isSelected: theme.id == selected,
                onTap: () => onChanged(theme.id),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.theme, required this.isSelected, required this.onTap});

  final PdfTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.primary : Colors.black.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(gradient: theme.gradient, shape: BoxShape.circle),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              theme.labelAr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
