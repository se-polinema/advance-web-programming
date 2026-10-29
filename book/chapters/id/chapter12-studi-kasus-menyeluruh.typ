#import "/template.typ": *

= Studi Kasus Menyeluruh: Membangun Simple POS dari Nol <ch:studi-kasus-menyeluruh>

#chapterhero("orange", [Rangkai kembali seluruh Simple POS dari skema sampai API, telusuri sepuluh increment yang membangunnya, lalu pakai sebagai peta awal proyekmu sendiri.], [#icon("store")#h(1em)Simple POS utuh], [#icon("cash-register")#h(1em)sepuluh increment], [#icon("flag-checkered")#h(1em)referensi PBL])

Bab 1 membuka buku ini dengan sebuah restoran keluarga yang berkembang
menjadi food court, dan usaha kecil itu menghadapi masalah nyata: satu
juru masak yang mengingat semua pesanan di kepala tidak lagi cukup
begitu jumlah pelanggan bertambah. Sebelas bab kemudian, Simple POS
sudah selesai dibangun, bukan lagi rancangan di atas kertas, tapi
aplikasi yang benar-benar menyimpan produk, mencatat transaksi, membatasi
akses lewat peran, dan melayani klien mobile lewat API. Hari pembukaan
perdana sebuah restoran adalah momen yang mirip: dapur sudah lengkap,
resep sudah diuji satu per satu, tapi baru pada hari itu semuanya
berjalan bersamaan, di depan pelanggan sungguhan. Bab ini adalah hari
pembukaan itu untuk Simple POS: bukan bab yang mengajarkan hal baru,
melainkan bab yang menyalakan seluruh dapur sekaligus dan melihatnya
bekerja sebagai satu kesatuan.

#strong[Yang Akan Kamu Pelajari]

+ merangkai seluruh komponen Simple POS (skema, model, controller/route, view, validasi, autentikasi, laporan, API) menjadi satu alur aplikasi yang koheren;
+ menelusuri sepuluh increment commit Simple POS dan memetakan tiap increment ke bab yang sesuai di buku ini;
+ mengevaluasi Simple POS sebagai referensi arsitektur untuk proyek PBL pada domain bisnis lain, serta mengidentifikasi bagian mana yang perlu diadaptasi.

== Merangkai Simple POS dari Nol <sec:studi-kasus-menyeluruh-1>

Ikuti satu transaksi kasir dari awal sampai akhir, dan setiap lapisan
yang dilewatinya adalah satu bab yang sudah dipelajari. Kasir membuka
`/pos`, sebuah halaman yang dilindungi middleware `auth`
dan dirender lewat layout Blade dengan keranjang belanja interaktif
lewat Alpine.js (Bab~3). Produk yang tampil di grid diambil lewat query
Eloquent yang sudah dilengkapi eager loading kategori (Bab~5), dibaca
dari tabel yang skemanya dirancang dan diisi seed data sejak Bab~4.

Begitu kasir menekan tombol bayar, request masuk ke
`TransactionController@store`, ditolak lebih dulu oleh
`StoreTransactionRequest` kalau ada item yang tidak valid
(Bab~6), lalu total dihitung ulang dari harga produk di basis data,
bukan dari angka yang dikirim klien (Bab~6). Baris `transactions`
dan `transaction_details` tersimpan, stok produk berkurang, dan
seluruh proses ini hanya bisa terjadi kalau kasir yang login memang
punya sesi yang sah (Bab~7). Beberapa hari kemudian, admin membuka
`/reports`, halaman yang ditutup untuk kasir lewat middleware
`role:admin` (Bab~7), memfilter transaksi per rentang tanggal
(Bab~8), dan mengekspornya ke CSV untuk rapat mingguan. Di sisi lain,
aplikasi kasir mobile memanggil `POST /api/login` untuk mendapat
token Sanctum, lalu `GET /api/products` dan `POST
/api/transactions` dengan header `Authorization: Bearer` pada
setiap request (Bab~9). Sebelum semua ini pernah dianggap selesai, 13
test fitur (Bab~10) memverifikasi bahwa alur di atas benar-benar
berjalan seperti yang dijelaskan, dan sebelum aplikasi ini pernah
disebut siap dipakai, index foreign key diperiksa ulang dan
`APP_DEBUG` dipastikan mati di produksi (Bab~11).

#notebox[
Tidak satu pun lapisan di atas berdiri sendiri. Middleware peran di
Bab~7 tidak berarti apa-apa tanpa sistem autentikasi yang mendahuluinya;
laporan di Bab~8 tidak berarti apa-apa tanpa kolom `total` yang
dijamin akurat sejak Bab~6. Simple POS koheren bukan karena setiap
bagiannya canggih sendiri-sendiri, tapi karena setiap bagian dibangun
di atas jaminan yang sudah dipenuhi bagian sebelumnya.
]

== Menelusuri Sepuluh Increment <sec:studi-kasus-menyeluruh-2>

Simple POS pada cakupan buku ini dibangun lewat sepuluh increment, dan
setiap increment punya padanan langsung ke satu bab yang sudah dibaca.

#figure(
  table(
    columns: (0.5fr, 0.6fr, 1.9fr),
    align: (center, left, left),
    table.hline(stroke: 0.8pt),
    [Increment], [Bab terkait], [Yang dibangun],
    table.hline(stroke: 0.5pt),
    [1], [Bab 1], [Setup proyek Laravel, Git, SQLite],
    [2], [Bab 2], [Route dan controller],
    [3], [Bab 3], [Layout Blade dan Tailwind],
    [4--5], [Bab 4--5], [Skema, migrasi, relasi Eloquent],
    [6], [Bab 6], [Validasi form],
    [7], [Bab 7], [Autentikasi dan RBAC],
    [9], [Bab 8], [Laporan, ekspor/impor],
    [10], [Bab 9], [REST API dan Sanctum],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Pemetaan sepuluh increment Simple POS ke bab buku ini],
) <tab:increment-mapping>

Angka increment tidak sepenuhnya berurutan rapi dengan nomor bab, dan
itu bukan kekeliruan penomoran. Increment 4 dan 5 sama-sama masuk ke
Bab~4 dan Bab~5 karena skema dan relasi memang dua sisi dari satu
pekerjaan yang sama, cukup besar untuk dipecah jadi dua bab tapi tetap
dikerjakan sebagai rangkaian commit yang berdekatan. Increment 8 tidak
punya baris sendiri di tabel ini karena ia bukan penambahan fitur baru,
melainkan titik pemeriksaan menyeluruh atas increment 1 sampai 7 yang
sudah berjalan, sebelum berlanjut ke increment 9. Sejarah kode yang
sebenarnya jarang serapi urutan bab dalam buku; buku menyusun ulang
urutan itu supaya lebih mudah diajarkan, sementara commit historis
mengikuti urutan pekerjaan yang benar-benar terjadi.

== Praktik: Simple POS sebagai Referensi Arsitektur <sec:studi-kasus-menyeluruh-3>

Sebelum menilai Simple POS sebagai referensi, jalankan dulu wujud
lengkapnya dari nol, persis seperti pengembang lain akan melakukannya
saat pertama kali membuka proyek ini.

+ Clone repositori, lalu pindah ke branch `chapter-12`
      (kondisi akhir Simple POS seperti yang dibahas sepanjang buku ini):

  #listing(```bash
  git clone https://github.com/dhanifudin/simple-pos.git
  cd simple-pos
  git checkout chapter-12
    
  ```)
+ Pasang dependensi PHP dan siapkan berkas environment:

  #listing(```bash
  composer install
  cp .env.example .env
  php artisan key:generate
    
  ```)
+ Pasang dependensi JavaScript, lalu bangun aset frontend produksi
      (tanpa langkah ini, direktif `@vite` di layout akan melempar
      `ViteManifestNotFoundException` begitu `/pos` dibuka
      beberapa langkah lagi):

  #listing(```bash
  npm install
  npm run build
    
  ```)
+ Jalankan migrasi sekaligus seeder:

  #listing(```bash
  php artisan migrate:fresh --seed
    
  ```)

  #strong[Yang diharapkan]: daftar migrasi tercetak satu per satu
      tanpa galat, diikuti pesan bahwa seeder selesai berjalan.
+ Jalankan seluruh test untuk memastikan checkout ini benar-benar
      berfungsi (bukan cuma ter-clone):

  #listing(```bash
  php artisan test
    
  ```)

  #strong[Yang diharapkan]: seluruh test lolos, sesuai anatomi yang
      dibahas di Bab~10.
+ Jalankan server, lalu login dan catat satu transaksi
      sungguhan lewat browser:

  #listing(```bash
  php artisan serve
    
  ```)

  Buka `http://127.0.0.1:8000`, login sebagai
      `admin@pos.test`, buka `/pos`, tambahkan satu produk ke
      keranjang, lalu simpan transaksinya. #strong[Yang diharapkan]:
      transaksi tersimpan dan langsung terlihat di `/transactions`,
      dengan stok produk yang berkurang sesuai qty yang dibeli, persis
      alur end-to-end yang dibahas di bagian sebelumnya.
+ #strong[Kalau `migrate:fresh` gagal dengan pesan
      `database file does not exist`], buat dulu berkas basis data
      SQLite-nya secara manual sebelum migrasi: `touch
      database/database.sqlite`, lalu ulangi langkah 4.

Dengan Simple POS yang sudah berjalan penuh ini sebagai bukti, bagian
berikut menilai pola strukturalnya sebagai referensi untuk proyek lain.

Simple POS dirancang khusus untuk kasus penjualan eceran, tapi pola
strukturalnya, bukan detail bisnisnya, adalah bagian yang paling
berguna dipakai ulang. Proyek PBL pada domain lain, katakanlah sistem
reservasi ruang rapat atau peminjaman buku perpustakaan, tidak akan
punya tabel `products` atau `transactions`, tapi kerangka
yang sama, skema lalu model lalu controller/route lalu view lalu
validasi lalu autentikasi lalu laporan lalu API, tetap relevan sebagai
titik awal.

#figure(
  table(
    columns: (1.3fr, 1.7fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [Bagian], [Perlu diadaptasi atau dipertahankan],
    table.hline(stroke: 0.5pt),
    [Entitas inti (`products`, `transactions`)], [Diganti total sesuai domain (mis. `rooms`, `bookings`)],
    [Skema dan relasi (Bab~4--5)], [Dirancang ulang, tapi pola `hasMany`/`belongsTo` dan index FK tetap dipertahankan],
    [Pola validasi server-side (Bab~6)], [Dipertahankan penuh: total/nilai kritis tetap wajib dihitung ulang di server],
    [Autentikasi dan RBAC (Bab~7)], [Dipertahankan, peran disesuaikan (mis. `staf`/`anggota` alih-alih `admin`/`kasir`)],
    [Struktur laporan dan API (Bab~8--9)], [Dipertahankan sebagai pola, isi dan endpoint disesuaikan domain],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Checklist adaptasi Simple POS ke domain bisnis lain],
) <tab:checklist-adaptasi>

#tipbox[
Pakai urutan skema → model → controller/route → view →
validasi → autentikasi → laporan → API sebagai kerangka awal
proyek baru, persis urutan bab-bab buku ini. Urutan ini bukan kebetulan:
setiap lapisan butuh jaminan dari lapisan sebelumnya, dan membangunnya
di luar urutan itu biasanya berarti menulis ulang sesuatu yang
seharusnya sudah benar sejak awal.
]

#branchref("chapter-12")

== Rangkuman <sec:studi-kasus-menyeluruh-rangkuman>

- Satu transaksi kasir pada Simple POS melewati seluruh lapisan
      yang dipelajari di sebelas bab sebelumnya, dari skema dan model
      sampai validasi, autentikasi, laporan, dan API, dan setiap lapisan
      bergantung pada jaminan yang sudah dipenuhi lapisan sebelumnya.
- Sepuluh increment Simple POS memetakan langsung ke Bab~1 sampai
      Bab~9, dengan increment 4--5 menyatu ke dua bab dan increment 8
      berperan sebagai titik pemeriksaan, bukan penambahan fitur baru.
- Pola struktural Simple POS, bukan detail bisnis penjualan
      eceran-nya, adalah yang layak dipakai ulang sebagai referensi
      arsitektur untuk proyek pada domain bisnis lain.

== Latihan

+ Gambar ulang diagram alur end-to-end satu transaksi kasir
      dengan kata-katamu sendiri, sebutkan bab mana yang bertanggung
      jawab atas setiap tahapnya.
+ Pilih satu domain bisnis lain (reservasi, perpustakaan,
      inventaris gudang, atau domain pilihanmu sendiri), lalu identifikasi
      tiga bagian Simple POS yang perlu diadaptasi paling dulu untuk
      domain itu.
+ Jelaskan dengan kata-katamu sendiri mengapa urutan skema
      → model → controller → view → validasi →
      autentikasi → laporan → API lebih masuk akal dikerjakan
      berurutan daripada diacak.

== Referensi

Bab ini merangkum kembali seluruh referensi yang sudah dikutip di
Bab~1 sampai Bab~11, tanpa rujukan baru.
