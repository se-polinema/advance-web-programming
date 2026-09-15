#!/usr/bin/env bash
# Render jobsheets/pertemuan-*.md (Indonesian, at the root) and
# jobsheets/en/pertemuan-*.md (English) into A4 PDFs under jobsheets/build/,
# English output going to jobsheets/build/en/ to avoid filename collisions
# with its Indonesian counterpart.
#
# Usage: ./build.sh                            (build all: root + en/)
#        ./build.sh FILE.md                    (build a single Indonesian file)
#        ./build.sh en/FILE.md                 (build a single English file)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
mkdir -p build build/en

PANDOC_OPTS=(
  --pdf-engine=lualatex
  -V papersize=a4
  -V geometry:margin=2cm
  -V mainfont="DejaVu Sans"
  -V monofont="DejaVu Sans Mono"
  -V fontsize=10pt
  -V colorlinks
  --include-in-header=assets/header.tex
)

build_one() {
  local src="$1"
  local name outdir
  name="$(basename "${src%.md}")"
  outdir="build"
  case "$src" in
    en/*) outdir="build/en" ;;
  esac
  echo "==> ${src}"
  pandoc "$src" -o "${outdir}/${name}.pdf" "${PANDOC_OPTS[@]}"
}

if [ "$#" -gt 0 ]; then
  build_one "$1"
else
  shopt -s nullglob
  for f in pertemuan-*.md; do
    build_one "$f"
  done
  for f in en/pertemuan-*.md; do
    build_one "$f"
  done
fi
