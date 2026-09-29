#!/bin/bash
# Build a single chapter or appendix as a standalone PDF
# Usage: ./scripts/build-standalone.sh <lang> <type> <name>
#   lang: id or en
#   type: chapter or appendix
#   name: source filename without .tex extension, e.g. chapter01-arsitektur-web-modern
#
# Examples:
#   ./scripts/build-standalone.sh en chapter chapter01-arsitektur-web-modern
#   ./scripts/build-standalone.sh id appendix instalasi
#   ./scripts/build-standalone.sh en appendix installation-guide

set -e

LANG=${1}
TYPE=${2}
NAME=${3}

if [ -z "$LANG" ] || [ -z "$TYPE" ] || [ -z "$NAME" ]; then
    echo "Usage: $0 <lang> <type> <name>"
    echo "  lang: id or en"
    echo "  type: chapter or appendix"
    echo "  name: source filename without .tex extension"
    echo "Example: $0 en chapter chapter01-arsitektur-web-modern"
    echo "Example: $0 id appendix instalasi"
    exit 1
fi

if [ "$LANG" != "id" ] && [ "$LANG" != "en" ]; then
    echo "Error: lang must be 'id' or 'en'"
    exit 1
fi

if [ "$TYPE" != "chapter" ] && [ "$TYPE" != "appendix" ]; then
    echo "Error: type must be 'chapter' or 'appendix'"
    exit 1
fi

# chapter -> chapters/, appendix -> appendices/
if [ "$TYPE" = "chapter" ]; then
    SOURCE_DIR="chapters"
else
    SOURCE_DIR="appendices"
fi

SOURCE_FILE="${SOURCE_DIR}/${LANG}/${NAME}.tex"
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file not found: $SOURCE_FILE"
    exit 1
fi

# Reuse SOURCE_DIR ("chapters"/"appendices") so output mirrors the source
# layout instead of naively pluralizing $TYPE (which would give "appendixs").
#
# latexmk's own working files (wrapper.tex, .aux/.log/.fdb_latexmk/wrapper.pdf)
# live under a hidden per-item cache dir, kept separate from OUTPUT_DIR so
# that directory only ever contains clean, friendly-named final PDFs -
# nothing else to sift through when browsing build/.
OUTPUT_DIR="build/${SOURCE_DIR}/${LANG}"
CACHE_DIR="build/.cache/${SOURCE_DIR}/${LANG}/${NAME}"
mkdir -p "$OUTPUT_DIR" "$CACHE_DIR"

WRAPPER="${CACHE_DIR}/${NAME}.wrapper.tex"

if [ "$LANG" = "id" ]; then
    INDONESIAN_FLAG="\\Indonesiantrue"
    ENGLISH_FLAG="\\Englishfalse"
    SELECT_LANG="\\selectlanguage{indonesian}"
else
    INDONESIAN_FLAG="\\Indonesianfalse"
    ENGLISH_FLAG="\\Englishtrue"
    SELECT_LANG="\\selectlanguage{english}"
fi

# Appendices need \appendix before \input so they get letter numbering
# (A, B, ...) and appendix-style chapter headings instead of numeric ones.
if [ "$TYPE" = "appendix" ]; then
    APPENDIX_SWITCH="\\appendix"
else
    APPENDIX_SWITCH=""
fi

cat > "$WRAPPER" << EOF
%% Standalone ${TYPE} wrapper - auto-generated
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
${APPENDIX_SWITCH}
\input{${SOURCE_FILE%.tex}}
\printbibliography
\end{document}
EOF

echo "Building: ${NAME} (${LANG}, ${TYPE})"

# latexmk can report a nonzero exit from a biber/makeindex rerun race even
# though it fully converged and wrote a complete PDF within that same
# invocation - and a second invocation does NOT fix this, since latexmk
# remembers "a previous invocation failed" and re-reports a nonzero exit
# even when it does zero work and confirms the file is up-to-date (see
# Makefile's book-id/book-en rules for the same issue at the top level). So
# don't retry: just check whether the PDF actually exists and treat that as
# the real success signal.
latexmk -pdf -bibtex -interaction=nonstopmode -file-line-error \
    -outdir="${CACHE_DIR}" "$WRAPPER" || true

CACHE_PDF="${CACHE_DIR}/${NAME}.wrapper.pdf"
FINAL_PDF="${OUTPUT_DIR}/${NAME}.pdf"
if [ -f "$CACHE_PDF" ]; then
    cp -f "$CACHE_PDF" "$FINAL_PDF"
    echo "Output: $FINAL_PDF"
else
    echo "Error: PDF not generated"
    exit 1
fi
