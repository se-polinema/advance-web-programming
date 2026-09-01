#!/usr/bin/env bash
# Generate $SITE_DIR/index.html linking every available slide deck and
# jobsheet, one row per pertemuan.
#
# Usage: ./scripts/build-pages-index.sh [SITE_DIR]
#
# Run from the repo root, after:
#   - slides/bab*.md have been rendered into $SITE_DIR/slides/*.{html,pdf}
#   - jobsheets/pertemuan-*.md have been rendered into
#     $SITE_DIR/jobsheets/*.pdf, with the source .md copied alongside
#
# Titles are read from the original Markdown sources (slides/*.md,
# jobsheets/pertemuan-*.md), not from the built output, so this only needs
# plain grep/sed -- no HTML parsing.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

SITE_DIR="${1:-_site}"
OUT="$SITE_DIR/index.html"
mkdir -p "$SITE_DIR"

# Pertemuan number from a filename like slides/bab03-foo.md or
# jobsheets/pertemuan-03-foo.md -> "3" (strip leading zero for use as an
# array key / sort key; display re-pads to two digits).
pertemuan_num() {
  basename "$1" | grep -oE '[0-9]+' | head -1 | sed 's/^0*//'
}

# Slide topic: the lead slide's "Pertemuan N: **Topic**" line.
slide_title() {
  grep -m1 -oE 'Pertemuan [0-9]+: \*\*[^*]+\*\*' "$1" \
    | sed -E 's/Pertemuan [0-9]+: \*\*(.*)\*\*/\1/' || true
}

# Jobsheet topic: the H2 line right under the H1.
jobsheet_title() {
  sed -n '2p' "$1" | sed -E 's/^## //'
}

declare -A TITLES SLIDE_HTML SLIDE_PDF JOB_PDF JOB_MD
NUMS=""

for f in slides/bab*.md; do
  [ -f "$f" ] || continue
  n="$(pertemuan_num "$f")"
  [ -z "$n" ] && continue
  slug="$(basename "$f" .md)"
  t="$(slide_title "$f")"
  [ -n "$t" ] && TITLES["$n"]="$t"
  [ -f "$SITE_DIR/slides/$slug.html" ] && SLIDE_HTML["$n"]="slides/$slug.html"
  [ -f "$SITE_DIR/slides/$slug.pdf" ] && SLIDE_PDF["$n"]="slides/$slug.pdf"
  NUMS="$NUMS $n"
done

for f in jobsheets/pertemuan-*.md; do
  [ -f "$f" ] || continue
  n="$(pertemuan_num "$f")"
  [ -z "$n" ] && continue
  slug="$(basename "$f" .md)"
  t="$(jobsheet_title "$f")"
  if [ -z "${TITLES[$n]:-}" ] && [ -n "$t" ]; then
    TITLES["$n"]="$t"
  fi
  [ -f "$SITE_DIR/jobsheets/$slug.pdf" ] && JOB_PDF["$n"]="jobsheets/$slug.pdf"
  [ -f "$SITE_DIR/jobsheets/$slug.md" ] && JOB_MD["$n"]="jobsheets/$slug.md"
  NUMS="$NUMS $n"
done

SORTED_NUMS="$(echo "$NUMS" | tr ' ' '\n' | sed '/^$/d' | sort -n -u)"

rows=""
for n in $SORTED_NUMS; do
  padded="$(printf '%02d' "$n")"
  title="${TITLES[$n]:-Pertemuan $n}"

  slide_links="<span class=\"muted\">belum tersedia</span>"
  if [ -n "${SLIDE_HTML[$n]:-}" ] || [ -n "${SLIDE_PDF[$n]:-}" ]; then
    slide_links=""
    [ -n "${SLIDE_HTML[$n]:-}" ] && slide_links="$slide_links<a class=\"btn\" href=\"${SLIDE_HTML[$n]}\">Lihat</a>"
    [ -n "${SLIDE_PDF[$n]:-}" ] && slide_links="$slide_links<a class=\"btn\" href=\"${SLIDE_PDF[$n]}\">Unduh PDF</a>"
  fi

  job_links="<span class=\"muted\">belum tersedia</span>"
  if [ -n "${JOB_PDF[$n]:-}" ] || [ -n "${JOB_MD[$n]:-}" ]; then
    job_links=""
    [ -n "${JOB_PDF[$n]:-}" ] && job_links="$job_links<a class=\"btn\" href=\"${JOB_PDF[$n]}\">Unduh PDF</a>"
    [ -n "${JOB_MD[$n]:-}" ] && job_links="$job_links<a class=\"btn btn-outline\" href=\"${JOB_MD[$n]}\">Markdown</a>"
  fi

  rows="$rows
    <tr>
      <td class=\"num\">$padded</td>
      <td>$title</td>
      <td class=\"links\">$slide_links</td>
      <td class=\"links\">$job_links</td>
    </tr>"
done

cat > "$OUT" <<HTML
<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Pemrograman Web Lanjut — Materi Kuliah</title>
<style>
  :root { color-scheme: light dark; }
  body {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    max-width: 960px;
    margin: 0 auto;
    padding: 48px 24px 80px;
    color: #0f172a;
    background: #fff;
  }
  header { margin-bottom: 8px; }
  h1 { color: #1d4ed8; font-size: 1.8em; margin-bottom: 4px; }
  .subtitle { color: #475569; margin-top: 0; }
  table { width: 100%; border-collapse: collapse; margin-top: 32px; font-size: 0.95em; }
  th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #e2e8f0; vertical-align: top; }
  th { background: #1d4ed8; color: #fff; }
  td.num { font-weight: bold; color: #1d4ed8; width: 3em; }
  td.links { white-space: nowrap; }
  .btn {
    display: inline-block;
    background: #1d4ed8;
    color: #fff;
    text-decoration: none;
    padding: 4px 10px;
    border-radius: 5px;
    font-size: 0.85em;
    margin: 2px 4px 2px 0;
  }
  .btn:hover { background: #1e40af; }
  .btn-outline { background: transparent; color: #1d4ed8; border: 1px solid #1d4ed8; }
  .btn-outline:hover { background: #eff6ff; }
  .muted { color: #94a3b8; font-size: 0.85em; }
  footer { margin-top: 48px; padding-top: 16px; border-top: 1px solid #e2e8f0; color: #64748b; font-size: 0.85em; }
  footer a { color: #1d4ed8; }
  code { background: #f1f5f9; padding: 1px 5px; border-radius: 4px; }
  @media (prefers-color-scheme: dark) {
    body { background: #0f172a; color: #e2e8f0; }
    .subtitle { color: #94a3b8; }
    th, td { border-bottom-color: #1e293b; }
    .btn-outline { color: #93c5fd; border-color: #93c5fd; }
    .btn-outline:hover { background: #1e293b; }
    footer { border-top-color: #1e293b; color: #94a3b8; }
    code { background: #1e293b; color: #e2e8f0; }
  }
</style>
</head>
<body>
<header>
  <h1>Pemrograman Web Lanjut</h1>
  <p class="subtitle">SIB245007 &middot; D-IV Sistem Informasi Bisnis &mdash; Slide dan jobsheet praktikum, per pertemuan.</p>
</header>

<table>
  <tr>
    <th>Pertemuan</th>
    <th>Materi</th>
    <th>Slide</th>
    <th>Jobsheet</th>
  </tr>$rows
</table>

<footer>
  Kode praktikum Simple POS: <a href="https://github.com/se-polinema/simple-pos">github.com/se-polinema/simple-pos</a>
  &middot; Sumber materi: <a href="https://github.com/se-polinema/advance-web-programming">github.com/se-polinema/advance-web-programming</a>
</footer>
</body>
</html>
HTML

echo "Wrote $OUT ($(echo "$SORTED_NUMS" | wc -l | tr -d ' ') pertemuan)"
