#!/bin/bash
# Build a single chapter as a standalone PDF
# Usage: ./scripts/build-chapter.sh <lang> <chapter>
# Example: ./scripts/build-chapter.sh en chapter01-mengapa-gagal
#          ./scripts/build-chapter.sh id chapter05-pemantauan-dan-manajemen-cacat

set -e

LANG=${1}
CHAPTER=${2}

if [ -z "$LANG" ] || [ -z "$CHAPTER" ]; then
    echo "Usage: $0 <lang> <chapter>"
    echo "  lang:    id or en"
    echo "  chapter: chapter filename without .tex extension"
    echo "Example: $0 en chapter01-mengapa-gagal"
    exit 1
fi

if [ "$LANG" != "id" ] && [ "$LANG" != "en" ]; then
    echo "Error: lang must be 'id' or 'en'"
    exit 1
fi

CHAPTER_FILE="chapters/${LANG}/${CHAPTER}.tex"
if [ ! -f "$CHAPTER_FILE" ]; then
    echo "Error: Chapter file not found: $CHAPTER_FILE"
    exit 1
fi

OUTPUT_DIR="output/chapters"
mkdir -p "$OUTPUT_DIR"

WRAPPER="${OUTPUT_DIR}/chapter-${LANG}-${CHAPTER}.tex"

if [ "$LANG" = "id" ]; then
    INDONESIAN_FLAG="\\Indonesiantrue"
    ENGLISH_FLAG="\\Englishfalse"
    SELECT_LANG="\\selectlanguage{indonesian}"
else
    INDONESIAN_FLAG="\\Indonesianfalse"
    ENGLISH_FLAG="\\Englishtrue"
    SELECT_LANG="\\selectlanguage{english}"
fi

cat > "$WRAPPER" << EOF
%% Standalone chapter wrapper - auto-generated
\documentclass[
    a4paper,
    12pt,
    twoside,
    openright,
    bibliography=totoc,
]{scrbook}

\newif\ifIndonesian
\newif\ifEnglish
${INDONESIAN_FLAG}
${ENGLISH_FLAG}

\input{preamble}
${SELECT_LANG}

\begin{document}
\mainmatter
\input{${CHAPTER_FILE%.tex}}
\printbibliography
\end{document}
EOF

echo "Building: ${CHAPTER} (${LANG})"

latexmk -pdf -bibtex -interaction=nonstopmode -file-line-error \
    -outdir="${OUTPUT_DIR}" \
    "$WRAPPER"

OUTPUT_PDF="${OUTPUT_DIR}/chapter-${LANG}-${CHAPTER}.pdf"
if [ -f "$OUTPUT_PDF" ]; then
    echo "Output: $OUTPUT_PDF"
else
    echo "Error: PDF not generated"
    exit 1
fi
