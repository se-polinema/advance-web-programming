# Outline Buku Pemrograman Web dengan Laravel

> **Status: FINAL (cakupan dan urutan).** Struktur 12 bab di bawah ini
> menempatkan Simple POS, aplikasi kasir/point-of-sale yang sudah ada sebagai
> kode sumber nyata di `../../simple-pos/`, sebagai studi kasus berjalan
> sepanjang buku. Rasional pemetaan sumber materi ada di `book-plan.md`
> (satu-satunya berkas yang boleh menyebut sumber kurikulum internal); berkas
> ini murni berbicara tentang bab, materi, dan kode.

## Bab 1: Arsitektur Web Modern dan Ekosistem Laravel
- **Materi**:
  - Monolith vs microservices vs serverless, dan posisi Laravel di antaranya
  - Mengenal Laravel sebagai kerangka kerja full-stack
  - Menyiapkan proyek Laravel baru dengan SQLite sebagai basis data zero-setup
  - Struktur proyek Laravel dan menjalankan server pengembangan
  - Konvensi commit dan alur Git dasar pada repositori Simple POS

## Bab 2: Protokol HTTP dan Pola MVC
- **Materi**:
  - Siklus request/response HTTP: method, status code, header
  - Pola MVC, perbandingan singkat dengan MVVM dan Clean Architecture
  - Routing dan pembagian tanggung jawab controller
  - Praktik: route dan controller untuk halaman kasir dan transaksi

## Bab 3: Antarmuka dengan Blade, Tailwind, dan Alpine
- **Materi**:
  - Multi-page application vs single-page application
  - Layout dan komponen Blade, Tailwind CSS lewat CDN
  - Interaktivitas sisi klien dengan Alpine.js
  - Praktik: keranjang belanja dinamis pada halaman kasir

## Bab 4: Desain Basis Data, Migrasi, dan Seeding
- **Materi**:
  - Merancang skema basis data Simple POS dan relasinya
  - Migrasi dan strategi seeding skala nyata (bulk insert vs `Model::create()`)
  - Index foreign key eksplisit dan verifikasi lewat `EXPLAIN QUERY PLAN`
  - Praktik: mereproduksi dan memperbaiki bug performa index yang hilang

## Bab 5: Eloquent ORM dan Relasi
- **Materi**:
  - Relasi `hasOne`, `hasMany`, `belongsTo`, `belongsToMany` pada model Simple POS
  - Eager loading dan masalah N+1 query
  - Paginasi pada data berskala ribuan baris
  - Praktik: memverifikasi paginasi mengembalikan data yang benar-benar berbeda

## Bab 6: Validasi dan Keamanan Input
- **Materi**:
  - FormRequest dan aturan validasi
  - Mengapa total transaksi dihitung ulang di server, bukan dari input klien
  - Penanganan pesan error dan flash message
  - Praktik: validasi form produk dan transaksi

## Bab 7: Autentikasi, Otorisasi, dan RBAC
- **Materi**:
  - Autentikasi vs otorisasi, login dan sesi pengguna
  - Middleware peran kustom (`role:admin`)
  - Perbandingan dengan paket seperti Laravel Breeze dan Spatie Permission
  - Praktik: membatasi akses halaman admin dari peran kasir

## Bab 8: Pengolahan Data: Impor, Ekspor, dan Antrean
- **Materi**:
  - Laporan penjualan dengan filter rentang tanggal
  - Ekspor laporan ke CSV dan impor data produk dari CSV
  - Penanganan galat pada baris data yang tidak valid
  - Kapan memindahkan pemrosesan data ke antrean (queue)

## Bab 9: Merancang dan Membangun REST API
- **Materi**:
  - Prinsip desain endpoint REST dan semantik HTTP method
  - Autentikasi token dengan Laravel Sanctum
  - Endpoint API Simple POS: login, daftar produk, transaksi
  - Praktik: mendokumentasikan API dengan spesifikasi OpenAPI

## Bab 10: Pengujian dan Kualitas Aplikasi
- **Materi**:
  - Anatomi test fitur Simple POS (autentikasi, otorisasi, transaksi, API)
  - Menjalankan dan menafsirkan hasil test otomatis
  - Menyusun checklist milestone sebagai gerbang kualitas

## Bab 11: Optimasi, Deployment, dan Dokumentasi
- **Materi**:
  - Profiling query N+1 dan query tanpa index
  - Menyiapkan environment produksi dan caching konfigurasi/route
  - Menyusun dokumentasi teknis untuk pengembang lain

## Bab 12: Studi Kasus Menyeluruh: Membangun Simple POS dari Nol
- **Materi**:
  - Merangkai seluruh komponen Simple POS menjadi satu alur aplikasi
  - Menelusuri riwayat pertumbuhan aplikasi dari commit ke commit
  - Simple POS sebagai referensi arsitektur untuk proyek pada domain lain

---

## Pemetaan Increment Simple POS ke Bab

Sumber: `../../simple-pos/README.md`. Setiap commit pada repositori Simple
POS dilabeli `increment N`; tabel berikut memetakan increment tersebut ke bab
buku ini.

| Increment | Yang Dibangun | Bab Buku |
|---|---|---|
| 1 | Setup proyek Laravel, repo Git, SQLite | Bab 1 |
| 2 | Route & controller produk/transaksi | Bab 2 |
| 3 | Layout Blade + Tailwind CDN, halaman kasir | Bab 3 |
| 4-5 | Skema (produk, kategori, transaksi), model Eloquent, index FK | Bab 4, Bab 5 |
| 6 | FormRequest produk & transaksi | Bab 6 |
| 7 | Login, middleware `role:admin` | Bab 7 |
| 9 | Laporan penjualan (ekspor CSV), impor produk (CSV) | Bab 8 |
| 10 | Sanctum token auth, API produk/transaksi | Bab 9 |

Increment 8 tidak ada pada riwayat commit Simple POS (lompat dari 7 ke 9,
lihat `../../simple-pos/README.md`); pengujian (Bab 10), optimasi/dokumentasi
(Bab 11), dan sintesis (Bab 12) dibangun di atas seluruh increment 1-10 yang
sudah ada, bukan increment tersendiri.

---

## Catatan Aman ISBN (Perpusnas)

Diadopsi dari konvensi `mobile/docs/authoring-guide.md`. Buku diposisikan
sebagai buku referensi/teks komersial, bukan materi ajar internal. Kosakata
kurikulum internal **hanya** boleh muncul di `book-plan.md`
(lihat catatan konvensi di berkas tersebut); berkas ini dan seluruh `.tex`
tidak pernah memakainya:

| Hindari | Gunakan |
|---|---|
| RPS, RPP, Silabus, SAP, kurikulum | (dihilangkan) |
| CPMK, CPL, Sub-CPMK | "Tujuan Pembelajaran" |
| Modul, Diktat, Bahan Ajar, Handout, Petunjuk Praktikum | "Buku", "Bab" |
| "Minggu/Pekan ke-", "Pertemuan ke-" | "Bab N" |
| "Tugas 1/2/...", "Praktikum" (label) | "Latihan", "Studi Kasus" |
| "Mahasiswa mampu ..." | "Pembaca dapat ...", "Anda dapat ..." |
| Kode MK, SKS, semester | (dihilangkan) |
| Nama prodi/institusi di judul/isi | hanya di halaman penulis bila perlu |
| Laporan, UTS, UAS | (dihilangkan) |
| "Panduan", "Buku Panduan", "Panduan Praktis" (judul/subjudul) | Subjudul tematik langsung, mis. "Dari X hingga Y" |
