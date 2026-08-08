#!/usr/bin/env bash
# Dev-only: split a preview PDF into per-page PNGs so the pages can be
# viewed (or diffed) as images. macOS only — uses sips, which converts just
# the first page of a PDF, so pages are split with pypdf first.
#
#   tools/rasterize.sh /tmp/nutriflow-previews/aurora-emerald.pdf
set -euo pipefail

PDF="$1"
BASE="$(basename "${PDF%.pdf}")"
OUT="$(dirname "$PDF")/png/$BASE"
VENV_PY="$(cd "$(dirname "$0")/.." && pwd)/.venv/bin/python"

rm -rf "$OUT"
mkdir -p "$OUT"

"$VENV_PY" - "$PDF" "$OUT" <<'PY'
import sys
from pypdf import PdfReader, PdfWriter

src, out = sys.argv[1], sys.argv[2]
reader = PdfReader(src)
for i, page in enumerate(reader.pages, start=1):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"{out}/p{i:02d}.pdf", "wb") as fh:
        writer.write(fh)
print(len(reader.pages))
PY

for f in "$OUT"/*.pdf; do
  sips -s format png -Z 1400 "$f" --out "${f%.pdf}.png" >/dev/null
  rm "$f"
done

echo "$OUT"
ls "$OUT"
