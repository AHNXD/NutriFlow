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
     --dart-define=SUPABASE_URL=https://fxfambjealokclkrbmaq.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=sb_publishable_s4k3LVhcwPHbbLhxkq5MxA_zKN_KBWo \
     --dart-define=PDF_SERVICE_URL=https://nutriflow-pdf.onrender.com
   ```

   Don't put real values directly in this file or commit them anywhere —
   see the `dart_define.txt` approach right below. RLS in
   `supabase/schema.sql` is permissive for v1, so this key currently grants
   full read/write access to the whole database to anyone who has it.

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

## Building a release APK for a tester

Config is compiled in at build time. Keep the values in a gitignored file
rather than typing them per build:

```json
// env/prod.json   (env/ is gitignored — it holds the anon key)
{
  "SUPABASE_URL": "https://<project>.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_...",
  "PDF_SERVICE_URL": "https://nutriflow-pdf.onrender.com"
}
```

```bash
flutter build apk --release --dart-define-from-file=env/prod.json
# -> build/app/outputs/flutter-apk/app-release.apk
```

Send that one file (universal APK — installs on any phone; don't use
`--split-per-abi` unless you know the tester's CPU). What the tester sees:

- Android blocks sideloading by default. Opening the APK prompts to allow
  installs from whichever app it arrived in (WhatsApp / Drive / Files), then
  Play Protect warns about an unknown developer — "install anyway".
- **The first PDF export takes 30–60 seconds.** The PDF service is on
  Render's free tier and spins down after ~15 minutes idle; the first
  request pays the cold start. Later exports are fast. Warn the tester or
  they will think the app hung.
- A free Supabase project pauses after 7 days with no activity, which shows
  up as every screen failing to load. Opening the dashboard resumes it.

Release builds are currently signed with the local **debug** key (see the
TODO in `android/app/build.gradle.kts`). That installs and runs fine for
testing, with two caveats: a build made on a different machine has a
different signature, so the tester would have to uninstall before
installing it; and Google Play will not accept it, nor will it accept the
`com.example.nutri_flow` application id. Both are only worth fixing when
you actually publish.

## Known gaps (see roadmap in the spec, step 6 onward)

- No dedicated "Plan Preview" screen yet — the day builder itself doubles as
  the editable preview; a true print-preview would mean embedding the PDF
  service's own rendering, which is next once that template is visually
  finalized.
- Image compression (`flutter_image_compress`) only has native codecs on
  Android/iOS/macOS/Web; on Windows/Linux desktop builds it uploads the
  original image instead of failing (see `lib/services/recipe_service.dart`).
