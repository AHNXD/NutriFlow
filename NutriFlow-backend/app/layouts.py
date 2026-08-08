"""PDF design templates (layouts).

A layout is the *shape* of the document — page composition, typography,
how a meal card is drawn. It is deliberately independent of the color
palette in ``app/themes.py``: every layout renders in every theme, so a
plan is described by the pair (layout, theme).

Each id maps 1:1 to a directory under ``templates/layouts/<id>/`` holding
``cover.html``, ``day.html``, ``notes.html`` and ``styles.css``. Adding a
design means adding a directory plus an entry here — nothing else.

Keep in sync with the Dart side — ``nutri_flow/lib/theme/pdf_layouts.dart``
— same ids, since the id is stored in ``plans.pdf_layout``.
"""

from __future__ import annotations

LAYOUTS: dict[str, dict[str, str]] = {
    "aurora": {
        "label": "أورورا",
        "description": "تدرّجات لونية ناعمة وبطاقات مستديرة — أسلوب حديث ومشرق",
    },
    "editorial": {
        "label": "مجلة",
        "description": "طباعة جريئة وخطوط فاصلة رفيعة بأسلوب المجلات الراقية",
    },
    "minimal": {
        "label": "بسيط",
        "description": "مساحات بيضاء واسعة وتفاصيل هادئة — مثالي للطباعة",
    },
    "bloom": {
        "label": "ناعم",
        "description": "ألوان باستيل وأشكال دائرية دافئة بروح العافية",
    },
    "noir": {
        "label": "ليلي",
        "description": "غلاف داكن فاخر مع لمسات لونية وإطار أنيق",
    },
}

DEFAULT_LAYOUT = "aurora"


def get_layout(layout_id: str | None) -> dict[str, str]:
    resolved = layout_id if layout_id in LAYOUTS else DEFAULT_LAYOUT
    return {"id": resolved, **LAYOUTS[resolved]}
