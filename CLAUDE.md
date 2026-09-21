# Repository instructions

## General

- Do not use em-dashes (—) in any generated content (slides, jobsheets, docs, commit messages, code comments). Use a comma, colon, parentheses, or split into two sentences instead.
- Never mention "buku" (the book) or "Bab N" (Chapter N) in student-facing content (slides, jobsheets). Always frame material around "Pertemuan N" (the course meeting), never the book chapter.
- Repository references in student-facing content always point to `github.com/se-polinema/...` (the official org). Never reference a personal fork or username.
- Never `git commit`/`git push` without an explicit instruction to do so in that turn. Stage only what was asked; leave unrelated pre-existing changes untouched.
- Write plain, everyday Indonesian in Indonesian-language content. Avoid stilted, literary, or translation-flavored phrasing. Keep standard technical jargon (route, controller, commit, push, pull, branch, merge, hot reload, dst.) in English rather than coining awkward Indonesian translations for it.

## Slides (`slides/id/*.md`, `slides/en/*.md`)

- Every deck ships bilingual: `slides/id/babNN-slug.md` and `slides/en/babNN-slug.md`, identical filename stem, identical slide count and structure.
- Reuse the shared Marp frontmatter/CSS block verbatim across decks (`.term-box`/`.tip-box`/`.warn-box`/`.cols`/`.flow`/`.stack`/`.ref-link` classes) — copy it from the most recent deck rather than inventing new styles.
- Standard structure: lead title slide (course name, code, "Pertemuan N: **Topic**") → objectives slide ("Yang Akan Kamu Pelajari"/"What You'll Learn", phrased at the CONCEPT level, not listing specific commands or deliverables) → "Bagian N"/"Part N" divider slides → content slides → "Rangkuman"/"Summary" → closing lead slide "Referensi & Diskusi"/"References & Discussion" announcing "Pertemuan berikutnya"/"Next meeting".
- Slides teach theory/concept with generic, domain-neutral illustrative examples (the established generic domain across this course is `authors`/`articles`/`comments` — reuse it for new decks rather than inventing a new one). The Simple POS case study is the practice vehicle, not the teaching vehicle: it should appear only as "minimal bridge mentions" (the intro tip-box, at most one dedicated bridge slide pointing to the jobsheet, and the closing references slide's repo link), never as the actual code shown on a concept-teaching slide.
- For genuinely central mechanisms (e.g. how a template engine works, how migrations form a history, how an index changes a query plan), add a dedicated concept-visualization slide using `.flow`/`.cols`, not just prose.
- For spec-heavy topics (HTTP methods/status codes, Blade directives, Tailwind classes, Alpine attributes), give a brief in-deck summary plus a `.ref-link` to the official docs rather than reproducing the full spec.
- Build via the Marp CLI Docker image, not `npx`: `docker run --rm --init -v "$PWD:/home/marp/app" -e LANG="$LANG" --entrypoint node marpteam/marp-cli /home/marp/.cli/marp-cli.js <file> --html|--pdf --allow-local-files -o <out>` (the image's entrypoint silently no-ops without the explicit `--entrypoint node .../marp-cli.js` script path).
- Before considering a deck done: confirm id/en page counts match exactly, visually inspect every slide for overflow/clipping (`pdftoppm -r 60-80` per slide + `montage` into a grid + read the grid image), and grep-sweep for em-dashes and "buku"/"Bab N".

## Jobsheets (`jobsheets/pertemuan-NN-slug.md`)

- Start new jobsheets from `jobsheets/TEMPLATE.md`'s structure: metadata table → A. Capaian Praktikum → B. Persiapan dan Prasyarat → C. Langkah Kerja → D. Tugas dan Deliverable → E. Kriteria Penilaian.
- Each Langkah: short "why" narrative → code/command block → `> ✅ **Checkpoint:**` → optional `> ⚠️ **Jika gagal:**`. Show the FULL contents of any file being edited, never a diff or snippet, so students can copy-paste directly.
- **Starting code**: each meeting has its own standalone GitHub **template repository** at `github.com/se-polinema/simple-pos-chNN` (a real `is_template: true` repo, not a branch of the monorepo). "Kode Awal" for Pertemuan N references `simple-pos-ch(N-1)`, created via GitHub's "Use this template → Create a new repository" flow, not `git clone -b`. There is no "Kode Akhir" row. Pertemuan and chapter numbers only match 1:1 through Pertemuan 7; after that they diverge (check `book/docs/book-plan.md`'s Minggu→Bab mapping before assuming pertemuan-NN = chNN). Repos only exist through `simple-pos-ch12` as of this writing; verify with `gh api repos/se-polinema/simple-pos-chNN` before referencing a new one.
- When a checkpoint depends on the starting repo's actual state (a specific error, a specific top commit message, specific files present), verify it against the real repo via `gh api` before writing it. Don't assume from the book text or from a previous meeting's jobsheet.
- **Starting Pertemuan 3 (every meeting after the 2nd), jobsheets are group assignments** (Pertemuan 1-2 stay individual). For group jobsheets:
  - Metadata table gets a **Mode Pengerjaan** row: `Kelompok (sesuai pembagian dosen), satu repositori GitHub bersama per kelompok`.
  - One member creates the shared repo from the meeting's template repo and adds every other member plus the lecturer as collaborators.
  - Git workflow is **feature branch + Pull Request**, never a single-branch relay: `checkout main && pull && checkout -b <branch>` → work → commit → `push -u origin <branch>` → open a PR → **merge with "Create a merge commit", never "Squash and merge"** (squashing collapses every member's commits into one, breaking the per-member contribution grading criterion below).
  - Branch names are English words describing the task (e.g. `base-layout`, `alpine-cart`), not Indonesian; commit messages stay Indonesian, matching the course's `increment N: ...` convention.
  - Do not assign specific steps to specific numbered members (no "Anggota 1 does X, Anggota 2 does Y"). State the steps generically and leave dividing the work up to the group itself, noting only that the split should leave each member with at least one meaningful commit.
  - Never mention "Asisten" (teaching assistant); grading/submission language says "dosen" only.
  - Grading rubric (Section E) splits group components (steps complete, checkpoints verified) from an individual **"Kontribusi per anggota"** component, verified via `git log --pretty="%h %an %s"` showing every member's name.
- When a step creates a brand-new file Laravel has a generator for, use the real `php artisan make:*` command (`make:view <dot.notation>` for a plain Blade view, `make:component <name> --view` for an anonymous/class-less component, `make:controller`, `make:migration`, etc.) instead of "buat berkas baru". Verify the exact command/flags against official Laravel docs for the version in use before adding it, don't guess.
- Build via `jobsheets/build.sh <file>.md` (pandoc + lualatex, using `jobsheets/assets/header.tex`). Before considering a jobsheet done: rebuild the PDF, visually inspect **every page** (`pdftoppm` + `montage` + read the grid image) for overflow, especially wide tables and long inline code paths near a line-wrap boundary (pandoc's LaTeX table columns and inline code spans don't always wrap the way expected), and grep-sweep for em-dashes, "buku"/"Bab N", and "Asisten".
