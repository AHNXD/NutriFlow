FROM python:3.12-slim-bookworm
# Pinned to Debian 12 (bookworm), not the floating `python:3.12-slim` tag —
# that tag recently moved to Debian 13 (trixie), which renamed
# libgdk-pixbuf2.0-0 to libgdk-pixbuf-2.0-0 and broke this build. Pinning
# avoids chasing renamed packages again on the next Debian bump.

# WeasyPrint needs Pango/Cairo/GDK-Pixbuf at the OS level — these aren't
# pip-installable. See https://doc.courtbouillon.org/weasyprint/stable/first_steps.html#linux
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

ENV PORT=8000
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
