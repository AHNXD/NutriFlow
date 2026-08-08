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

**"SSL: CERTIFICATE_VERIFY_FAILED" when a recipe/logo image is fetched:**
python.org's macOS installer doesn't register Python with the system CA
store, so WeasyPrint's own image fetch (not `httpx`, which uses `certifi`
regardless) can't verify HTTPS certs. Fix by pointing Python at `certifi`'s
bundle:

```bash
SSL_CERT_FILE="$(python -c 'import certifi; print(certifi.where())')" uvicorn app.main:app --reload
```

This only affects local runs on a python.org-installed interpreter — Render's
container doesn't have this problem.

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

## PDF designs and palettes

A plan's export is described by two independent columns on `plans`:

| Column | Meaning | Catalog |
|---|---|---|
| `pdf_layout` | the **design** — page composition, typography, how a meal is drawn | `app/layouts.py` |
| `theme` | the **palette** — five CSS custom properties | `app/themes.py` |

Any design renders in any palette, so five designs × eight palettes = 40
combinations. Both catalogs are mirrored on the Flutter side
(`nutri_flow/lib/theme/pdf_layouts.dart` and `pdf_themes.dart`) and the ids
must stay identical, since the id is what's stored and sent.

Each design is a directory under `app/templates/layouts/<id>/` holding
`cover.html`, `day.html`, `notes.html` and `styles.css`. `plan.html`
dispatches to it by id, so **adding a sixth design is a new directory plus
one entry in `layouts.py`** — nothing else in the pipeline counts them.
Shared page geometry, the meal grid and the header scaffold live in
`app/templates/shared.css`.

**Read the comment block at the top of `shared.css` before touching any
stylesheet.** WeasyPrint silently drops a surprising set of modern CSS —
all logical properties (`padding-inline-start`, `inset-inline-start`,
`inline-size`), `box-shadow`, `text-shadow`, flex `gap`, `background-size`
on gradients, and any gradient containing the `transparent` keyword. None
of these warn; the page just renders wrong. The document is always
`dir="rtl"`, so write physical properties (inline-start = `right`).

### Previewing without a database

`tools/preview_pdf.py` renders a realistic sample plan through the real
renderer — no Supabase, no plan id:

```bash
python tools/make_sample_photos.py            # once: placeholder meal photos
python tools/preview_pdf.py                   # every design, default palette
python tools/preview_pdf.py --layout noir --theme sand
python tools/preview_pdf.py --all-themes      # the whole matrix
```

PDFs land in `/tmp/nutriflow-previews/`. On macOS, `tools/rasterize.sh
<pdf>` splits one into per-page PNGs for eyeballing or diffing. The sample
plan deliberately includes a day with a single meal, a meal with no photo
and a meal with no tip, since those are the paths that break layouts.

## Deploying to Render (free tier)

Render builds this service from the `Dockerfile` in this folder — that's
what pulls in WeasyPrint's system libraries (Pango/Cairo/GDK-Pixbuf), which
a plain "Python" buildpack can't install. Deploys come from a connected Git
repo, so the code needs to be on GitHub/GitLab/Bitbucket first.

**1. Push the code, if you haven't.** NutriFlow-backend lives inside the
same repo as the Flutter app (a monorepo) — that's fine, Render lets you
point a service at a subfolder (step 4 below).

```bash
git push origin main
```

**2. Create a Render account and connect GitHub.** Go to
[render.com](https://render.com), sign up (GitHub login is easiest — it
handles the connection for you), and if asked, grant Render access to
either all repos or just this one (`AHNXD/NutriFlow`).

**3. Start a new Web Service.** From the Render dashboard: **New +** (top
right) → **Web Service**. Pick the `NutriFlow` repo from the list — if it's
not there, click "Configure account" to adjust which repos Render can see.

**4. Configure the service:**

| Field | Value |
|---|---|
| Name | `nutriflow-pdf` (or anything — this becomes part of the URL) |
| Root Directory | `NutriFlow-backend` — **important**: without this, Render tries to build from the repo root and won't find the Dockerfile |
| Region | whichever is closest to you/the dietitian |
| Branch | `main` |
| Language/Runtime | **Docker** — Render should auto-detect the `Dockerfile` once Root Directory is set correctly; if it instead offers a "Python 3" runtime, switch it to Docker manually |
| Instance Type | **Free** |

**5. Add environment variables.** Still on the same creation screen, under
"Environment Variables" (or Advanced → Add Environment Variable), add:

- `SUPABASE_URL` — your project URL.
- `SUPABASE_SERVICE_ROLE_KEY` — from the Supabase dashboard: **Project
  Settings → API Keys**. Grab the **service_role** key (shown as `secret`
  / `sb_secret_...` on newer Supabase projects, or listed under "Legacy API
  keys" as `service_role` on older ones). This is *not* the same key the
  Flutter app uses — it bypasses RLS entirely, so it only ever belongs
  here, never in the app or in git.

**6. Create Web Service.** Render clones the repo, builds the Docker image
(expect several minutes the first time — installing the apt packages plus
`pip install -r requirements.txt` isn't instant), and deploys it. Watch
progress in the **Logs** tab; a successful deploy ends with something like
`Uvicorn running on http://0.0.0.0:$PORT`. You don't need to set `PORT`
yourself — Render injects it and the Dockerfile's `CMD` already reads it.

**7. Verify it's actually up.** Render gives you a URL shaped like
`https://nutriflow-pdf.onrender.com`. Test the health check first (fast,
no Supabase round-trip):

```bash
curl https://nutriflow-pdf.onrender.com/health
# {"status":"ok"}
```

Then a real PDF, once you have at least one plan in the database:

```bash
curl -X POST https://nutriflow-pdf.onrender.com/generate-plan-pdf \
  -H "Content-Type: application/json" \
  -d '{"plan_id": "<uuid-from-plans-table>"}' \
  -o test-plan.pdf
```

**8. Point the Flutter app at it.** Add `--dart-define=PDF_SERVICE_URL=https://nutriflow-pdf.onrender.com`
to however you run/build the app (see `../nutri_flow/README.md`).

**9. Know the free-tier trade-offs** (two separate things, easy to conflate):

- **Render**: a free Web Service spins down after ~15 minutes with no
  incoming requests, and the *next* request pays a cold-start cost (often
  30-60s) while it spins back up. There's no free-tier way around this
  short of upgrading to a paid instance — an occasional keep-alive ping
  does not prevent it, since 15 minutes is a short window to keep pinging
  against. In practice this just means: the first PDF export after a
  while feels slow, subsequent ones are fast. Worth telling the dietitian
  this up front so it doesn't look broken.
- **Supabase**: a free project pauses after **7 days** of no API activity
  (different mechanism, different timescale). *This* is what the n8n
  keep-alive workflow in spec §2/§7 is actually for — an HTTP Request node
  hitting this service's `/health` (or any Supabase REST endpoint) every
  24-48h keeps the Supabase project active. It won't do anything for
  Render's 15-minute spin-down.

**10. Redeploys.** Render auto-deploys on every push to `main` by default
(toggle under the service's Settings if you'd rather deploy manually).

## Status

Templates render a complete plan (cover → one page per day → instructions →
allowed/forbidden → supplements & drinks → closing page) in five designs and
eight palettes — all 40 combinations verified locally end-to-end with
WeasyPrint against synthetic data, including the empty-section, no-photo and
single-meal paths. RTL Arabic text and the bundled Cairo font both render
correctly.

Known limit: a day with roughly seven or more meals still overflows onto a
continuation page that carries no header. Each design is tuned so a typical
five-to-six-meal day clears one sheet.
