# NutriFlow (mobile + desktop app)

Flutter client for NutriFlow — see `../nutrition-planner-spec.md` for the
full product/technical spec this app implements.

## What's here

- **بنك الأكلات / النصائح / المشروبات / المكملات / المسموح-الممنوع** — full
  CRUD banks backed by Supabase (`lib/screens/*_bank`, `lib/screens/food_lists`).
- **خطط المريضات** — create a plan, then build it day-by-day: pick a bank
  recipe (optionally overriding quantities for that patient) or write a meal
  by hand, plus attach helper drinks and supplements to the plan
  (`lib/screens/plan_builder`).
- **تصدير PDF** — wired up to call the FastAPI service in
  `../NutriFlow-backend` and share the result via `share_plus`.

State is managed with Riverpod (`lib/providers`); data access lives in
`lib/services`; `lib/models` mirrors `../supabase/schema.sql`.

## Running it

1. Create a Supabase project (free tier) and run `../supabase/schema.sql`
   against it (SQL Editor, paste + run).
2. Get the project URL and anon/publishable key from
   Project Settings → API.
3. Run with those injected at compile time — nothing is hardcoded or
   committed:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=eyJ... \
     --dart-define=PDF_SERVICE_URL=https://your-pdf-service.onrender.com
   ```

   `PDF_SERVICE_URL` is optional while developing — the PDF export button
   will just show a "not configured yet" message without it.

   Prefer not to retype that every time? Put the same flags (one per line,
   `--dart-define=KEY=VALUE`) in a local `dart_define.txt` (already
   gitignored) and run `flutter run $(cat dart_define.txt)`, or use your
   IDE's run-configuration args field.

4. `flutter test` and `flutter analyze` both run without any of the above —
   the app degrades to a "setup required" screen instead of crashing when
   unconfigured, which is also what the default test asserts.

## Building for release

Same `--dart-define` flags apply to `flutter build apk`, `flutter build
macos`, `flutter build windows`, etc.

## Known gaps (see roadmap in the spec, step 6 onward)

- No dedicated "Plan Preview" screen yet — the day builder itself doubles as
  the editable preview; a true print-preview would mean embedding the PDF
  service's own rendering, which is next once that template is visually
  finalized.
- Image compression (`flutter_image_compress`) only has native codecs on
  Android/iOS/macOS/Web; on Windows/Linux desktop builds it uploads the
  original image instead of failing (see `lib/services/recipe_service.dart`).
