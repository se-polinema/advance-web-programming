# Panduan Penulisan: Buku Pemrograman Web dengan Laravel

Dokumen ini adalah panduan gaya dan struktur untuk menulis buku ini. Diadaptasi
dari `mobile/docs/authoring-guide.md` (buku Flutter/Supabase pada workspace
`dhanifudin`), yang sendiri diturunkan dari konvensi `os-book`/SQA/OOAD di
workspace tersebut. Aturan yang bersifat umum (tata bahasa, anti pola AI,
struktur bab) dipertahankan apa adanya; bagian yang spesifik topik (makro
LaTeX, domain analogi, strategi hosting kode) disesuaikan untuk pemrograman
web dengan Laravel.

Lihat juga: `book-plan.md` (rencana induk, satu-satunya berkas yang boleh
memuat kosakata kurikulum internal), `outline.md` (peta bab final),
`chapter-plan-template.md` (templat rencana per bab), `rps-reference.md`
(salinan sumber kurikulum, untuk ketertelusuran internal saja).

## Model Produksi Dwibahasa

Buku ini mengikuti arsitektur dwibahasa `mobile/`:
- `book-id.tex` (edisi Indonesia) dan `book-en.tex` (edisi Inggris), berbagi
  satu `preamble.tex` dengan flag `\ifIndonesian` / `\ifEnglish`.
- Struktur direktori paralel: `chapters/id/` dan `chapters/en/`,
  `frontmatter/id/` dan `frontmatter/en/`, `appendices/id/` dan
  `appendices/en/`.
- Penamaan berkas bab: `chapters/{lang}/chapterNN-topik.tex`.

## Studi Kasus Berjalan: Simple POS

**Simple POS** adalah aplikasi kasir/point-of-sale sederhana untuk UMKM, kode
sumbernya sudah ada dan nyata di `../../simple-pos/` (bukan proyek fiktif
yang dibuat khusus untuk buku ini). Rasional lengkap kenapa nama dan kode
apa adanya dipertahankan (bukan diganti nama komersial) ada di
`book-plan.md`.

**Model data inti** (empat tabel, dipakai konsisten mulai Bab 4, dengan relasi
Eloquent diimplementasikan penuh di Bab 5):
- `categories`: `id`, `name`.
- `products`: `id`, `category_id` (fk), `name`, `price`, `stock`.
- `transactions`: `id`, `user_id` (fk), `total`, `created_at`.
- `transaction_details`: `id`, `transaction_id` (fk), `product_id` (fk),
  `qty`, `subtotal`.

**Perjalanan Simple POS sepanjang buku:**
- Bab 1-3: setup proyek, routing/controller dasar, layout Blade + Tailwind +
  Alpine.js untuk halaman kasir.
- Bab 4-6: skema dan seeding skala nyata, relasi Eloquent dan paginasi,
  validasi input dan keamanan.
- Bab 7-9: autentikasi dan RBAC, pengolahan data (laporan, ekspor/impor),
  REST API dengan Sanctum.
- Bab 10-12: pengujian, optimasi dan deployment, sintesis menyeluruh.

## Elemen Pedagogis (seragam tiap bab)

- **Wajib: paragraf pembuka dengan analogi atau kisah kontekstual**,
  ditempatkan tepat setelah `\chapterhero` dan sebelum blok "Yang Akan Kamu
  Pelajari", yang menjawab "mengapa bab ini penting bagi pembaca" sebelum
  masuk ke tujuan pembelajaran maupun definisi teknis. Paragraf ini wajib
  menegaskan taruhannya (stakes): konsekuensi konkret bila pembaca tidak
  menguasai topik ini, berpijak pada studi kasus Simple POS. Paragraf ini
  harus memakai domain analogi yang sudah ditetapkan untuk bab tersebut di
  tabel "Pelacakan Domain Analogi" di bawah, bukan memperkenalkan domain baru
  yang hanya dipakai sekali.
- Blok wajib **"Yang Akan Kamu Pelajari"** (ID) / **"What You'll Learn"** (EN).
- **`istilahpenting`** (kotak ketujuh, mengikuti preseden `mobile/`/SQA):
  daftar istilah kunci bab tersebut, ditempatkan di dalam `\section` pertama
  bab, tepat setelah judul seksi dan sebelum prosa konsep dimulai (bukan
  sebelum `\section` pertama). Dipakai karena kosakata Laravel (route,
  middleware, Eloquent, migrasi) cukup padat bagi pembaca pemula.
- Isi subbab, dengan praktik langsung pada proyek Simple POS.
- Kotak tantangan (`challengebox`) per bagian praktik.
- Bagian wajib penutup **Rangkuman** / **Summary**.
- Latihan dan Referensi.

## Kotak Berwarna (didefinisikan di `preamble.tex`)

```latex
\begin{notebox}         % biru   - catatan dan pengingat
\begin{tipbox}          % hijau  - tips dan praktik terbaik
\begin{warningbox}      % merah  - operasi berisiko (mis. menghapus data produksi,
                         %          mempercayai total dari input klien)
\begin{examplebox}[Judul]   % oranye - contoh dan demonstrasi
\begin{exercisebox}[N]      % ungu   - latihan akhir bab
\begin{challengebox}        % teal   - tantangan per bagian
\begin{istilahpenting}      % hijau muda - daftar istilah kunci bab
```

`warningbox` dipakai secara sengaja untuk operasi berisiko dunia nyata (mis.
men-deploy dengan `APP_DEBUG=true`, menerima total transaksi langsung dari
input klien, lupa memasang middleware peran pada route baru).

## `\chapterhero`: Signature dan Penggunaan

```latex
\chapterhero{<warna>}{<misi satu kalimat>}{\faIcon{<ikon1>}\quad <topik1>}{\faIcon{<ikon2>}\quad <topik2>}{\faIcon{<ikon3>}\quad <topik3>}
```

Lima argumen: warna kotak (`blue`/`teal`/`purple`/`orange`, satu warna per
bagian buku, lihat `outline.md`), misi bab dalam satu kalimat, dan tiga
`\faIcon{}` beserta label topik singkat yang dirender sebagai `\chaptertag{}`.
Dipakai tepat setelah `\chapter{}`/`\label{}`, sebelum paragraf pembuka
beranalogi. Pada scaffold saat ini, argumen misi masih literal
`TODO: satu kalimat misi bab (lihat docs/chapterNN.md).`; ini wajib diganti
prosa nyata saat bab ditulis.

## Blok Wajib Bab (urutan tetap)

1. `\chapter{}` + `\label{ch:<slug>}`
2. `\chapterhero{}`
3. Paragraf pembuka beranalogi (hook, wajib, lihat "Elemen Pedagogis")
4. Blok "Yang Akan Kamu Pelajari" / "What You'll Learn" + `\begin{enumerate}` tujuan pembelajaran
5. 3-5 `\section{}` topik, dengan `istilahpenting` di dalam section pertama
6. `\section{Rangkuman}` / `\section{Summary}`, wajib memetakan 1:1 ke setiap
   tujuan pembelajaran pada langkah 4, dengan jumlah dan urutan yang sama
   persis

## Makro Kustom (didefinisikan di `preamble.tex`)

Diadaptasi dari makro domain-spesifik pada `mobile/`, disesuaikan untuk
pemrograman web dengan Laravel:

```latex
\cmd{php artisan serve}         % Format perintah CLI umum (composer/php)
\phpclass{ProductController}    % Format nama class/model/controller PHP
\pkg{laravel/sanctum}           % Format nama paket Composer/npm
\file{routes/web.php}           % Format nama berkas konfigurasi/proyek
\artisan{php artisan migrate}   % Format perintah Artisan CLI (alias \cmd)
\route{/api/products}           % Format path/nama route Laravel
\branchref{chapter-08}          % Rujukan baku ke branch GitHub kode lengkap bab
```

`\branchref{}` merender rujukan "kode lengkap: `dhanifudin/simple-pos`,
branch `chapter-NN`" sebagai tautan langsung ke branch itu di GitHub,
dipakai di akhir setiap Praktik. Lihat "Strategi Hosting Kode" di bawah
untuk konvensi lengkapnya.

**Token kode panjang dan margin halaman:** `\cmd{}`, `\phpclass{}`,
`\file{}`, `\route{}` membungkus `\texttt{}` polos, yang tidak pernah
memenggal diri sendiri di akhir baris. Trim halaman buku ini cukup sempit
(~11.5cm lebar teks), jadi token seperti
`\phpclass{DB::table()->insert()}` atau
`\route{/api/transactions/\{id\}}` bisa meluber ke margin kalau kebetulan
jatuh di ujung baris. `\emergencystretch` dan `hyphenat` di `preamble.tex`
sudah menutup sebagian besar kasus secara otomatis; untuk token tunggal
yang lebih dari ~25 karakter dan tetap meluber (cek `Overfull \hbox` di
`book-id.log`/`book-en.log` setelah kompilasi), sisipkan `\allowbreak`
manual setelah `::`, `->`, atau `/` di dalam argumennya, mis.
`\phpclass{DB::table()\allowbreak->insert()}`.

## Strategi Hosting Kode

Mengikuti pola `mobile/` (pendekatan minim-kode-inline):

- **Kode singkat** (kira-kira 1-15 baris) yang mengilustrasikan satu konsep
  spesifik (satu definisi relasi Eloquent, satu aturan validasi, satu
  middleware) tetap tampil sebagai `lstlisting` langsung di dalam prosa.
- **Kode penuh** (seluruh berkas, seluruh controller, proyek Praktik
  multi-berkas) **tidak** didump penuh ke dalam bab. Setiap Praktik
  menampilkan potongan paling esensial saja (maksimal sekitar 15-20 baris),
  lalu ditutup dengan `\branchref{chapter-NN}` yang merujuk ke proyek lengkap
  di GitHub.
- **Repositori:** `dhanifudin/simple-pos` (repo publik di GitHub; `\repobase`
  di `preamble.tex` sudah diset ke nilai ini, string dipakai identik di
  seluruh bab, dan `\branchref{}` merender tautan langsung ke
  `github.com/dhanifudin/simple-pos/tree/chapter-NN`).
- **Branch per bab, kumulatif:** `chapter-01` hingga `chapter-12`, sudah
  dibuat dan dipublikasikan sebagai checkpoint yang bisa di-clone dan
  langsung dijalankan (`composer install && php artisan migrate:fresh --seed`)
  untuk tiap bab.
- **Setiap Praktik wajib diakhiri dengan `\branchref{}`**, bahkan jika
  potongan kode yang ditampilkan di bab sudah terasa lengkap.

### Praktik Wajib Berformat Langkah Bernomor

Setiap bagian Praktik (dan bagian hands-on lain yang setara, mis. sesi
profiling di Bab 11) ditulis sebagai `\begin{enumerate}` langkah konkret,
bukan prosa-di-sekitar-cuplikan-kode. Minimum per Praktik:

1. **Path berkas eksplisit** untuk tiap berkas yang dibuat/dibuka (mis. "buka
   `app/Http/Requests/StoreProductRequest.php`"), bukan sekadar menyebut nama
   kelasnya.
2. **Perintah `php artisan make:*`** (atau setara) yang membuat kerangka
   berkas itu, jika ada.
3. **Lokasi kode**: berkas/metode mana yang diedit dan bagaimana potongan
   `lstlisting` yang sudah ada di bab itu dipasang di sana.
4. **Perintah untuk dijalankan plus keluaran yang diharapkan** (bukan cuma
   "jalankan test", tapi seperti apa persisnya keluaran lolos/gagal).
5. **Minimal satu catatan troubleshooting** ("kalau ini gagal, periksa...")
   untuk mode kegagalan yang masuk akal terjadi di langkah itu.

Ini tidak mengubah aturan kode-singkat di atas: cuplikan tetap maksimal
15-20 baris, hanya dibungkus dalam urutan langkah yang benar-benar bisa
diikuti pembaca di proyeknya sendiri, bukan diperluas jadi dump kode penuh.

## Aturan Gaya Penulisan (berlaku untuk semua prosa, ID dan EN)

### Tanpa Tanda Pisah Panjang (Em-Dash)

**Jangan pernah gunakan tanda `---` di mana pun dalam prosa bab.** Gunakan
titik dua, koma, kalimat terpisah, atau tanda kurung sebagai gantinya.

### Identifier Kode Selalu Bahasa Inggris

**Setiap identifier yang terlihat oleh compiler PHP (nama variabel, method,
class, key array/JSON yang merepresentasikan kolom database, nama
tabel/kolom, nama route, nama berkas) wajib ditulis dalam Bahasa Inggris, di
kedua edisi, tanpa kecuali.** Ini berlaku sekalipun seluruh prosa di
sekitarnya berbahasa Indonesia, mengikuti konvensi Laravel/PHP dunia nyata.
Hanya string VALUE yang boleh berbahasa Indonesia (mis. label UI seperti
`'Simpan Transaksi'`, atau nilai yang disimpan pengguna), karena itu teks
yang dilihat pemakai aplikasi, bukan identifier kode. Contoh yang salah:
`hargaTotal`, `hitungTotalTransaksi()`, `'nama_produk'` sebagai key. Contoh
yang benar: `totalPrice`, `calculateTransactionTotal()`, `'product_name'`.
Sebelum bab dianggap selesai, periksa ulang setiap `\phpclass{}`, `\cmd{}`,
`\artisan{}`, `\route{}`, `\pkg{}`, `\file{}`, dan blok `lstlisting` untuk
memastikan tidak ada kata Indonesia yang menyelinap menjadi identifier kode.

### Audiens: Bahasa Formal untuk Pemula

Tulis untuk pembaca yang belum tentu pernah membangun aplikasi web berbasis
data maupun mengelola basis data relasional. Setiap istilah teknis (mis.
"middleware", "eager loading", "idempoten") harus diperkenalkan dengan
definisi ringkas sebelum dipakai bebas. Nada formal dan instruksional;
hindari kata pengisi kolokial.

**Struktur per konsep:**
1. Nyatakan konsep dalam satu kalimat sederhana.
2. Berikan analogi konkret dari pengalaman sehari-hari.
3. Tunjukkan kode atau mekanismenya (potongan singkat; kode penuh ke
   `\branchref{}`).
4. Nyatakan hasil yang diharapkan atau yang perlu diamati pembaca.

### Prosa Alami: Hindari Pola yang Terdeteksi sebagai Tulisan AI

- Variasikan panjang kalimat (4-8 kata diselingi 15-25 kata); jangan seragam.
- Variasikan panjang paragraf.
- Gunakan angka dan nama konkret: bukan "banyak transaksi", tapi "2.500
  transaksi tersebar dalam 120 hari terakhir".
- Hindari frasa transisi berulang ("Selain itu,", "Lebih lanjut,", "Pertama,")
  sebagai pembuka paragraf mekanis.
- Hindari rangkuman berulang di akhir paragraf konsep; langsung lanjut ke
  praktik.
- Utamakan kalimat aktif.
- Batasi "Bayangkan" maksimal sekali per bab, jangan sebagai kalimat pembuka
  bab.
- Variasikan label observasi: jangan selalu "Amati:"; gunakan juga
  "Perhatikan...", "Apa yang terjadi jika...", atau jalin observasi langsung
  ke teks langkah.
- Sisipkan 1-2 catatan penulis (authorial aside) per bab pada momen yang
  genuinely membingungkan bagi pemula.
- **Jangan pakai domain analogi yang sama pada bab yang bersebelahan.** Lacak
  penggunaan analogi di bawah ini dan hindari pengulangan pada bab tetangga
  (Bab 12 dikecualikan: ia sengaja menggaungkan analogi Bab 1 sebagai
  penutup, lihat tabel di bawah).

### Pelacakan Domain Analogi (isi seiring penulisan)

| Bab | Domain Analogi |
|---|---|
| Bab 1 | Restoran keluarga tunggal yang menangani semua sendiri vs food court dengan tenant terpisah (monolith vs microservices) |
| Bab 2 | Kantor pos: alamat, amplop, dan loket yang meneruskan surat ke bagian yang tepat (siklus HTTP, pembagian tugas MVC) |
| Bab 3 | Etalase toko yang statis vs pramuniaga yang sigap merespons pelanggan (Blade+Tailwind vs interaktivitas Alpine.js) |
| Bab 4 | Gudang dengan rak berlabel dan katalog kartu vs gudang tanpa katalog (skema, migrasi, index) |
| Bab 5 | Silsilah keluarga/pohon keluarga (relasi Eloquent, eager loading membawa seluruh cabang sekaligus) |
| Bab 6 | Satpam pemeriksa di pintu masuk dan kasir yang menghitung ulang struk, bukan percaya nota tamu (validasi, total di server) |
| Bab 7 | Kunci dan kartu akses gedung berlapis: lobi vs ruang server (autentikasi vs otorisasi/RBAC) |
| Bab 8 | Pabrik pengepakan dengan jalur konveyor vs pos suplai satu-satu (batch processing, antrean) |
| Bab 9 | Loket layanan publik dengan formulir baku sebagai kontrak antar-kantor (desain REST API) |
| Bab 10 | Petugas quality control pabrik yang mencoba produk sebelum dikirim (pengujian otomatis) |
| Bab 11 | Pindahan kantor ke gedung baru dan kurir yang tahu jalan pintas vs muter-muter (deployment, profiling query) |
| Bab 12 | Hari pembukaan perdana sebuah restoran (menggaungkan analogi restoran Bab 1 sebagai penutup) |

Perbarui tabel ini setiap kali sebuah bab ditulis, agar penulis bab berikutnya
dapat menghindari pengulangan domain.

## Aturan Aman ISBN (Perpusnas)

Buku diposisikan sebagai buku referensi/teks komersial, bukan materi ajar
internal. **Kosakata kurikulum internal (RPS, RPP, CPMK, CPL, Sub-CPMK,
"Minggu ke-", kode mata kuliah, SKS, semester, nama prodi/institusi di
judul/isi, dan sejenisnya) hanya boleh muncul di `book-plan.md`** (lihat
catatan konvensi di berkas tersebut); tidak pernah di berkas `.tex` mana pun,
tidak juga di `outline.md`, `chapter-plan-template.md`, atau
`docs/chapterNN.md`. Tabel lengkap istilah yang dihindari dan penggantinya
ada di `outline.md`, bagian "Catatan Aman ISBN (Perpusnas)".

## Referensi Silang dan Sitasi

```latex
\cref{fig:label}              % Referensi silang otomatis
\cite{citation-key}           % Sitasi bibliografi
\url{https://example.com}     % Format URL
```

## Status

Perancah LaTeX sudah dibangun (lihat `book-plan.md`). Setiap bab berstatus
scaffold: `\chapterhero`, tujuan pembelajaran, dan judul section sudah final;
prosa isi (`% TODO: prosa`) menunggu ditulis mengikuti rencana pada
`docs/chapterNN.md`.
