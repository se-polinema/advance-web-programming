# Jobsheet Praktikum

Jobsheet Markdown, satu berkas per pertemuan: `pertemuan-NN-<slug>.md`. Salin `TEMPLATE.md` saat menulis pertemuan baru. Bahasa Indonesia adalah bahasa utama, disimpan langsung di root direktori ini.

Versi Inggris (opsional, dibuat sesuai kebutuhan, belum lengkap untuk semua pertemuan) disimpan di `en/pertemuan-NN-<slug>.md`, terjemahan penuh dari versi Indonesia, kecuali pesan commit git tetap Bahasa Indonesia (mengikuti konvensi commit asli proyek Simple POS, bukan bahasa jobsheet).

Render ke PDF A4: `./build.sh` (semua berkas, Indonesia dan Inggris) atau `./build.sh pertemuan-01-arsitektur-web-modern.md` / `./build.sh en/pertemuan-04-desain-basis-data.md` (satu berkas). Output masuk ke `build/` (Indonesia) atau `build/en/` (Inggris), keduanya tidak di-commit. Butuh `pandoc` + `lualatex`.
