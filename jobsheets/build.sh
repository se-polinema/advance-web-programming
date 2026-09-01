#!/usr/bin/env bash
# Render every jobsheets/pertemuan-*.md into an A4 PDF under jobsheets/build/.
#
# Usage: ./build.sh          (build all)
#        ./build.sh FILE.md  (build a single file)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
mkdir -p build

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
  local name
  name="$(basename "${src%.md}")"
  echo "==> ${name}"
  pandoc "$src" -o "build/${name}.pdf" "${PANDOC_OPTS[@]}"
}

if [ "$#" -gt 0 ]; then
  build_one "$1"
else
  shopt -s nullglob
  for f in pertemuan-*.md; do
    build_one "$f"
  done
fi
