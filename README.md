# NutriFlow

Flutter + Supabase + FastAPI app that replaces a dietitian's manual
Gamma-based weekly meal-plan workflow with reusable banks (recipes, tips,
helper drinks, supplements, allowed/forbidden foods) and one-click PDF
export. Full product/technical spec: [`nutrition-planner-spec.md`](nutrition-planner-spec.md).

## Layout

```
NutriFlow/
├── nutri_flow/           # Flutter app (mobile + desktop) — see nutri_flow/README.md
├── NutriFlow-backend/     # FastAPI PDF service — see NutriFlow-backend/README.md
├── supabase/
│   └── schema.sql         # full Postgres schema + RLS + storage bucket, run once
└── nutrition-planner-spec.md
```

(These map to the spec's suggested `mobile_app/` / `pdf_service/` names —
kept the existing folder names from how the project was already scaffolded.)

## Quick start

1. **Database**: create a free Supabase project, run `supabase/schema.sql`
   in its SQL editor.
2. **App**: `cd nutri_flow && flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
   — see `nutri_flow/README.md` for the full flag list.
3. **PDF service** (optional while developing the app itself):
   `cd NutriFlow-backend`, follow its README, then pass
   `--dart-define=PDF_SERVICE_URL=...` to the app.

## Status vs. the spec's roadmap (§10)

- [x] 1. Supabase schema (`supabase/schema.sql`)
- [x] 2. Flutter project + Supabase connection + بنك الأكلات (full CRUD + image upload/compress)
- [x] 3. بنك النصائح / الرسائل التحفيزية / المشروبات / المكملات / المسموح-الممنوع
- [x] 4. "إنشاء خطة" + "باني اليوم" (recipe-from-bank or manual entry per meal, plan-level drinks/supplements)
- [x] 5. FastAPI service skeleton + Jinja2 templates for all pages (cover, day, instructions, allowed/forbidden, supplements, drinks, closing) + WeasyPrint wiring, Cairo font bundled locally
- [x] 6. Templates cover every page type described in the spec
- [x] 7. "تصدير PDF" button wired from Flutter to the service
- [ ] 8. Deploy FastAPI to Render + n8n keep-alive workflow — infra step, needs real accounts/credentials
- [ ] 9. End-to-end test with the dietitian's real data

**Biggest remaining gap:** the PDF's visual design is a first pass, not a
pixel-match to the Gamma reference the spec mentions — that needs a design
iteration once there's real plan data to look at. There's also no dedicated
"Plan Preview" screen in the app yet (the day builder doubles as an editable
preview).

## Notes on choices made while implementing (not fully pinned down by the spec)

- **State management**: Riverpod, chosen for clean async/loading/error
  handling across many CRUD screens.
- **RLS**: enabled but permissive (`using (true)`) for v1, since the spec
  explicitly defers login to a later version — see the header comment in
  `supabase/schema.sql` for the tightening path once there's more than one
  trusted holder of the anon key.
- **PDF service ↔ Supabase**: direct REST calls over `httpx` rather than the
  `supabase-py` SDK, to keep the Render free-tier cold start light (spec §6
  allows either).
