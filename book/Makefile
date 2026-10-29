# ========================================================================
# Makefile untuk Kompilasi Buku (Typst) - Bilingual Support
# "Laravel Praktis" / "Practical Laravel" - memakai typst compile
# ========================================================================

# File utama untuk setiap bahasa
BOOK_ID = book-id
BOOK_EN = book-en

# Semua output build (buku utuh, bab lepas, lampiran lepas) masuk ke sini
BUILD_DIR = build

# PDF Viewer
VIEWER = zathura

# Typst configuration: --root . lets every .typ file import "/template.typ";
# fonts/ holds the bundled Font Awesome icons font.
TYPST = typst
TYPST_FLAGS = --root . --font-path fonts

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
APPENDICES_ID = $(notdir $(basename $(wildcard appendices/id/*.typ)))
APPENDICES_EN = $(notdir $(basename $(wildcard appendices/en/*.typ)))

# ========================================================================
# Target Utama
# ========================================================================

.PHONY: all id en both dist \
        clean cleanall view view-id view-en watch watch-id watch-en \
        wordcount help check-deps \
        chapters chapters-id chapters-en chapter \
        appendices appendices-id appendices-en appendix \
        secure secure-id secure-en

# Default target - build Indonesian version (backward compatibility)
all: id

id: $(BUILD_DIR)/$(BOOK_ID).pdf

en: $(BUILD_DIR)/$(BOOK_EN).pdf

both: id en

# Build everything: full books, every chapter, every appendix, both languages
dist: both chapters appendices

COMMON = template.typ i18n.typ icons.typ diagrams.typ references.bib \
         $(wildcard fonts/*)

SOURCES_ID = $(BOOK_ID).typ $(COMMON) \
             $(wildcard chapters/id/*.typ) $(wildcard frontmatter/id/*.typ) \
             $(wildcard appendices/id/*.typ)
SOURCES_EN = $(BOOK_EN).typ $(COMMON) \
             $(wildcard chapters/en/*.typ) $(wildcard frontmatter/en/*.typ) \
             $(wildcard appendices/en/*.typ)

# Kompilasi Indonesian PDF
$(BUILD_DIR)/$(BOOK_ID).pdf: $(SOURCES_ID)
	@mkdir -p $(BUILD_DIR)
	@echo "========================================="
	@echo "Kompilasi versi Indonesia dengan typst"
	@echo "========================================="
	$(TYPST) compile $(TYPST_FLAGS) $(BOOK_ID).typ $@
	@echo "Kompilasi selesai! File: $@"

# Kompilasi English PDF
$(BUILD_DIR)/$(BOOK_EN).pdf: $(SOURCES_EN)
	@mkdir -p $(BUILD_DIR)
	@echo "========================================="
	@echo "Compiling English version with typst"
	@echo "========================================="
	$(TYPST) compile $(TYPST_FLAGS) $(BOOK_EN).typ $@
	@echo "Compilation complete! File: $@"

# Build all chapters individually for both languages
chapters: chapters-id chapters-en

chapters-id:
	@echo "Building all Indonesian chapters..."
	@for chapter in $(CHAPTERS); do \
		$(MAKE) --no-print-directory chapter LANG=id CHAPTER=$$chapter || exit 1; \
	done
	@echo "All Indonesian chapters built in $(BUILD_DIR)/chapters/id/"

chapters-en:
	@echo "Building all English chapters..."
	@for chapter in $(CHAPTERS); do \
		$(MAKE) --no-print-directory chapter LANG=en CHAPTER=$$chapter || exit 1; \
	done
	@echo "All English chapters built in $(BUILD_DIR)/chapters/en/"

# Build a single chapter: make chapter LANG=en CHAPTER=chapter01-arsitektur-web-modern
chapter:
	@if [ -z "$(LANG)" ] || [ -z "$(CHAPTER)" ]; then \
		echo "Usage: make chapter LANG=<id|en> CHAPTER=<chapter-name>"; \
		exit 1; \
	fi
	@if [ ! -f chapters/$(LANG)/$(CHAPTER).typ ]; then \
		echo "Error: chapters/$(LANG)/$(CHAPTER).typ not found"; exit 1; \
	fi
	@mkdir -p $(BUILD_DIR)/chapters/$(LANG)
	$(TYPST) compile $(TYPST_FLAGS) \
		--input lang=$(LANG) --input kind=chapter --input name=$(CHAPTER) \
		standalone.typ $(BUILD_DIR)/chapters/$(LANG)/$(CHAPTER).pdf

# Build all appendices individually for both languages
appendices: appendices-id appendices-en

appendices-id:
	@echo "Building all Indonesian appendices..."
	@for appendix in $(APPENDICES_ID); do \
		$(MAKE) --no-print-directory appendix LANG=id APPENDIX=$$appendix || exit 1; \
	done
	@echo "All Indonesian appendices built in $(BUILD_DIR)/appendices/id/"

appendices-en:
	@echo "Building all English appendices..."
	@for appendix in $(APPENDICES_EN); do \
		$(MAKE) --no-print-directory appendix LANG=en APPENDIX=$$appendix || exit 1; \
	done
	@echo "All English appendices built in $(BUILD_DIR)/appendices/en/"

# Build a single appendix: make appendix LANG=id APPENDIX=instalasi
appendix:
	@if [ -z "$(LANG)" ] || [ -z "$(APPENDIX)" ]; then \
		echo "Usage: make appendix LANG=<id|en> APPENDIX=<appendix-name>"; \
		exit 1; \
	fi
	@if [ ! -f appendices/$(LANG)/$(APPENDIX).typ ]; then \
		echo "Error: appendices/$(LANG)/$(APPENDIX).typ not found"; exit 1; \
	fi
	@mkdir -p $(BUILD_DIR)/appendices/$(LANG)
	$(TYPST) compile $(TYPST_FLAGS) \
		--input lang=$(LANG) --input kind=appendix --input name=$(APPENDIX) \
		standalone.typ $(BUILD_DIR)/appendices/$(LANG)/$(APPENDIX).pdf

# Watch mode - kompilasi otomatis saat file berubah
watch: watch-id

watch-id:
	@mkdir -p $(BUILD_DIR)
	@echo "Mode Watch Indonesia - Kompilasi otomatis aktif (Ctrl+C untuk berhenti)"
	$(TYPST) watch $(TYPST_FLAGS) $(BOOK_ID).typ $(BUILD_DIR)/$(BOOK_ID).pdf

watch-en:
	@mkdir -p $(BUILD_DIR)
	@echo "Watch Mode English - Auto-compilation active (Ctrl+C to stop)"
	$(TYPST) watch $(TYPST_FLAGS) $(BOOK_EN).typ $(BUILD_DIR)/$(BOOK_EN).pdf

# Hapus semua output build
clean cleanall:
	@echo "Menghapus semua file output..."
	rm -rf $(BUILD_DIR)/
	@echo "Semua file output telah dihapus."

# Buka PDF dengan viewer
view: view-id

view-id: $(BUILD_DIR)/$(BOOK_ID).pdf
	@if command -v $(VIEWER) > /dev/null; then \
		$(VIEWER) $(BUILD_DIR)/$(BOOK_ID).pdf & \
	else \
		echo "Error: $(VIEWER) tidak ditemukan!"; \
		exit 1; \
	fi

view-en: $(BUILD_DIR)/$(BOOK_EN).pdf
	@if command -v $(VIEWER) > /dev/null; then \
		$(VIEWER) $(BUILD_DIR)/$(BOOK_EN).pdf & \
	else \
		echo "Error: $(VIEWER) not found!"; \
		exit 1; \
	fi

# Word count (dari teks PDF hasil build)
wordcount: both
	@echo "=== Indonesian Version ===" && pdftotext $(BUILD_DIR)/$(BOOK_ID).pdf - | wc -w
	@echo "=== English Version ===" && pdftotext $(BUILD_DIR)/$(BOOK_EN).pdf - | wc -w

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
	@echo "Memeriksa dependensi..."
	@command -v $(TYPST) >/dev/null 2>&1 || { echo "typst tidak ditemukan (https://typst.app)"; exit 1; }
	@echo "typst ditemukan: $$($(TYPST) --version)"
	@$(TYPST) fonts --font-path fonts | grep -qi "Times New Roman" || { echo "font Times New Roman tidak ditemukan"; exit 1; }
	@echo "font Times New Roman ditemukan"
	@$(TYPST) fonts --font-path fonts | grep -qi "Font Awesome 6 Free Solid" || { echo "font Font Awesome (fonts/) tidak ditemukan"; exit 1; }
	@echo "font Font Awesome ditemukan"
	@echo "Catatan: kompilasi pertama mengunduh paket Typst (cetz, in-dexter) dan butuh internet."
	@command -v $(VIEWER) >/dev/null 2>&1 || echo "$(VIEWER) tidak ditemukan (opsional)"
	@echo "Semua dependensi wajib tersedia!"

help:
	@echo "make id | en | both        build the full book (build/book-<lang>.pdf)"
	@echo "make dist                  full books + every chapter + every appendix"
	@echo "make chapter LANG=id CHAPTER=chapter01-arsitektur-web-modern"
	@echo "make appendix LANG=en APPENDIX=installation-guide"
	@echo "make chapters | appendices build all standalone chapters / appendices"
	@echo "make watch-id | watch-en   rebuild on change"
	@echo "make secure                protected PDFs (needs .secure-password)"
	@echo "make clean                 remove build/"
