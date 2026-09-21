# Jobsheet Praktikum: Pertemuan N
## <Judul Topik Pertemuan>

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | N (Minggu N) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK X: <salin deskripsi dari `book/docs/rps-reference.md`> |
| **Mode Pengerjaan** | <Individu, atau Kelompok (sesuai pembagian dosen), satu repositori GitHub bersama per kelompok> |
| **Kode Awal** | template repository `github.com/se-polinema/simple-pos-ch(N-1)` |

<!--
Catatan penulisan (hapus komentar ini di jobsheet final):
- Bahasa Indonesia, sapaan "kamu", nada sama seperti materi kelas.
- Jangan menyebut "buku" atau "Bab N". Pakai framing "Pertemuan N" saja.
- Pertemuan 1 tidak punya baris "Kode Awal" (proyek dibuat dari nol).
- Kode awal setiap pertemuan adalah template repository tersendiri di
  `github.com/se-polinema/simple-pos-chNN` (repo asli dengan
  `is_template: true`, bukan branch dari monorepo lama). Tidak ada baris
  "Kode Akhir". Nomor Pertemuan dan nomor chapter sama persis hanya sampai
  Pertemuan 7; setelah itu urutannya menyimpang (lihat tabel pemetaan
  Minggu->Bab di `book/docs/book-plan.md`) -- jangan asumsikan
  pertemuan-NN = chNN begitu saja untuk Pertemuan 8 ke atas. Repo hanya
  ada sampai `simple-pos-ch12` per saat ini; cek dulu dengan
  `gh api repos/se-polinema/simple-pos-chNN` sebelum merujuknya.
- Kalau sebuah Checkpoint bergantung pada kondisi nyata kode awal (pesan
  error tertentu, commit teratas tertentu, berkas yang ada/tidak ada),
  verifikasi dulu lewat `gh api` terhadap repo aslinya. Jangan menebak
  dari isi buku atau dari jobsheet pertemuan sebelumnya.
- Mulai Pertemuan 3 (setiap pertemuan setelah yang kedua), jobsheet
  dikerjakan berkelompok; Pertemuan 1-2 tetap individu. Untuk jobsheet
  kelompok: satu anggota membuat repo dari template lalu menambahkan
  anggota lain plus dosen sebagai collaborator; alur kerja git memakai
  feature branch + Pull Request (bukan commit langsung ke main), di-merge
  dengan "Create a merge commit" (bukan "Squash and merge", supaya commit
  tiap anggota tetap tercatat atas namanya untuk penilaian kontribusi
  individu); nama branch pakai kata bahasa Inggris; jangan menugaskan
  langkah tertentu ke anggota bernomor tertentu, biarkan kelompok sendiri
  yang membagi; jangan menyebut "Asisten", hanya "dosen".
- Kalau sebuah langkah membuat berkas baru yang punya generator asli di
  Laravel, pakai `php artisan make:*` (mis. `make:view <dot.notation>`
  untuk view biasa, `make:component <nama> --view` untuk anonymous
  component) alih-alih "buat berkas baru" manual. Cek dulu sintaks/opsinya
  ke dokumentasi resmi Laravel, jangan menebak.
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
- **Kode awal** (individu): lanjutkan proyek `simple-pos` milikmu dari pertemuan sebelumnya. Kalau tertinggal atau proyekmu bermasalah, buat repositori baru dari template pertemuan ini:
  1. Buka `https://github.com/se-polinema/simple-pos-ch(N-1)`.
  2. Klik **Use this template** → **Create a new repository**.
  3. Beri nama repositori, lalu klik **Create repository**.

  <!-- Untuk jobsheet kelompok, ganti bullet di atas dengan langkah "salah satu anggota membuat repo dari template + menambahkan collaborator", lihat pertemuan-03-blade-dan-tailwind.md sebagai contoh. -->
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

Kumpulkan hal berikut sesuai format yang diminta dosen:

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
<!--
Untuk jobsheet KELOMPOK, ganti baris "Langkah kerja tuntas" dan "Kerapian commit" di atas
menjadi berlabel "(kelompok)", dan tambahkan satu baris komponen individu, mis.:
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna atas nama tiap anggota, terverifikasi lewat `git log --pretty="%h %an %s"` | Commit ada tapi kecil atau kurang jelas kaitannya |
Sesuaikan total bobot supaya tetap 100%, dan hapus komentar ini di jobsheet final.
-->

