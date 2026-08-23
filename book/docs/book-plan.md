# Rencana Buku: Pemrograman Web dengan Laravel

Rencana induk penulisan buku komersial tentang pengembangan aplikasi web dengan
Laravel, dibangun mengikuti studi kasus Simple POS. Struktur dan konvensi
diadopsi dari `mobile/` (buku Flutter/Supabase pada workspace `dhanifudin`) dan
pola ISBN-aman yang sudah dirintis di sana. Dokumen ini adalah gambaran
menyeluruh; detail gaya penulisan ada di `authoring-guide.md`, peta bab final
di `outline.md`, dan templat rencana per bab di `chapter-plan-template.md`.

> **Catatan konvensi:** dokumen ini adalah satu-satunya berkas dalam `book/`
> yang boleh memuat kosakata RPS/CPMK/Sub-CPMK/SKS/kode mata kuliah/minggu
> ke-. Berkas `.tex` mana pun, `outline.md`, `chapter-plan-template.md`, dan
> `docs/chapterNN.md` tidak pernah menyebut istilah tersebut (lihat "Aturan
> Aman ISBN" di bawah dan di `authoring-guide.md`).

## Status Saat Ini

**Perancah LaTeX sudah dibangun** (dokumen ini ditulis bersamaan dengan
perancah, bukan mendahuluinya, berbeda dari `mobile/` yang menulis rencana
lebih dulu). RPS sumber: `docs/rps-reference.md` (salinan verbatim dari
`../../docs/RPS-PWL-aligned.md`, mata kuliah "Pemrograman Web Lanjut", kode
`RTI254007`, 3 SKS/6 jam, semester 4, Prodi D4 Sistem Informasi Bisnis).
Struktur cakupan 12 bab dalam 4 bagian **final**; seluruh bab masih berstatus
scaffold (kerangka `\chapterhero`, tujuan pembelajaran, dan judul section
sudah final, prosa isi belum ditulis).

## Positioning dan Judul

**Judul komersial:**
*Laravel Praktis: Membangun Aplikasi Kasir dari Nol*
(EN: *Practical Laravel: Building a Point-of-Sale App from Scratch*)

Buku ini diposisikan sebagai buku referensi/teks komersial untuk dua
kelompok pembaca:
1. **Mahasiswa D4 Sistem Informasi Bisnis semester 4** yang mengikuti mata
   kuliah berbasis Laravel dengan proyek studi kasus kasir (POS), yang ingin
   rujukan yang lebih dalam dan lebih terstruktur daripada slide kuliah.
2. **Pembelajar mandiri (self-learner)** yang sudah punya literasi dasar
   pemrograman (variabel, fungsi, struktur kontrol) tetapi belum pernah
   membangun aplikasi web berbasis data dari nol, dan ingin satu studi kasus
   utuh yang bergerak dari routing dasar hingga REST API siap produksi,
   bukan kumpulan potongan kode lepas.

Buku ini tidak mengasumsikan pengalaman framework backend sebelumnya, tetapi
mengasumsikan literasi dasar pemrograman dan HTML/CSS.

## Delta Laravel 13 vs RPS (Laravel 12)

RPS resmi (`docs/rps-reference.md`, minggu 1) menyebut "Setup Laravel 12"
sebagai materi minggu pertama. Repositori studi kasus `simple-pos/` yang
menjadi tulang punggung buku ini sudah berjalan di atas **Laravel 13** (lihat
`simple-pos/README.md`: "Aplikasi ... berbasis Laravel 13"). Buku ini
mengikuti versi aktual aplikasi (Laravel 13), bukan versi yang disebut RPS,
dengan pertimbangan:

- Buku komersial punya siklus hidup lebih panjang daripada satu semester RPS;
  menulis terhadap versi framework yang benar-benar berjalan pada kode sumber
  lebih tahan lama daripada menulis terhadap versi yang disebut dokumen
  internal yang bisa saja belum diperbarui.
- Seluruh konsep yang diajarkan (routing, MVC, Eloquent, middleware,
  validasi, Sanctum) stabil lintas Laravel 12 dan 13; delta versi ini tidak
  mengubah satu pun tujuan pembelajaran pada `outline.md`.
- Nomor versi ("13") sengaja **tidak** dicantumkan pada judul maupun subjudul
  buku (lihat "Aturan Aman ISBN" di bawah dan preseden `mobile/`, yang juga
  tidak mencantumkan versi Flutter/Dart pada judul), agar buku tidak terasa
  kedaluwarsa begitu Laravel merilis versi mayor berikutnya. Angka versi
  disebutkan sewajarnya di prosa Bab 1/Prakata sebagai konteks, bukan sebagai
  klaim judul.

## Studi Kasus: Simple POS

**Simple POS** adalah aplikasi kasir/point-of-sale sederhana untuk UMKM,
sudah ada sebagai kode sumber nyata di `simple-pos/` (bukan dirancang khusus
untuk buku ini). Buku ini memakai Simple POS apa adanya, bukan membangun
studi kasus fiktif baru, dengan alasan:

- **Kode sudah ada dan teruji.** Simple POS punya 13 test fitur (27
  assertion) yang lulus, seeder skala nyata (300 produk, 2.500 transaksi,
  6.250 baris detail), dan riwayat commit `increment N` yang memetakan
  pertumbuhan aplikasi secara historis nyata, bukan rekonstruksi naratif.
- **Bug performa nyata sebagai bahan ajar.** Kasus index foreign key yang
  hilang di SQLite (`constrained()` tidak otomatis membuat index) adalah bug
  performa yang benar-benar ditemukan dan diperbaiki pada kode sumber,
  bukan skenario rekaan untuk keperluan pedagogis. Ini memberi Bab 4 dan
  Bab 11 bahan ajar yang lebih meyakinkan daripada contoh sintetis.
- **Nama tetap "Simple POS", bukan diganti nama komersial.** Nama alternatif
  seperti "KasirKita" sempat dipertimbangkan agar terdengar lebih seperti
  produk komersial (sejalan dengan "PasarKita" pada `mobile/`), tetapi
  ditolak: mengganti nama aplikasi berarti seluruh route, nama tabel, email
  akun demo (`admin@pos.test`, `kasir@pos.test`), dan nama proyek pada kode
  sumber harus ikut diubah atau buku akan menyimpang dari kode yang benar-benar
  bisa dijalankan pembaca. Karena `\branchref{}` merujuk langsung ke
  repositori `simple-pos` yang sudah ada, konsistensi nama dengan kode sumber
  dinilai lebih penting daripada nama yang terdengar lebih komersial.

## Model Produksi Dwibahasa

Mengadopsi arsitektur `mobile/` secara penuh:
- `book-id.tex` (edisi Indonesia) dan `book-en.tex` (edisi Inggris), berbagi
  satu `preamble.tex` dengan flag `\ifIndonesian` / `\ifEnglish`.
- `chapters/{id,en}/chapterNN-topik.tex`, `frontmatter/{id,en}/`,
  `appendices/{id,en}/`.
- `Makefile` dengan target penuh `id`/`en`/`both`, `quick-*`, `watch-*`,
  `chapter` (build satu bab standalone via `scripts/build-chapter.sh`),
  `checkerrors`, `checkref`, `wordcount`, `view-*`, `check-deps`.

## Rasional Empat Bagian

- **Bagian I - Fondasi Laravel dan Arsitektur Web (Bab 1-3):** pembaca perlu
  memahami di mana Laravel berdiri di antara pilihan arsitektur lain, lalu
  segera bisa melihat sesuatu di layar (routing, controller, halaman kasir)
  sebelum masuk ke lapisan data yang lebih abstrak.
- **Bagian II - Data dan Eloquent (Bab 4-6):** begitu antarmuka dasar
  berdiri, bagian ini membangun fondasi data yang menopang seluruh fitur
  sesudahnya: skema, relasi, dan validasi. Diurutkan sebelum autentikasi
  karena autentikasi Bab 7 memakai tabel `users` yang polanya sudah
  dikenalkan di Bab 4.
- **Bagian III - Keamanan, Laporan, dan API (Bab 7-9):** setelah data dan
  validasi mapan, bagian ini menambahkan lapisan yang mengubah Simple POS
  dari sekadar aplikasi CRUD menjadi aplikasi yang aman dan bisa diakses
  klien lain (laporan untuk pemilik usaha, API untuk kasir mobile).
- **Bagian IV - Menuju Aplikasi Siap Produksi (Bab 10-12):** menutup buku
  dengan pertanyaan yang jarang dijawab tuntas buku pemrograman pemula:
  bagaimana memastikan aplikasi ini benar (pengujian), cukup cepat dan siap
  dirilis (optimasi/deployment), dan bagaimana seluruh perjalanan ini
  dilihat sebagai satu kesatuan (studi kasus menyeluruh).

## Rencana Bibliografi Rujukan

Lihat `../references.bib` untuk daftar lengkap (8 entri): dokumentasi resmi
Laravel dan PHP, disertasi REST Roy Fielding, dokumentasi Tailwind CSS, OWASP
Top 10, *Patterns of Enterprise Application Architecture* (Fowler),
dokumentasi Laravel Sanctum, dan spesifikasi OpenAPI.

## Peta Bab

Lihat `outline.md` untuk struktur lengkap 12 bab dan materi per bab.

## Pemetaan Minggu RPS ke Bab (internal, untuk ketertelusuran saja)

Tabel ini **satu-satunya tempat** kosakata RPS/Sub-CPMK/minggu boleh muncul
di seluruh direktori `book/`. Sumber: `docs/rps-reference.md`. Urutan bab
buku ini mengikuti urutan minggu RPS secara langsung (berbeda dari `mobile/`
yang memindahkan backend lebih awal), karena RPS `RTI254007` sudah menaruh
fondasi (arsitektur, HTTP/MVC, data) sebelum keamanan dan API secara alami,
tanpa kebutuhan pivot struktural.

| Minggu RPS | Sub-CPMK | Topik RPS | Bab Buku |
|---|---|---|---|
| 1 | Sub-CPMK 1 | Pengenalan mata kuliah, arsitektur web modern, setup Laravel, Git | Bab 1 |
| 2 | Sub-CPMK 1 | HTTP protocol, MVC architecture, routing, controller | Bab 2 |
| 3 | Sub-CPMK 2 | Frontend landscape, templating, Blade, Tailwind, Alpine.js | Bab 3 |
| 4 | Sub-CPMK 1 | Database design, migration, indexing strategy, seeding | Bab 4 |
| 5 | Sub-CPMK 2 | ORM, Eloquent, relasi, eager loading | Bab 5 |
| 6 | Sub-CPMK 2 | Validasi, sanitasi, Form Request, error handling UX | Bab 6 |
| 7 | Sub-CPMK 3 | Authentication, authorization, RBAC | Bab 7 |
| 8 | Sub-CPMK 1-3 | UTS - evaluasi progress proyek PBL | Bab 10 (checklist milestone) |
| 9 | Sub-CPMK 4 | Data processing, import/export, queue-based processing | Bab 8 |
| 10 | Sub-CPMK 3 | API architecture, OpenAPI, Sanctum | Bab 9 |
| 11 | Sub-CPMK 4 | PBL - perencanaan fitur dan arsitektur proyek | Bab 12 |
| 12 | Sub-CPMK 4 | PBL - pengembangan fitur utama | Bab 12 |
| 13 | Sub-CPMK 4 | PBL - integrasi modul, testing fungsional | Bab 10, Bab 12 |
| 14 | Sub-CPMK 4 | PBL - optimasi performa, deployment preparation | Bab 11 |
| 15 | Sub-CPMK 4 | PBL - finalisasi, dokumentasi, presentasi | Bab 11, Bab 12 |
| 16 | Sub-CPMK 4 | UAS - evaluasi proyek web final | Bab 12 |

Catatan: minggu 8 dan 16 (UTS/UAS) pada RPS adalah evaluasi progres proyek
mahasiswa, bukan materi baru; buku ini memetakannya ke Bab 10 (pengujian
sebagai gerbang kualitas) dan Bab 12 (sintesis menyeluruh) karena keduanya
memainkan peran evaluatif yang setara dalam narasi buku. Minggu 11-15 (PBL)
adalah proyek kelompok mahasiswa pada domain bisnis pilihan sendiri; buku
memetakannya ke Bab 12 karena Bab 12 memposisikan Simple POS sebagai referensi
arsitektur untuk proyek semacam itu, bukan sebagai materi minggu-per-minggu
yang berdiri sendiri.

## Ruang Lingkup yang Ditunda

- Pembuatan branch GitHub sungguhan (`chapter-01` hingga `chapter-12`) pada
  repositori `simple-pos`, dibangun dari commit `increment N` yang sudah ada.
  Lihat "Strategi Hosting Kode" di `authoring-guide.md`.
- Penulisan prosa isi bab (bab saat ini berstatus scaffold: `\chapterhero`,
  tujuan pembelajaran, dan judul section sudah final; isi `% TODO: prosa`
  belum ditulis).
- Materi pengayaan di luar cakupan RPS (Livewire, Inertia.js, Laravel
  Octane), dirangkum sebagai peta jalan pada Lampiran Topik Lanjutan.
