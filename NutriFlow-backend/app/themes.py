"""PDF color themes. Keep in sync with the Dart side —
``nutri_flow/lib/theme/pdf_themes.dart`` — same ids, same hex values. The
`id` is what's stored in `plans.theme` and picks the palette injected into
the rendered PDF's CSS custom properties (see templates/base.html).
"""

from __future__ import annotations

THEMES: dict[str, dict[str, str]] = {
    "emerald": {"label": "زمردي", "primary": "#0F9D75", "secondary": "#14B8A6", "dark": "#0B6E54", "soft": "#ECFDF5"},
    "ocean": {"label": "محيطي", "primary": "#0284C7", "secondary": "#38BDF8", "dark": "#075985", "soft": "#F0F9FF"},
    "sunset": {"label": "غروب", "primary": "#EA580C", "secondary": "#F472B6", "dark": "#9A3412", "soft": "#FFF7ED"},
    "orchid": {"label": "بنفسجي", "primary": "#4F46E5", "secondary": "#A855F7", "dark": "#3730A3", "soft": "#F5F3FF"},
    "rose": {"label": "وردي", "primary": "#E11D48", "secondary": "#FB7185", "dark": "#9F1239", "soft": "#FFF1F2"},
    "gold": {"label": "ذهبي", "primary": "#D97706", "secondary": "#FBBF24", "dark": "#92400E", "soft": "#FFFBEB"},
}

DEFAULT_THEME = "emerald"


def get_theme(theme_id: str | None) -> dict[str, str]:
    return THEMES.get(theme_id or DEFAULT_THEME, THEMES[DEFAULT_THEME])
