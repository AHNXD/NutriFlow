# NutriFlow — PDF service

FastAPI service that turns one `plans` row (plus its days/meals/drinks/
supplements) into a formatted, RTL, Arabic PDF — see
`../nutrition-planner-spec.md` §6 for the full design brief.

## Endpoints

- `POST /generate-plan-pdf` — body `{"plan_id": "<uuid>"}`, returns the PDF
  as `application/pdf`.
- `GET /health` (and `GET /`) — used by the n8n keep-alive ping (spec §2, §7).

## Local setup

WeasyPrint needs a few OS-level libraries (Pango/Cairo/GDK-Pixbuf) that pip
can't install for you:

```bash
# macOS
brew install pango gdk-pixbuf libffi

# Debian/Ubuntu
sudo apt-get install libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 \
  libgdk-pixbuf2.0-0 libffi-dev shared-mime-info
```

Then:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

cp .env.example .env   # fill in SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY
                        # (Project Settings → API in the Supabase dashboard —
                        # this is the SERVICE ROLE key, not the anon key)

uvicorn app.main:app --reload
```

**Apple Silicon macOS note:** even after `brew install`, Python's `ctypes` may
not find the Homebrew libs on its own (`OSError: cannot load library
'libgobject-2.0-0'`). If that happens, run uvicorn with:

```bash
DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib" uvicorn app.main:app --reload
```

Try it once you have at least one plan in the database:

```bash
curl -X POST http://127.0.0.1:8000/generate-plan-pdf \
  -H "Content-Type: application/json" \
  -d '{"plan_id": "<uuid-from-plans-table>"}' \
  -o test-plan.pdf
```

## Fonts

`app/fonts/Cairo-Variable.ttf` (SIL OFL 1.1, see `app/fonts/OFL.txt`) is
bundled so PDF generation never depends on network access, per spec §6.

## Deploying to Render (free tier)

1. New Web Service → point at this repo/subfolder, or push the
   included `Dockerfile`.
2. Set env vars `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in the Render
   dashboard (never commit `.env`).
3. Render sets `$PORT` automatically — the Dockerfile's CMD already reads it.
4. Point the Flutter app's `PDF_SERVICE_URL` dart-define at the resulting
   `https://<name>.onrender.com` URL.
5. Add an n8n workflow that pings `/health` (and the Supabase REST root)
   every 24-48h so the free instance doesn't spin down / pause.

## Status

Templates render a complete plan (cover → one page per day → instructions →
allowed/forbidden → supplements → drinks → closing page) — verified locally
end-to-end with WeasyPrint against synthetic data, RTL Arabic text and the
bundled Cairo font both render correctly. The visual design is a first
pass, not a pixel-match to the Gamma reference mentioned in the spec —
expect a design-polish iteration once the dietitian has real data to
look at.
