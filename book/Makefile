# ========================================================================
# Makefile untuk Kompilasi Buku LaTeX - Bilingual Support
# "Laravel Praktis" / "Practical Laravel" - Menggunakan latexmk untuk
# automasi kompilasi
# ========================================================================

# File utama untuk setiap bahasa
BOOK_ID = book-id
BOOK_EN = book-en

# PDF Viewer
VIEWER = zathura

# latexmk configuration
LATEXMK = latexmk
LATEXMK_FLAGS = -pdf -bibtex -interaction=nonstopmode -file-line-error

# Chapters list
CHAPTERS = chapter01-arsitektur-web-modern \
           chapter02-http-dan-mvc \
           chapter03-blade-dan-tailwind \
           chapter04-desain-basis-data \
           chapter05-eloquent-dan-relasi \
           chapter06-validasi-input \
           chapter07-autentikasi-dan-otorisasi \
           chapter08-pengolahan-data \
           chapter09-membangun-rest-api \
           chapter10-pengujian-aplikasi \
           chapter11-optimasi-dan-deployment \
           chapter12-studi-kasus-menyeluruh

# ========================================================================
# Target Utama
# ========================================================================

.PHONY: all id en both \
        clean cleanall view view-id view-en watch watch-id watch-en \
        quick quick-id quick-en checkerrors checkref wordcount help check-deps \
        chapters chapters-id chapters-en secure secure-id secure-en

# Default target - build Indonesian version (backward compatibility)
all: id

# Build Indonesian version
id: $(BOOK_ID).pdf

# Build English version
en: $(BOOK_EN).pdf

# Build both versions
both: id en

SOURCES_ID = $(BOOK_ID).tex preamble.tex references.bib \
             $(wildcard chapters/id/*.tex) $(wildcard frontmatter/id/*.tex) \
             $(wildcard appendices/id/*.tex)
SOURCES_EN = $(BOOK_EN).tex preamble.tex references.bib \
             $(wildcard chapters/en/*.tex) $(wildcard frontmatter/en/*.tex) \
             $(wildcard appendices/en/*.tex)

# Kompilasi Indonesian PDF
$(BOOK_ID).pdf: $(SOURCES_ID)
	@echo "========================================="
	@echo "Kompilasi versi Indonesia dengan latexmk"
	@echo "========================================="
	$(LATEXMK) $(LATEXMK_FLAGS) $(BOOK_ID).tex
	@echo "========================================="
	@echo "Kompilasi selesai! File: $(BOOK_ID).pdf"
	@echo "========================================="

# Kompilasi English PDF
$(BOOK_EN).pdf: $(SOURCES_EN)
	@echo "========================================="
	@echo "Compiling English version with latexmk"
	@echo "========================================="
	$(LATEXMK) $(LATEXMK_FLAGS) $(BOOK_EN).tex
	@echo "========================================="
	@echo "Compilation complete! File: $(BOOK_EN).pdf"
	@echo "========================================="

# Build all chapters individually for both languages
chapters: chapters-id chapters-en

# Build all Indonesian chapters individually
chapters-id:
	@echo "Building all Indonesian chapters..."
	@for chapter in $(CHAPTERS); do \
		echo "Building ID chapter: $$chapter"; \
		./scripts/build-chapter.sh id $$chapter; \
	done
	@echo "All Indonesian chapters built in output/chapters/"

# Build all English chapters individually
chapters-en:
	@echo "Building all English chapters..."
	@for chapter in $(CHAPTERS); do \
		echo "Building EN chapter: $$chapter"; \
		./scripts/build-chapter.sh en $$chapter; \
	done
	@echo "All English chapters built in output/chapters/"

# Build a single chapter: make chapter LANG=en CHAPTER=chapter01-pengantar-flutter
chapter:
	@if [ -z "$(LANG)" ] || [ -z "$(CHAPTER)" ]; then \
		echo "Usage: make chapter LANG=<id|en> CHAPTER=<chapter-name>"; \
		exit 1; \
	fi
	./scripts/build-chapter.sh $(LANG) $(CHAPTER)

# Kompilasi cepat (single pass)
quick: quick-id

quick-id:
	@echo "Kompilasi cepat versi Indonesia..."
	$(LATEXMK) -pdf -interaction=nonstopmode $(BOOK_ID).tex

quick-en:
	@echo "Quick compile English version..."
	$(LATEXMK) -pdf -interaction=nonstopmode $(BOOK_EN).tex

# Watch mode - kompilasi otomatis saat file berubah
watch: watch-id

watch-id:
	@echo "========================================="
	@echo "Mode Watch Indonesia - Kompilasi otomatis aktif"
	@echo "Tekan Ctrl+C untuk berhenti"
	@echo "========================================="
	$(LATEXMK) -pdf -bibtex -pvc -interaction=nonstopmode $(BOOK_ID).tex

watch-en:
	@echo "========================================="
	@echo "Watch Mode English - Auto-compilation active"
	@echo "Press Ctrl+C to stop"
	@echo "========================================="
	$(LATEXMK) -pdf -bibtex -pvc -interaction=nonstopmode $(BOOK_EN).tex

# Bersihkan file temporary
clean:
	@echo "Membersihkan file temporary..."
	$(LATEXMK) -c $(BOOK_ID).tex $(BOOK_EN).tex
	rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.bcf *.run.xml
	rm -f *.idx *.ilg *.ind *.lol *.nav *.snm *.vrb
	rm -f chapters/id/*.aux chapters/en/*.aux
	rm -f frontmatter/id/*.aux frontmatter/en/*.aux
	rm -f appendices/id/*.aux appendices/en/*.aux
	@echo "File temporary telah dibersihkan."

# Bersihkan semua file termasuk PDF
cleanall:
	@echo "Menghapus semua file output..."
	$(LATEXMK) -C $(BOOK_ID).tex $(BOOK_EN).tex
	rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.bcf *.run.xml
	rm -f *.idx *.ilg *.ind *.lol *.nav *.snm *.vrb
	rm -f chapters/id/*.aux chapters/en/*.aux
	rm -f frontmatter/id/*.aux frontmatter/en/*.aux
	rm -f appendices/id/*.aux appendices/en/*.aux
	rm -rf output/
	@echo "Semua file output telah dihapus."

# Buka PDF dengan viewer
view: view-id

view-id: $(BOOK_ID).pdf
	@echo "Membuka PDF Indonesia dengan $(VIEWER)..."
	@if command -v $(VIEWER) > /dev/null; then \
		$(VIEWER) $(BOOK_ID).pdf & \
	else \
		echo "Error: $(VIEWER) tidak ditemukan!"; \
		echo "Install dengan: sudo apt install zathura"; \
		exit 1; \
	fi

view-en: $(BOOK_EN).pdf
	@echo "Opening English PDF with $(VIEWER)..."
	@if command -v $(VIEWER) > /dev/null; then \
		$(VIEWER) $(BOOK_EN).pdf & \
	else \
		echo "Error: $(VIEWER) not found!"; \
		echo "Install with: sudo apt install zathura"; \
		exit 1; \
	fi

# Cek error di log files
checkerrors:
	@echo "Memeriksa error di log files..."
	@for logfile in $(BOOK_ID).log $(BOOK_EN).log; do \
		if [ -f $$logfile ]; then \
			echo "=== $$logfile ==="; \
			grep -i "error\|warning" $$logfile || echo "Tidak ada error atau warning."; \
		fi; \
	done

# Validasi referensi
checkref:
	@echo "Memeriksa referensi yang tidak terdefinisi..."
	@for logfile in $(BOOK_ID).log $(BOOK_EN).log; do \
		if [ -f $$logfile ]; then \
			echo "=== $$logfile ==="; \
			grep "undefined" $$logfile || echo "Semua referensi terdefinisi."; \
		fi; \
	done

# Word count
wordcount:
	@echo "Menghitung jumlah kata..."
	@if command -v texcount > /dev/null; then \
		echo "=== Indonesian Version ==="; \
		texcount -inc -total $(BOOK_ID).tex; \
		echo ""; \
		echo "=== English Version ==="; \
		texcount -inc -total $(BOOK_EN).tex; \
	else \
		echo "texcount tidak ditemukan. Install: sudo apt install texlive-extra-utils"; \
	fi

# ========================================================================
# PDF Protection (print/copy/edit restrictions via Ghostscript)
# ========================================================================
# NOTE: this is a deterrent, not real DRM. PDF permission flags are honored
# voluntarily by compliant readers and can be stripped by many common PDF
# tools. It raises the bar against casual copy/paste/print in mainstream
# readers; it cannot stop screenshots or a determined bypass.
SECURE_PASSWORD_FILE = .secure-password

secure: secure-id secure-en

secure-id: $(BOOK_ID).pdf
	@if [ ! -f $(SECURE_PASSWORD_FILE) ]; then \
		echo "Error: $(SECURE_PASSWORD_FILE) tidak ditemukan."; \
		echo "Buat berkas ini berisi kata sandi owner sebelum menjalankan target ini:"; \
		echo "  echo 'kata-sandi-anda' > $(SECURE_PASSWORD_FILE)"; \
		echo "Berkas ini masuk .gitignore dan tidak pernah di-commit."; \
		exit 1; \
	fi
	@echo "Membuat versi terproteksi (cetak/salin/edit dinonaktifkan)..."
	gs -sOutputFile=$(BOOK_ID).secure.pdf -sDEVICE=pdfwrite \
	   -sOwnerPassword="$$(cat $(SECURE_PASSWORD_FILE))" -sUserPassword="" \
	   -dEncryptionR=3 -dKeyLength=128 -dPermissions=-2080 \
	   -dNOPAUSE -dBATCH -dQUIET $(BOOK_ID).pdf
	@echo "Selesai: $(BOOK_ID).secure.pdf (terbuka bebas, cetak/salin/edit dibatasi)"

secure-en: $(BOOK_EN).pdf
	@if [ ! -f $(SECURE_PASSWORD_FILE) ]; then \
		echo "Error: $(SECURE_PASSWORD_FILE) not found."; \
		echo "Create this file containing an owner password before running this target:"; \
		echo "  echo 'your-password' > $(SECURE_PASSWORD_FILE)"; \
		echo "This file is gitignored and never committed."; \
		exit 1; \
	fi
	@echo "Creating protected version (print/copy/edit disabled)..."
	gs -sOutputFile=$(BOOK_EN).secure.pdf -sDEVICE=pdfwrite \
	   -sOwnerPassword="$$(cat $(SECURE_PASSWORD_FILE))" -sUserPassword="" \
	   -dEncryptionR=3 -dKeyLength=128 -dPermissions=-2080 \
	   -dNOPAUSE -dBATCH -dQUIET $(BOOK_EN).pdf
	@echo "Done: $(BOOK_EN).secure.pdf (opens freely, print/copy/edit restricted)"

# Check dependencies
check-deps:
	@echo "========================================="
	@echo "Memeriksa dependensi..."
	@echo "========================================="
	@command -v pdflatex >/dev/null 2>&1 || { echo "pdflatex tidak ditemukan"; exit 1; }
	@echo "pdflatex ditemukan"
	@command -v biber >/dev/null 2>&1 || { echo "biber tidak ditemukan"; exit 1; }
	@echo "biber ditemukan"
	@command -v latexmk >/dev/null 2>&1 || { echo "latexmk tidak ditemukan"; exit 1; }
	@echo "latexmk ditemukan"
	@command -v $(VIEWER) >/dev/null 2>&1 || { echo "$(VIEWER) tidak ditemukan (opsional)"; }
	@command -v $(VIEWER) >/dev/null 2>&1 && echo "$(VIEWER) ditemukan"
	@echo "========================================="
	@echo "Semua dependensi wajib tersedia!"
	@echo "========================================="

# Help
help:
	@echo "========================================="
	@echo "Makefile untuk Kompilasi Buku LaTeX (Bilingual)"
	@echo "========================================="
	@echo ""
	@echo "Target yang tersedia:"
	@echo "  make (atau make all)  - Kompilasi versi Indonesia (default)"
	@echo "  make id               - Kompilasi versi Indonesia"
	@echo "  make en               - Kompilasi versi English"
	@echo "  make both             - Kompilasi kedua versi"
	@echo "  make quick-id         - Kompilasi cepat Indonesia"
	@echo "  make quick-en         - Kompilasi cepat English"
	@echo "  make watch-id         - Watch mode Indonesia"
	@echo "  make watch-en         - Watch mode English"
	@echo ""
	@echo "  make clean            - Hapus file temporary"
	@echo "  make cleanall         - Hapus semua file termasuk PDF"
	@echo "  make view-id          - Buka PDF Indonesia"
	@echo "  make view-en          - Buka PDF English"
	@echo "  make checkerrors      - Cek error di log files"
	@echo "  make checkref         - Cek referensi undefined"
	@echo "  make wordcount        - Hitung jumlah kata kedua versi"
	@echo "  make check-deps       - Periksa dependensi"
	@echo "  make chapters         - Build semua chapter (ID & EN) secara terpisah"
	@echo "  make chapter LANG=<id|en> CHAPTER=<name> - Build satu chapter"
	@echo "  make secure           - Buat versi PDF terproteksi (ID & EN)"
	@echo "  make help             - Tampilkan bantuan ini"
	@echo ""
	@echo "Output files:"
	@echo "  $(BOOK_ID).pdf        - Versi Indonesia"
	@echo "  $(BOOK_EN).pdf        - Versi English"
	@echo ""
