#import "/template.typ": *

= Optimasi, Deployment, dan Dokumentasi <ch:optimasi-dan-deployment>

#chapterhero("orange", [Profilkan ulang query N+1 dan index dengan angka nyata, siapkan Simple POS untuk deployment, lalu tinggalkan dokumentasi teknis untuk pengembang berikutnya.], [#icon("tachometer-alt")#h(1em)profil N+1 & index], [#icon("rocket")#h(1em)persiapan deployment], [#icon("file-alt")#h(1em)dokumentasi teknis])

Kurir yang memindahkan kantor dari satu gedung ke gedung lain punya dua
rute yang bisa dipilih: jalan pintas yang sudah dipetakan sebelumnya
lewat gang belakang, atau rute muter-muter lewat jalan utama yang macet
karena belum sempat dicek rute alternatifnya. Kurir yang berpengalaman
tidak menebak-nebak; ia sudah mengukur kedua rute itu dengan stopwatch
sebelum hari pindahan, dan tahu persis rute mana yang lebih cepat untuk
truk bermuatan penuh. Bab ini melakukan hal serupa pada Simple POS di
penghujung perjalanannya: mengukur ulang, dengan angka konkret, seberapa
jauh perbaikan eager loading (Bab~5) dan index foreign key (Bab~4)
benar-benar mempercepat aplikasi, lalu menyiapkan aplikasi itu untuk
"hari pindahan" yang sesungguhnya, yaitu deployment ke lingkungan
produksi, dan meninggalkan peta rute itu dalam bentuk dokumentasi bagi
siapa pun yang melanjutkan perjalanan.

#strong[Yang Akan Kamu Pelajari]

+ memprofilkan query N+1 dan query tanpa index pada Simple POS memakai `EXPLAIN QUERY PLAN`, lalu mengukur perbaikannya setelah eager loading dan index ditambahkan;
+ menyiapkan Simple POS untuk deployment (konfigurasi environment produksi, migrasi, caching konfigurasi dan route);
+ menyusun dokumentasi teknis ringkas yang menjelaskan keputusan arsitektur Simple POS bagi pengembang lain yang melanjutkan proyek.

== Memprofilkan Query N+1 dan Index <sec:optimasi-dan-deployment-1>

#istilahpenting[
/ Profiling: Proses mengukur secara langsung, dengan angka, bagian mana dari sebuah aplikasi yang memakan waktu paling banyak, alih-alih menebak berdasarkan intuisi.
/ Query Cache: Mekanisme menyimpan hasil query yang mahal agar tidak perlu dijalankan ulang pada request berikutnya yang identik.
/ Route Cache: Berkas hasil kompilasi seluruh definisi route Laravel, mempercepat pencocokan URL ke route tanpa memuat ulang seluruh berkas route setiap request.
/ Config Cache: Berkas hasil penggabungan seluruh berkas konfigurasi Laravel menjadi satu, menghindari pembacaan berulang banyak berkas kecil pada setiap request.
]

Bab~4 dan Bab~5 masing-masing menunjukkan satu bug performa: index
foreign key yang hilang pada SQLite, dan masalah N+1 pada listing
transaksi. Kali ini kedua perbaikan itu diukur bersamaan, dengan skenario
yang lebih dekat ke kondisi produksi: menampilkan halaman riwayat
transaksi lengkap dengan detail dan produknya, di atas basis data yang
sudah terisi penuh hasil seeding Bab~4.

+ Ukur dulu kondisi #emph[tanpa] eager loading:

  #listing(```bash
  php artisan tinker
  >>> DB::enableQueryLog();
  >>> Transaction::latest()->take(15)->get()->each(fn($t) => $t->details);
  >>> count(DB::getQueryLog());
    
  ```)

  `DB::enableQueryLog()` mengaktifkan pencatatan setiap query
      yang dijalankan Eloquent dalam sesi tinker itu. #strong[Yang
      diharapkan]: angka yang tercetak sekitar 16 (1 query daftar
      transaksi, ditambah 15 query detail, satu per transaksi, karena
      `$t->details` diakses lazy di dalam `each()`).
+ Keluar dari tinker (`exit`), lalu ulangi dengan
      `with('details.product')` dipasang di awal query:

  #listing(```bash
  php artisan tinker
  >>> DB::enableQueryLog();
  >>> Transaction::with('details.product')->latest()->take(15)->get();
  >>> count(DB::getQueryLog());
    
  ```)

  #strong[Yang diharapkan]: angka yang tercetak turun jadi 3, sesuai
      penjelasan Bab~5, bukan sekadar klaim teoretis.
+ Verifikasi index dengan perintah yang sama seperti Bab~4,
      dijalankan di sini pada query laporan penjualan Bab~8:

  #listing(```bash
  sqlite3 database/database.sqlite \
    "EXPLAIN QUERY PLAN SELECT * FROM transactions WHERE created_at BETWEEN ? AND ?;"
    
  ```)

  #strong[Yang diharapkan]: baris hasil memuat
      `SEARCH ... USING INDEX`, bukan `SCAN`, membuktikan
      index `transactions.created_at` yang ditambahkan di Bab~4
      benar-benar dipakai, bukan cuma ada di skema tapi tidak pernah
      tersentuh query yang sebenarnya berjalan.

== Menyiapkan Deployment <sec:optimasi-dan-deployment-2>

Lingkungan pengembangan lokal dan lingkungan produksi punya prioritas
yang berlawanan pada satu hal penting: informasi galat. Di lokal,
melihat detail lengkap sebuah exception, termasuk isi query dan baris
kode yang memicunya, mempercepat proses debugging. Di produksi,
informasi yang sama, kalau ditampilkan ke pengguna umum, membocorkan
struktur internal aplikasi (nama tabel, jalur berkas server, bahkan
sepotong kode sumber) kepada siapa pun yang kebetulan memicu error.

#warningbox[
`APP_DEBUG=true` pada environment produksi adalah salah satu
kesalahan konfigurasi paling umum dan paling berbahaya: begitu satu
saja request memicu exception yang tidak tertangani, Laravel
menampilkan halaman debug lengkap ke pengguna, termasuk isi variabel
environment lain yang mungkin berisi kredensial basis data. Berkas
`.env` produksi wajib memakai `APP_DEBUG=false` dan
`APP_ENV=production`.
]

Setelah konfigurasi environment benar, empat perintah berikut menyiapkan
Simple POS untuk berjalan lebih cepat di produksi:

+ Bangun aset frontend produksi. Server produksi tidak pernah
      menjalankan `npm run dev`, dev server yang membutuhkan Node tetap
      hidup di latar belakang; sebagai gantinya, `npm run build`
      membundel dan meminifikasi seluruh CSS & JavaScript sekali jadi ke
      `public/build/`, lalu direktif `@vite` yang sama dari
      Bab~3 otomatis membaca berkas hasil build itu, bukan dev server:

  #listing(```bash
  npm ci
  npm run build
    
  ```)

  #strong[Yang diharapkan]: keluaran diakhiri baris `built in N
      ms` bertanda centang, beserta daftar berkas `public/build/`
      yang dihasilkan. `npm ci` dipakai alih-alih `npm install` di
      lingkungan produksi karena ia memasang persis versi yang terkunci di
      `package-lock.json`, tanpa kemungkinan memutakhirkan versi
      paket secara tidak sengaja.
+ Jalankan migrasi tanpa konfirmasi interaktif yang biasanya
      muncul di lingkungan produksi (Laravel secara default menolak
      menjalankan migrasi begitu saja di `APP_ENV=production`
      tanpa flag ini, sebagai pengaman tambahan):

  #listing(```bash
  php artisan migrate --force
    
  ```)
+ Gabungkan seluruh berkas konfigurasi menjadi satu berkas
      terkompilasi:

  #listing(```bash
  php artisan config:cache
    
  ```)

  #strong[Yang diharapkan]: keluaran
      `INFO Configuration cached successfully.`
+ Gabungkan seluruh definisi route menjadi satu berkas
      terkompilasi:

  #listing(```bash
  php artisan route:cache
    
  ```)

  #strong[Yang diharapkan]: keluaran `INFO Routes cached
      successfully.` Kedua cache ini mempercepat setiap request karena
      Laravel tidak perlu memuat ulang puluhan berkas kecil setiap kali
      dijalankan.
+ #strong[Kalau aplikasi tiba-tiba error setelah
      `config:cache`] (mis. perubahan pada `.env` tidak
      terasa berpengaruh, atau route baru tidak ditemukan), itu tanda
      cache lama masih dipakai. Bersihkan dengan
      `php artisan config:clear` dan
      `php artisan route:clear`, lakukan perubahan yang
      diperlukan, baru jalankan ulang `config:cache`/`route:cache`.

== Praktik: Dokumentasi Teknis Simple POS <sec:optimasi-dan-deployment-3>

Kode yang berjalan benar tidak selalu menjelaskan dirinya sendiri
kepada pengembang berikutnya. Dokumentasi teknis yang baik tidak
mengulang apa yang sudah terbaca dari kode (nama kolom, nama metode),
tapi menjawab pertanyaan yang tidak bisa dijawab kode itu sendiri:
mengapa keputusan tertentu diambil.

+ Buat berkas `docs/architecture.md` di root proyek
      Simple POS (belum ada bawaan; ini berkas dokumentasi baru).
+ Isi dengan judul `## Keputusan Arsitektur`, lalu satu
      subbagian per keputusan yang sudah dibuat sepanjang buku ini,
      minimal dua contoh berikut:

  #listing(file: "docs/architecture.md", ```
  ## Keputusan Arsitektur

  ### Mengapa SQLite, bukan MySQL/PostgreSQL?
  Simple POS memakai SQLite untuk pengembangan karena tidak butuh
  proses server basis data terpisah, cocok untuk demo dan kelas.
  Skema tetap portabel ke MySQL/PostgreSQL lewat migrasi standar
  Laravel, dengan catatan: index foreign key harus tetap dibuat
  eksplisit (lihat Bab 4), karena MySQL membuatnya otomatis sementara
  SQLite tidak.

  ### Mengapa middleware kustom, bukan Spatie Permission?
  Simple POS hanya punya dua peran tetap (admin, kasir), sehingga
  middleware kustom `role:admin` lebih sederhana dan tidak menambah
  dependensi. Lihat Bab 7 untuk perbandingan lengkap.
    
  ```)

  Dua bagian di atas bukan sekadar mendeskripsikan apa yang ada
      (deskriptif), tapi menjelaskan mengapa pilihan itu diambil
      dibanding alternatif lain yang masuk akal (justifikasi), sesuatu
      yang tidak bisa disimpulkan pengembang baru hanya dengan membaca
      kode `EnsureUserHasRole` itu sendiri.
+ Tambahkan subbagian ketiga untuk satu keputusan lain yang belum
      tercatat, misalnya kenapa total transaksi dihitung ulang di server
      (Bab~6) atau kenapa impor CSV dipindah ke antrean (Bab~8).
+ #strong[Verifikasi]: minta satu rekan (atau baca ulang sendiri
      esok harinya) menjawab "kenapa Simple POS memakai SQLite" hanya
      dari membaca `docs/architecture.md`, tanpa membuka kode sama
      sekali. Kalau jawabannya meleset atau ia masih harus menebak,
      tambahkan kalimat yang hilang ke berkas itu.

#branchref("chapter-11")

== Rangkuman <sec:optimasi-dan-deployment-rangkuman>

- Profiling ulang lewat `DB::enableQueryLog()` dan
      `EXPLAIN QUERY PLAN` membuktikan dengan angka konkret bahwa
      perbaikan eager loading (Bab~5) dan index foreign key (Bab~4)
      benar-benar dipakai pada skenario mendekati produksi, bukan sekadar
      klaim teoretis.
- Persiapan deployment mencakup `APP_DEBUG=false` untuk
      mencegah kebocoran informasi sensitif, plus `npm run build`
      untuk membundel aset frontend produksi, `migrate --force`,
      `config:cache`, dan `route:cache` untuk
      menjalankan migrasi dan mempercepat request di lingkungan produksi.
- Dokumentasi teknis yang berguna menjelaskan mengapa sebuah
      keputusan arsitektur diambil dibanding alternatif lain, bukan
      sekadar mendeskripsikan ulang apa yang sudah terbaca langsung dari
      kode.

== Latihan

+ Profilkan satu query lain di Simple POS yang belum diperiksa di
      bab ini (misalnya listing produk per kategori), dan catat apakah
      ia sudah memakai index yang ada.
+ Siapkan checklist deployment versi sendiri, minimal lima butir,
      mencakup konfigurasi environment dan perintah cache.
+ Tulis satu halaman dokumentasi arsitektur untuk satu bagian
      Simple POS yang belum dibahas di bab ini (misalnya alur import CSV
      dari Bab~8).
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) mengapa `APP_DEBUG=true`
      berbahaya di produksi, (b) apa yang dilakukan
      `route:cache`, dan (c) perbedaan dokumentasi deskriptif
      dan dokumentasi yang menjelaskan justifikasi keputusan. Cocokkan
      jawabanmu dengan isi bab ini.

#challengebox[
Ukur perbaikan performa pada endpoint laporan penjualan Bab~8 sebelum
dan sesudah index `transactions.created_at` ditambahkan, lewat
`EXPLAIN QUERY PLAN`, dan tuliskan hasilnya dalam satu tabel
perbandingan.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel #cite(<laraveldocs>) untuk
konfigurasi deployment dan perintah caching.
