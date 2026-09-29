# ========================================================================
# Makefile untuk Kompilasi Buku LaTeX - Bilingual Support
# "Laravel Praktis" / "Practical Laravel" - Menggunakan latexmk untuk
# automasi kompilasi
# ========================================================================

# File utama untuk setiap bahasa
BOOK_ID = book-id
BOOK_EN = book-en

# Semua output build (buku utuh, bab lepas, lampiran lepas) masuk ke sini
BUILD_DIR = build

# PDF Viewer
VIEWER = zathura

# latexmk configuration
LATEXMK = latexmk
LATEXMK_FLAGS = -pdf -bibtex -interaction=nonstopmode -file-line-error -outdir=$(BUILD_DIR)

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

# Appendix filenames differ per language (translated slugs), so each list is
# derived from what actually exists in appendices/<lang>/ rather than hardcoded.
APPENDICES_ID = $(notdir $(basename $(wildcard appendices/id/*.tex)))
APPENDICES_EN = $(notdir $(basename $(wildcard appendices/en/*.tex)))

# ========================================================================
# Target Utama
# ========================================================================

.PHONY: all id en both dist \
        clean cleanall view view-id view-en watch watch-id watch-en \
        quick quick-id quick-en checkerrors checkref wordcount help check-deps \
        chapters chapters-id chapters-en chapter \
        appendices appendices-id appendices-en appendix \
        secure secure-id secure-en

# Default target - build Indonesian version (backward compatibility)
all: id

# Build Indonesian version
id: $(BUILD_DIR)/$(BOOK_ID).pdf

# Build English version
en: $(BUILD_DIR)/$(BOOK_EN).pdf

# Build both versions
both: id en

# Build everything: full books, every chapter, every appendix, both languages
dist: both chapters appendices

SOURCES_ID = $(BOOK_ID).tex preamble.tex references.bib \
             $(wildcard chapters/id/*.tex) $(wildcard frontmatter/id/*.tex) \
             $(wildcard appendices/id/*.tex)
SOURCES_EN = $(BOOK_EN).tex preamble.tex references.bib \
             $(wildcard chapters/en/*.tex) $(wildcard frontmatter/en/*.tex) \
             $(wildcard appendices/en/*.tex)

# Kompilasi Indonesian PDF
# A cold build's latexmk invocation can report a nonzero exit from a
# biber/makeindex rerun race even though it fully converged and wrote a
# complete PDF within that same invocation. A second latexmk call does NOT
# fix this: latexmk remembers "a previous invocation failed" and re-reports
# a nonzero exit even when it does zero work and confirms the file is
# up-to-date. So instead of retrying, treat "the PDF exists and was
# (re)written during this invocation" (newer than the pre-run marker) as
# the real success signal, and only fail the build when that is false.
$(BUILD_DIR)/$(BOOK_ID).pdf: $(SOURCES_ID)
	@mkdir -p $(BUILD_DIR)
	@echo "========================================="
	@echo "Kompilasi versi Indonesia dengan latexmk"
	@echo "========================================="
	@touch $(BUILD_DIR)/.book-id-marker
	@$(LATEXMK) $(LATEXMK_FLAGS) $(BOOK_ID).tex || \
		{ [ -f $(BUILD_DIR)/$(BOOK_ID).pdf ] && [ $(BUILD_DIR)/$(BOOK_ID).pdf -nt $(BUILD_DIR)/.book-id-marker ] && \
		  echo "latexmk exited nonzero but wrote a complete PDF this run (known transient biber/makeindex race); continuing."; }
	@rm -f $(BUILD_DIR)/.book-id-marker
	@test -f $(BUILD_DIR)/$(BOOK_ID).pdf
	@echo "========================================="
	@echo "Kompilasi selesai! File: $(BUILD_DIR)/$(BOOK_ID).pdf"
	@echo "========================================="

# Kompilasi English PDF
$(BUILD_DIR)/$(BOOK_EN).pdf: $(SOURCES_EN)
	@mkdir -p $(BUILD_DIR)
	@echo "========================================="
	@echo "Compiling English version with latexmk"
	@echo "========================================="
	@touch $(BUILD_DIR)/.book-en-marker
	@$(LATEXMK) $(LATEXMK_FLAGS) $(BOOK_EN).tex || \
		{ [ -f $(BUILD_DIR)/$(BOOK_EN).pdf ] && [ $(BUILD_DIR)/$(BOOK_EN).pdf -nt $(BUILD_DIR)/.book-en-marker ] && \
		  echo "latexmk exited nonzero but wrote a complete PDF this run (known transient biber/makeindex race); continuing."; }
	@rm -f $(BUILD_DIR)/.book-en-marker
	@test -f $(BUILD_DIR)/$(BOOK_EN).pdf
	@echo "========================================="
	@echo "Compilation complete! File: $(BUILD_DIR)/$(BOOK_EN).pdf"
	@echo "========================================="

# Build all chapters individually for both languages
chapters: chapters-id chapters-en

# Build all Indonesian chapters individually
chapters-id:
	@echo "Building all Indonesian chapters..."
	@for chapter in $(CHAPTERS); do \
		echo "Building ID chapter: $$chapter"; \
		./scripts/build-standalone.sh id chapter $$chapter || exit 1; \
	done
	@echo "All Indonesian chapters built in $(BUILD_DIR)/chapters/id/"

# Build all English chapters individually
chapters-en:
	@echo "Building all English chapters..."
	@for chapter in $(CHAPTERS); do \
		echo "Building EN chapter: $$chapter"; \
		./scripts/build-standalone.sh en chapter $$chapter || exit 1; \
	done
	@echo "All English chapters built in $(BUILD_DIR)/chapters/en/"

# Build a single chapter: make chapter LANG=en CHAPTER=chapter01-arsitektur-web-modern
chapter:
	@if [ -z "$(LANG)" ] || [ -z "$(CHAPTER)" ]; then \
		echo "Usage: make chapter LANG=<id|en> CHAPTER=<chapter-name>"; \
		exit 1; \
	fi
	./scripts/build-standalone.sh $(LANG) chapter $(CHAPTER)

# Build all appendices individually for both languages
appendices: appendices-id appendices-en

# Build all Indonesian appendices individually
appendices-id:
	@echo "Building all Indonesian appendices..."
	@for appendix in $(APPENDICES_ID); do \
		echo "Building ID appendix: $$appendix"; \
		./scripts/build-standalone.sh id appendix $$appendix || exit 1; \
	done
	@echo "All Indonesian appendices built in $(BUILD_DIR)/appendices/id/"

# Build all English appendices individually
appendices-en:
	@echo "Building all English appendices..."
	@for appendix in $(APPENDICES_EN); do \
		echo "Building EN appendix: $$appendix"; \
		./scripts/build-standalone.sh en appendix $$appendix || exit 1; \
	done
	@echo "All English appendices built in $(BUILD_DIR)/appendices/en/"

# Build a single appendix: make appendix LANG=id APPENDIX=instalasi
appendix:
	@if [ -z "$(LANG)" ] || [ -z "$(APPENDIX)" ]; then \
		echo "Usage: make appendix LANG=<id|en> APPENDIX=<appendix-name>"; \
		exit 1; \
	fi
	./scripts/build-standalone.sh $(LANG) appendix $(APPENDIX)

# Kompilasi cepat (single pass)
quick: quick-id

quick-id:
	@mkdir -p $(BUILD_DIR)
	@echo "Kompilasi cepat versi Indonesia..."
	$(LATEXMK) -pdf -interaction=nonstopmode -outdir=$(BUILD_DIR) $(BOOK_ID).tex

quick-en:
	@mkdir -p $(BUILD_DIR)
	@echo "Quick compile English version..."
	$(LATEXMK) -pdf -interaction=nonstopmode -outdir=$(BUILD_DIR) $(BOOK_EN).tex

# Watch mode - kompilasi otomatis saat file berubah
watch: watch-id

watch-id:
	@mkdir -p $(BUILD_DIR)
	@echo "========================================="
	@echo "Mode Watch Indonesia - Kompilasi otomatis aktif"
	@echo "Tekan Ctrl+C untuk berhenti"
	@echo "========================================="
	$(LATEXMK) -pdf -bibtex -pvc -interaction=nonstopmode -outdir=$(BUILD_DIR) $(BOOK_ID).tex

watch-en:
	@mkdir -p $(BUILD_DIR)
	@echo "========================================="
	@echo "Watch Mode English - Auto-compilation active"
	@echo "Press Ctrl+C to stop"
	@echo "========================================="
	$(LATEXMK) -pdf -bibtex -pvc -interaction=nonstopmode -outdir=$(BUILD_DIR) $(BOOK_EN).tex

# Bersihkan file temporary (aux/log/dll di build/, PDF tetap disimpan)
clean:
	@echo "Membersihkan file temporary..."
	$(LATEXMK) -c -outdir=$(BUILD_DIR) $(BOOK_ID).tex $(BOOK_EN).tex
	@echo "File temporary telah dibersihkan."

# Bersihkan semua file termasuk PDF dan seluruh direktori build/
cleanall:
	@echo "Menghapus semua file output..."
	$(LATEXMK) -C -outdir=$(BUILD_DIR) $(BOOK_ID).tex $(BOOK_EN).tex
	rm -rf $(BUILD_DIR)/
	rm -rf output/
	@echo "Semua file output telah dihapus."

# Buka PDF dengan viewer
view: view-id

view-id: $(BUILD_DIR)/$(BOOK_ID).pdf
	@echo "Membuka PDF Indonesia dengan $(VIEWER)..."
	@if command -v $(VIEWER) > /dev/null; then \
		$(VIEWER) $(BUILD_DIR)/$(BOOK_ID).pdf & \
	else \
		echo "Error: $(VIEWER) tidak ditemukan!"; \
		echo "Install dengan: sudo apt install zathura"; \
		exit 1; \
	fi

view-en: $(BUILD_DIR)/$(BOOK_EN).pdf
	@echo "Opening English PDF with $(VIEWER)..."
	@if command -v $(VIEWER) > /dev/null; then \
		$(VIEWER) $(BUILD_DIR)/$(BOOK_EN).pdf & \
	else \
		echo "Error: $(VIEWER) not found!"; \
		echo "Install with: sudo apt install zathura"; \
		exit 1; \
	fi

# Cek error di log files
checkerrors:
	@echo "Memeriksa error di log files..."
	@for logfile in $(BUILD_DIR)/$(BOOK_ID).log $(BUILD_DIR)/$(BOOK_EN).log; do \
		if [ -f $$logfile ]; then \
			echo "=== $$logfile ==="; \
			grep -i "error\|warning" $$logfile || echo "Tidak ada error atau warning."; \
		fi; \
	done

# Validasi referensi
checkref:
	@echo "Memeriksa referensi yang tidak terdefinisi..."
	@for logfile in $(BUILD_DIR)/$(BOOK_ID).log $(BUILD_DIR)/$(BOOK_EN).log; do \
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

secure-id: $(BUILD_DIR)/$(BOOK_ID).pdf
	@if [ ! -f $(SECURE_PASSWORD_FILE) ]; then \
		echo "Error: $(SECURE_PASSWORD_FILE) tidak ditemukan."; \
		echo "Buat berkas ini berisi kata sandi owner sebelum menjalankan target ini:"; \
		echo "  echo 'kata-sandi-anda' > $(SECURE_PASSWORD_FILE)"; \
		echo "Berkas ini masuk .gitignore dan tidak pernah di-commit."; \
		exit 1; \
	fi
	@echo "Membuat versi terproteksi (cetak/salin/edit dinonaktifkan)..."
	gs -sOutputFile=$(BUILD_DIR)/$(BOOK_ID).secure.pdf -sDEVICE=pdfwrite \
	   -sOwnerPassword="$$(cat $(SECURE_PASSWORD_FILE))" -sUserPassword="" \
	   -dEncryptionR=3 -dKeyLength=128 -dPermissions=-2080 \
	   -dNOPAUSE -dBATCH -dQUIET $(BUILD_DIR)/$(BOOK_ID).pdf
	@echo "Selesai: $(BUILD_DIR)/$(BOOK_ID).secure.pdf (terbuka bebas, cetak/salin/edit dibatasi)"

secure-en: $(BUILD_DIR)/$(BOOK_EN).pdf
	@if [ ! -f $(SECURE_PASSWORD_FILE) ]; then \
		echo "Error: $(SECURE_PASSWORD_FILE) not found."; \
		echo "Create this file containing an owner password before running this target:"; \
		echo "  echo 'your-password' > $(SECURE_PASSWORD_FILE)"; \
		echo "This file is gitignored and never committed."; \
		exit 1; \
	fi
	@echo "Creating protected version (print/copy/edit disabled)..."
	gs -sOutputFile=$(BUILD_DIR)/$(BOOK_EN).secure.pdf -sDEVICE=pdfwrite \
	   -sOwnerPassword="$$(cat $(SECURE_PASSWORD_FILE))" -sUserPassword="" \
	   -dEncryptionR=3 -dKeyLength=128 -dPermissions=-2080 \
	   -dNOPAUSE -dBATCH -dQUIET $(BUILD_DIR)/$(BOOK_EN).pdf
	@echo "Done: $(BUILD_DIR)/$(BOOK_EN).secure.pdf (opens freely, print/copy/edit restricted)"

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
	@echo "  make dist             - Kompilasi buku utuh + semua bab + semua lampiran (ID & EN)"
	@echo "  make quick-id         - Kompilasi cepat Indonesia"
	@echo "  make quick-en         - Kompilasi cepat English"
	@echo "  make watch-id         - Watch mode Indonesia"
	@echo "  make watch-en         - Watch mode English"
	@echo ""
	@echo "  make clean            - Hapus file temporary di build/ (PDF tetap ada)"
	@echo "  make cleanall         - Hapus seluruh direktori build/ termasuk PDF"
	@echo "  make view-id          - Buka PDF Indonesia"
	@echo "  make view-en          - Buka PDF English"
	@echo "  make checkerrors      - Cek error di log files"
	@echo "  make checkref         - Cek referensi undefined"
	@echo "  make wordcount        - Hitung jumlah kata kedua versi"
	@echo "  make check-deps       - Periksa dependensi"
	@echo "  make chapters         - Build semua bab (ID & EN) sebagai PDF terpisah"
	@echo "  make chapter LANG=<id|en> CHAPTER=<name> - Build satu bab"
	@echo "  make appendices       - Build semua lampiran (ID & EN) sebagai PDF terpisah"
	@echo "  make appendix LANG=<id|en> APPENDIX=<name> - Build satu lampiran"
	@echo "  make secure           - Buat versi PDF terproteksi (ID & EN)"
	@echo "  make help             - Tampilkan bantuan ini"
	@echo ""
	@echo "Output files (semua di bawah $(BUILD_DIR)/):"
	@echo "  $(BUILD_DIR)/$(BOOK_ID).pdf              - Buku utuh, versi Indonesia"
	@echo "  $(BUILD_DIR)/$(BOOK_EN).pdf              - Buku utuh, versi English"
	@echo "  $(BUILD_DIR)/chapters/<lang>/*.pdf     - Bab lepas per bahasa"
	@echo "  $(BUILD_DIR)/appendices/<lang>/*.pdf   - Lampiran lepas per bahasa"
	@echo ""
