"""PDF color palettes. Keep in sync with the Dart side —
``nutri_flow/lib/theme/pdf_themes.dart`` — same ids, same hex values. The
`id` is what's stored in `plans.theme` and picks the palette injected into
the rendered PDF's CSS custom properties (see templates/base.html).

Palette is orthogonal to layout: any theme here can be combined with any
design in ``app/layouts.py``. That means no stylesheet may hardcode a brand
color — everything goes through --primary/--secondary/--dark/--soft/--tint.

    primary    the main brand color; headings, rules, badges
    secondary  the lighter end of every gradient, accent dots
    dark       deepest shade; text on soft backgrounds (must pass contrast)
    soft       near-white tint; card and banner fills
    tint       one step deeper than soft; borders, chips, table stripes
"""

from __future__ import annotations

THEMES: dict[str, dict[str, str]] = {
    "emerald": {
        "label": "زمردي",
        "primary": "#0F9D75",
        "secondary": "#14B8A6",
        "dark": "#0B6E54",
        "soft": "#ECFDF5",
        "tint": "#D1FAE5",
    },
    "ocean": {
        "label": "محيطي",
        "primary": "#0284C7",
        "secondary": "#38BDF8",
        "dark": "#075985",
        "soft": "#F0F9FF",
        "tint": "#E0F2FE",
    },
    "sunset": {
        "label": "غروب",
        "primary": "#EA580C",
        "secondary": "#F472B6",
        "dark": "#9A3412",
        "soft": "#FFF7ED",
        "tint": "#FFEDD5",
    },
    "orchid": {
        "label": "بنفسجي",
        "primary": "#4F46E5",
        "secondary": "#A855F7",
        "dark": "#3730A3",
        "soft": "#F5F3FF",
        "tint": "#EDE9FE",
    },
    "rose": {
        "label": "وردي",
        "primary": "#E11D48",
        "secondary": "#FB7185",
        "dark": "#9F1239",
        "soft": "#FFF1F2",
        "tint": "#FFE4E6",
    },
    "gold": {
        "label": "ذهبي",
        "primary": "#D97706",
        "secondary": "#FBBF24",
        "dark": "#92400E",
        "soft": "#FFFBEB",
        "tint": "#FEF3C7",
    },
    "sand": {
        "label": "رملي",
        "primary": "#C2643F",
        "secondary": "#E4A57D",
        "dark": "#8A4227",
        "soft": "#FBF4EE",
        "tint": "#F3E0D1",
    },
    "charcoal": {
        "label": "فحمي",
        "primary": "#3F4A5A",
        "secondary": "#7A889B",
        "dark": "#1E2733",
        "soft": "#F4F6F8",
        "tint": "#E3E8EE",
    },
}

DEFAULT_THEME = "emerald"


def get_theme(theme_id: str | None) -> dict[str, str]:
    return THEMES.get(theme_id or DEFAULT_THEME, THEMES[DEFAULT_THEME])
