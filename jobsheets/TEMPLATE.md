# Jobsheet Praktikum: Pertemuan N
## <Judul Topik Pertemuan>

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | N (Minggu N) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK X: <salin deskripsi dari `book/docs/rps-reference.md`> |
| **Kode Awal** | branch `chapter-(NN-1)` di `github.com/se-polinema/simple-pos` (hasil akhir pertemuan sebelumnya) |
| **Kode Akhir** | branch `chapter-NN` di `github.com/se-polinema/simple-pos` |

<!--
Catatan penulisan (hapus komentar ini di jobsheet final):
- Bahasa Indonesia, sapaan "kamu", nada sama seperti materi kelas.
- Jangan menyebut "buku" atau "Bab N". Pakai framing "Pertemuan N" saja.
- Pertemuan 1 tidak punya baris "Kode Awal" (proyek dibuat dari nol).
- Repo `se-polinema/simple-pos` punya satu branch kumulatif per chapter
  (`chapter-01`..`chapter-09` saat ini, masing-masing dibangun di atas
  chapter sebelumnya, tanpa pasangan start/end terpisah). Nomor Pertemuan
  dan nomor chapter sama persis hanya sampai Pertemuan 7; setelah itu
  urutannya menyimpang (lihat tabel pemetaan Minggu->Bab di
  `book/docs/book-plan.md`) -- jangan asumsikan pertemuan-NN = chapter-NN
  begitu saja untuk Pertemuan 8 ke atas, dan chapter di atas 09 belum ada.
- Setiap langkah: narasi singkat "mengapa" sebelum perintah, lalu blok kode,
  lalu Checkpoint, lalu (bila relevan) blok "Jika gagal".
- Tampilkan ISI PENUH berkas yang diedit, bukan potongan: mahasiswa harus
  bisa menyalin langsung tanpa menebak bagian yang hilang.
-->

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet ini, kamu mampu:

1. <capaian 1: kata kerja aktif, terukur>
2. <capaian 2>
3. <capaian 3>

## B. Persiapan dan Prasyarat

- **Alat**: <daftar versi minimum yang dibutuhkan>
- **Kelanjutan kode**: lanjutkan proyek `simple-pos` milikmu dari pertemuan sebelumnya. Kalau tertinggal atau proyekmu bermasalah, mulai dari kode awal pertemuan ini:
  ```bash
  git clone -b chapter-(NN-1) https://github.com/se-polinema/simple-pos.git
  cd simple-pos
  ```
- **Verifikasi cepat** sebelum mulai:
  ```bash
  <perintah verifikasi>
  ```

## C. Langkah Kerja

### Langkah 1: <judul aksi>

<narasi singkat 1-3 kalimat: apa yang dilakukan langkah ini dan mengapa>

```bash
<perintah>
```

> ✅ **Checkpoint:** <output persis/kondisi yang menandakan langkah ini berhasil>

> ⚠️ **Jika gagal:** <gejala umum → penyebab → cara memperbaiki>

### Langkah 2: <judul aksi>

...

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta asisten/dosen:

- <deliverable 1, mis. screenshot>
- <deliverable 2, mis. output `git log --oneline`>
- **Tugas mandiri:** <1-2 latihan singkat yang dikerjakan di luar sesi kelas>

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---:|---|---|
| Langkah kerja tuntas | 40% | Seluruh langkah dijalankan dan berfungsi | Sebagian besar langkah selesai, hasil akhir berjalan |
| Checkpoint terverifikasi | 30% | Semua checkpoint tercapai dan dibuktikan (screenshot/output) | Sebagian checkpoint terbukti |
| Tugas mandiri | 20% | Jawaban lengkap dan tepat | Jawaban ada meski belum lengkap |
| Kerapian commit | 10% | Pesan commit mengikuti konvensi `increment N`, tidak menyertakan `vendor/`/`node_modules/`/`.env` | Commit ada meski pesan kurang rapi |
