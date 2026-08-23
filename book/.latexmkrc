# ========================================================================
# latexmk Configuration File
# ========================================================================

# Use pdflatex by default
$pdf_mode = 1;

# Use biber for bibliography
$bibtex_use = 2;

# PDF viewer configuration (used only when -pvc flag is passed explicitly)
$pdf_previewer = 'zathura %O %S';

# Do not auto-open viewer after build; use 'make view-id' / 'make view-en' instead
$preview_mode = 0;

# Extra pdflatex options
$pdflatex = 'pdflatex -interaction=nonstopmode -file-line-error %O %S';

# Clean extra extensions
$clean_ext = 'aux bbl bcf blg fdb_latexmk fls lof log lot out run.xml synctex.gz toc idx ilg ind lol nav snm vrb';

# Force biber to run
$biber = 'biber %O %S';

# Use indexstyle.ist so latexmk's makeindex call matches imakeidx's call,
# preventing oscillation between styled (149 lines) and unstyled (129 lines) index output.
# Resolved to an absolute path (relative to this rc file) so it still resolves
# when latexmk runs with -outdir set to a subdirectory, e.g. output/chapters/
# for standalone `make chapter` builds.
use Cwd 'abs_path';
use File::Basename;
my $indexstyle = abs_path(dirname(__FILE__) . '/indexstyle.ist');
$makeindex = "makeindex -s $indexstyle %O -o %D %S";

# Maximum number of runs
$max_repeat = 5;

# Force mode - continue even if there are errors (important for CI/CD)
# This ensures we get a PDF even with warnings/undefined references on first pass
$force_mode = 1;

# Remove output directory on clean
$out_dir = '';

# Generate PDF using pdflatex
$postscript_mode = 0;
$dvi_mode = 0;

# Warnings
$warnings_as_errors = 0;

# Files to watch for changes (bilingual entry points)
@default_files = ('book-id.tex', 'book-en.tex');

# Extra file extensions to clean
push @generated_exts, 'synctex.gz', 'run.xml', 'bcf', 'nav', 'snm', 'vrb', 'lol';
