#import "/template.typ": *
#import "/diagrams.typ": *

= Arsitektur Web Modern dan Ekosistem Laravel <ch:arsitektur-web-modern>

#chapterhero("blue", [Bandingkan arsitektur monolith, microservices, dan serverless, lalu siapkan proyek Laravel 13 dengan SQLite sebagai fondasi Simple POS.], [#icon("server")#h(1em)monolith vs microservices], [#icon("code-branch")#h(1em)ekosistem Laravel], [#icon("database")#h(1em)Simple POS])

Sebuah restoran keluarga yang baru buka biasanya menangani semuanya sendiri:
pemilik memasak, anaknya mencatat pesanan, istrinya menghitung uang di meja
kasir yang sama dengan meja pelanggan makan. Semua orang tahu semua hal, dan
kalau dapur kebanjiran pesanan pada malam Minggu, solusinya cukup menambah
kompor, bukan membuka cabang baru di ujung kota. Bandingkan dengan food
court di sebuah mal, tempat setiap tenant punya dapur sendiri, kasir
sendiri, bahkan resep rahasia sendiri, dan pengelola mal hanya menyediakan
meja bersama serta jalur listrik. Kalau tenant bakso ramai sementara tenant
es krim sepi, keduanya tetap berjalan sebagai unit terpisah, tidak saling
menunggu.

Kedua model itu punya padanan persis dalam arsitektur perangkat lunak:
monolith seperti restoran keluarga (satu basis kode, satu proses, satu tim
yang mengurus semuanya), dan microservices seperti food court (banyak
layanan independen yang saling terhubung lewat jaringan). Simple POS,
aplikasi kasir yang dibangun bab demi bab sepanjang buku ini, dipilih
sebagai monolith bukan karena keterbatasan, melainkan karena skalanya
cocok: sebuah warung dengan satu atau dua kasir tidak butuh sepuluh layanan
terpisah hanya untuk mencatat penjualan segelas kopi. Salah pilih arsitektur
di titik ini, membangun food court untuk bisnis yang cukup dilayani satu
dapur, berarti menghabiskan waktu pengembangan untuk mengurus jaringan
antar-layanan yang sebenarnya tidak dibutuhkan, alih-alih menyelesaikan
fitur yang dipakai kasir setiap hari.

#strong[Yang Akan Kamu Pelajari]

+ membandingkan arsitektur monolith, microservices, dan serverless untuk menjelaskan alasan Laravel dipilih sebagai kerangka kerja monolith bagi Simple POS;
+ menyiapkan proyek Laravel 13 baru dengan SQLite sebagai basis data zero-setup, lengkap dengan `migrate:fresh --seed` dan `serve`;
+ mengenali struktur folder proyek Laravel (`routes/`, `app/Http/Controllers/`, `database/migrations/`) sebagai perwujudan pola MVC, lalu menginisialisasi repositori Git dengan commit `increment 1` pertama.

== Monolith, Microservices, dan Mengapa Laravel <sec:arsitektur-web-modern-1>

#istilahpenting[
/ Monolith: Aplikasi yang seluruh lapisannya, antarmuka, logika bisnis, dan akses data, berjalan dalam satu basis kode dan satu proses deploy. Sering disalahpahami sebagai "kode berantakan"; monolith yang terstruktur (mis. dengan MVC) tetap rapi, lawan katanya bukan "modular", melainkan "terdistribusi".
/ Microservices: Arsitektur yang memecah aplikasi menjadi layanan-layanan independen, masing-masing berjalan dan di-deploy sendiri, saling berkomunikasi lewat jaringan. Aturan praktis: baru sepadan ketika organisasi punya banyak tim yang masing-masing bisa memiliki dan mengoperasikan layanannya sendiri; satu tim kecil yang memecah aplikasinya hanya menambah ongkos operasional.
]

Sebuah aplikasi #term[monolith] menyimpan seluruh kodenya, mulai dari
tampilan yang dilihat pengguna sampai query yang menyentuh basis data, dalam
satu proyek yang di-deploy sebagai satu unit. Menambah fitur berarti
menambah kode pada proyek yang sama; men-deploy pembaruan berarti mengganti
satu unit itu dengan versi barunya. Sebaliknya, #term[microservices]
memecah tanggung jawab itu ke layanan-layanan terpisah, misalnya satu
layanan khusus mengurus katalog produk, layanan lain khusus mengurus
pembayaran, dan keduanya saling bicara lewat panggilan jaringan (biasanya
HTTP atau message queue). Pemisahan ini memberi kebebasan: setiap layanan
bisa ditulis dengan bahasa berbeda, di-deploy dengan jadwal berbeda, dan
diskalakan sendiri-sendiri saat trafiknya melonjak.

Kebebasan itu punya harga. Sebuah tim yang memecah aplikasinya menjadi
delapan layanan terpisah kini harus mengurus delapan proses deploy, delapan
titik yang bisa gagal, dan komunikasi jaringan antar-layanan yang sebelumnya
cukup dipanggil sebagai satu fungsi biasa di dalam proses yang sama. Untuk
tim besar yang mengoperasikan sistem berskala jutaan pengguna, ongkos itu
sepadan dengan kebebasan yang didapat. Untuk aplikasi seperti Simple POS,
yang melayani satu warung dengan volume transaksi harian yang bisa dihitung
manual di kertas, ongkos itu jauh melebihi manfaatnya.

#figure(
  table(
    columns: (1fr, 1.2fr, 1fr, 1.4fr),
    align: (left, left, left, left),
    table.hline(stroke: 0.8pt),
    [Arsitektur], [Deployment], [Kompleksitas Awal], [Cocok Untuk],
    table.hline(stroke: 0.5pt),
    [Monolith], [Satu unit], [Rendah], [Simple POS, MVP, tim kecil],
    [Microservices], [Banyak unit independen], [Tinggi], [Sistem skala besar, tim besar],
    [Serverless], [Fungsi per event], [Sedang], [Beban kerja sporadis],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Perbandingan arsitektur monolith, microservices, dan serverless],
) <tab:arsitektur-perbandingan>

#figure(
  diagram-monolith(),
  caption: [Struktur monolith (satu basis kode, tiga lapisan menyatu) vs
microservices (layanan independen yang saling memanggil lewat jaringan)],
) <fig:monolith-microservices>

#istilahpenting[
/ Serverless: Model eksekusi kode sebagai fungsi-fungsi kecil yang hanya berjalan saat dipicu peristiwa, tanpa proses server yang menyala terus-menerus; penyedia cloud yang mengurus infrastrukturnya. Namanya menyesatkan: server tetap ada, hanya bukan tanggung jawabmu. Karena proses tidak hidup terus-menerus, ada jeda #emph[cold start] saat fungsi lama tidak dipanggil, dan biaya dihitung per eksekusi, bukan per jam server menyala.
]

#term[Serverless] menempuh jalan ketiga: kode ditulis sebagai fungsi-fungsi
kecil yang hanya berjalan ketika ada peristiwa yang memicunya (permintaan
HTTP, jadwal cron, pesan baru di antrean), dan penyedia layanan cloud yang
mengurus server di baliknya. Cocok untuk beban kerja yang naik-turun tajam,
misalnya pemrosesan gambar yang hanya dipicu saat pengguna mengunggah foto,
tetapi kurang cocok untuk aplikasi seperti Simple POS yang butuh koneksi
basis data yang konsisten sepanjang jam operasional warung.

#istilahpenting[
/ MVC: Pola #emph[Model-View-Controller]: Model mengurus data, View mengurus tampilan, Controller mengurus alur permintaan di antara keduanya. Aturan praktis menaruh kode: menyentuh data ke Model, mengatur alur permintaan ke Controller, menampilkan ke View. Framework tidak memaksa ini, query di dalam view tetap bisa jalan, pola ini adalah disiplin yang dijaga penulis kodenya sendiri.
]

Laravel dipilih sebagai kerangka kerja buku ini karena memetakan tepat ke
kebutuhan monolith: satu proyek PHP yang sudah menyediakan routing,
autentikasi, ORM, dan sistem template tanpa perlu merakit potongan pustaka
dari sumber berbeda. Dibandingkan menulis PHP polos dari nol, Laravel
memberi struktur #term[MVC] yang konsisten sejak baris kode pertama; dibandingkan
kerangka kerja microservices-first yang lebih rumit, Laravel tetap
produktif untuk tim satu atau dua orang yang mengejar tenggat.

#figure(
  diagram-lifecycle(),
  caption: [Alur satu request Laravel: dari permintaan HTTP masuk lewat
router, ditangani controller, mengambil/mengubah data lewat model, sampai
respons dikembalikan lewat view],
) <fig:laravel-lifecycle>

Alur pada #xref(<fig:laravel-lifecycle>) adalah pola yang akan berulang di
hampir setiap bab buku ini: `/pos` pada Bab~3 mengikuti alur ini
persis, begitu juga setiap endpoint API pada Bab~9.

Satu detail yang membedakan Laravel dari PHP polos: pada PHP polos, alamat
URL biasanya sama persis dengan path berkas di server (mis.
`/produk.php` memuat `produk.php`). Laravel meniadakan pemetaan
langsung ini; setiap permintaan, apa pun alamatnya, selalu masuk lewat satu
berkas yang sama, `public/index.php`, yang baru kemudian menyerahkan
permintaan itu ke `routes/web.php` untuk dicocokkan dengan Controller
yang sesuai. Tidak ada berkas lain di dalam proyek yang bisa diakses
langsung lewat URL. Mulai Bab~2, kamu juga akan melihat pemanggilan seperti
`Route::get(...)`; sekilas mirip pemanggilan method static PHP biasa,
tetapi proses di baliknya berbeda (disebut #emph[facade]), dijelaskan
lebih lanjut saat pertama kali dipakai.

#notebox[
Laravel bukan satu-satunya kerangka kerja PHP, dan PHP bukan satu-satunya
bahasa untuk membangun aplikasi web monolith. Django (Python) dan Ruby on
Rails punya filosofi "convention over configuration" yang mirip Laravel.
Posisi Laravel yang menonjol ada pada ekosistem
paketnya (Sanctum untuk API, Excel untuk impor/ekspor, Cashier untuk
pembayaran) yang langsung terintegrasi tanpa konfigurasi berlebihan, sesuatu
yang akan terasa langsung mulai Bab~9.
]

== Menyiapkan Proyek Laravel dan SQLite <sec:arsitektur-web-modern-2>

Setiap proyek Laravel butuh basis data untuk berjalan, dan buku ini memilih
SQLite alih-alih MySQL atau PostgreSQL untuk satu alasan praktis: SQLite
menyimpan seluruh basis data dalam satu berkas biasa, tanpa proses server
terpisah yang harus dinyalakan, dikonfigurasi, dan diberi kredensial
sebelum baris kode pertama dijalankan. Pembaca yang baru menginstal PHP
bisa langsung menjalankan migrasi pada menit pertama, bukan menghabiskan
setengah jam mengatur akun MySQL. Simple POS sendiri berjalan di atas
SQLite bahkan untuk demonstrasi kelas, bukan cuma untuk latihan buku ini.

#tipbox[
Sebelum lanjut, pastikan empat alat berikut sudah terpasang dengan
menjalankan masing-masing perintah ini di terminal: `php -v` (versi
8.2 ke atas), `composer -V`, `node -v`, dan `git --version`.
Kalau salah satu belum terpasang atau versinya terlalu lama, instal dulu
sebelum melanjutkan ke langkah berikutnya; Lampiran~E menuntun instalasi
keempatnya per sistem operasi (Windows, macOS, Linux).
]

#istilahpenting[
/ Artisan: Antarmuka baris perintah bawaan Laravel untuk menjalankan tugas pengembangan sehari-hari: migrasi, seeding, dan pembuatan berkas boilerplate. Daftar lengkap perintahnya bisa dilihat kapan saja dengan menjalankan `php artisan list`; Artisan hanya alat bantu pengembangan, tidak ikut berjalan saat aplikasi melayani pengguna. Daftar perintah Artisan dan Composer yang paling sering dipakai di buku ini terangkum di Lampiran~B.
/ Migrasi: Berkas PHP yang mendefinisikan perubahan skema basis data secara terprogram, sehingga skema dapat dibangun ulang secara konsisten di komputer mana pun. Perlakukan seperti version control untuk skema: perubahan baru berarti berkas migrasi baru, bukan mengedit migrasi lama yang sudah pernah dijalankan di komputer lain.
]

#listing(```bash
composer create-project laravel/laravel simple-pos
cd simple-pos
cp .env.example .env
php artisan key:generate
```)

#strong[Yang diharapkan]: `composer create-project` mencetak daftar
paket yang diunduh satu per satu, diakhiri baris seperti
`Application ready in simple-pos. You can now start using
Composer!`; `key:generate` mencetak
`INFO Application key set successfully.` Tiga perintah terakhir
menyiapkan berkas konfigurasi `.env` (tempat kredensial dan
pengaturan lingkungan disimpan, terpisah dari kode sumber supaya tidak
pernah ikut ter-commit ke Git) dan menghasilkan kunci enkripsi aplikasi
yang dipakai Laravel untuk mengamankan sesi dan cookie.

`composer create-project` bukan sekadar mengunduh Laravel, melainkan
menjalankan Composer, pengelola dependensi PHP: ia membaca berkas
`composer.json`, mengunduh setiap paket yang terdaftar ke
`vendor/`, lalu menghasilkan `vendor/autoload.php`. Berkas
itulah yang membuat setiap class di proyek ini, termasuk milikmu sendiri,
langsung bisa dipakai tanpa `require` atau `include` manual
seperti pada PHP polos. Nilai di `.env` juga tidak langsung dipakai
di kode; Laravel membacanya lewat helper `env()`, yang biasanya
dibungkus lagi oleh berkas `config/*.php` dan diakses lewat helper
`config()`. Lapisan ini tidak ada padanannya di PHP polos yang
biasanya hanya memakai konstanta atau berkas `.ini` tunggal, tetapi
memungkinkan konfigurasi di-cache untuk performa saat aplikasi berjalan
di server produksi (dibahas lebih lanjut pada Bab~11).

#tipbox[
#strong[Kalau `composer create-project` gagal] dengan pesan yang
menyinggung versi PHP (mis. `requires php ^8.2`),
jalankan
`php -v` untuk memastikan versi PHP yang terpasang 8.2 ke atas;
Laravel 13 tidak bisa dipasang di versi PHP yang lebih lama.
]

Selain dependensi PHP yang baru saja diinstal `composer`, proyek Laravel
terbaru juga menyertakan `package.json`: daftar dependensi JavaScript
untuk toolchain frontend (Vite dan Tailwind CSS) yang akan mulai dipakai
Bab~3. `npm install` adalah padanan `composer install` di dunia
JavaScript, membaca `package.json` lalu mengunduh setiap paket yang
terdaftar ke folder `node_modules/`:

#listing(```bash
npm install
```)

#strong[Yang diharapkan]: `npm install` mencetak jumlah paket yang
terpasang, diakhiri baris seperti `added N packages in Ns`, tanpa
baris `npm error` di antaranya. Langkah ini belum wajib untuk
menjalankan Simple POS hari ini; halaman bawaan Laravel masih tampil
dengan gaya cadangan meski `node_modules/` belum ada.
Menjalankannya sekarang menghindari jeda instalasi mendadak begitu Bab~3
mulai memakai Tailwind dan Alpine.js lewat Vite. Langkah berikutnya
mengarahkan koneksi basis data ke sebuah berkas SQLite:

#listing(```bash
touch database/database.sqlite
php artisan migrate:fresh --seed
```)

#strong[Yang diharapkan]: daftar migrasi tercetak satu per satu, masing-masing
diakhiri kata `DONE`, tanpa satu pun baris error di antaranya,
diikuti pesan bahwa seeder selesai berjalan. `migrate:fresh`
menjalankan seluruh berkas migrasi dari awal (menghapus tabel lama jika
ada, lalu membangunnya kembali dari definisi skema terbaru), sedangkan
opsi `--seed` langsung mengisi tabel yang baru dibuat dengan data
contoh lewat berkas seeder. Untuk Simple POS, seeder ini mengisi ratusan
produk dan ribuan transaksi sekaligus, sesuatu yang akan dibahas lebih
dalam pada Bab~4 ketika alasan mengisi data dalam skala nyata, bukan
sekadar beberapa baris, mulai terlihat manfaatnya.

#warningbox[
Berkas `.env` menyimpan informasi yang sensitif (kunci aplikasi,
kredensial basis data produksi jika ada) dan tidak boleh ikut di-commit ke
Git. Proyek hasil `composer create-project` sudah menyertakan berkas
`.gitignore` yang mengecualikan `.env` secara default; jangan
pernah menghapus baris itu.
]

Setelah migrasi selesai, server pengembangan bawaan Laravel bisa langsung
dijalankan tanpa konfigurasi web server terpisah seperti Apache atau Nginx:

#listing(```bash
php artisan serve
```)

#strong[Yang diharapkan]: baris `INFO Server running on
[http://127.0.0.1:8000]`, lalu terminal tetap terbuka menunggu request
(tekan `Ctrl+C` untuk menghentikannya). Buka alamat itu di
browser; halaman selamat datang Laravel, bukan pesan error, adalah
tanda seluruh langkah di bagian ini berhasil. Perintah ini menjalankan
aplikasi pada `http://127.0.0.1:8000` memakai server PHP bawaan,
cukup untuk seluruh pengembangan lokal di buku ini. Server produksi
sungguhan (dibahas pada Bab~11) memakai konfigurasi berbeda, tetapi
struktur aplikasi yang dipelajari di sini tetap sama persis.

== Praktik: Inisialisasi Simple POS dan Alur Git <sec:arsitektur-web-modern-3>

#heading(level: 3, numbering: none, outlined: false)[Praktik 1.1: Mengenal Struktur Proyek]

Sebelum menulis kode fitur pertama, penting mengenali bagian mana dari
struktur folder Laravel yang akan sering disentuh sepanjang buku ini, dan
mana yang boleh diabaikan untuk sementara.

+ Buka folder `routes/`, khususnya `routes/web.php`: di
      sinilah setiap alamat URL yang bisa diakses pengguna aplikasi
      didaftarkan.
+ Buka folder `app/Http/Controllers/`: tempat class yang
      memproses setiap permintaan (menerima input, memanggil model, memilih
      tampilan) akan bertambah satu demi satu mulai Bab~2.
+ Buka folder `database/migrations/`: tempat perubahan skema
      basis data didefinisikan sebagai kode, bukan diklik lewat aplikasi
      basis data terpisah.
+ Bandingkan dengan folder `vendor/`: berisi seluruh paket
      Composer pihak ketiga, tidak pernah diedit manual, dan tidak ikut
      di-commit ke Git.

Struktur ini bukan kebetulan. Ia mewujudkan pola MVC yang disinggung di
istilah penting bagian awal bab: `routes/` dan
`app/Http/Controllers/` menangani sisi Controller, model Eloquent yang
akan diperkenalkan di Bab~5 menangani sisi Model, dan berkas Blade di
`resources/views/` (dibahas mulai Bab~3) menangani sisi View.

#heading(level: 3, numbering: none, outlined: false)[Praktik 1.2: Konvensi Commit Increment pada Simple POS]

Repositori Simple POS yang menjadi rujukan buku ini tidak dibangun sekaligus
sebagai satu proyek utuh, melainkan tumbuh commit demi commit, masing-masing
diberi label `increment N`. Increment 1 hanya berisi kerangka proyek
kosong hasil `composer create-project`, persis seperti hasil Praktik
1.1; increment berikutnya menambah satu kemampuan konkret, routing dan
controller produk, lalu tampilan Blade, lalu skema basis data, mengikuti
urutan yang sama dengan urutan bab pada buku ini. Membaca riwayat commit
Simple POS secara berurutan sama seperti membaca buku ini bab demi bab,
hanya dalam bentuk kode sungguhan alih-alih prosa. Langkah-langkah berikut
membuat commit `increment 1` milikmu sendiri, supaya konvensi ini
terasa nyata, bukan cuma dibaca.

+ `composer create-project` tidak otomatis menyiapkan repositori
      Git (berbeda dari installer `laravel new` yang melakukannya
      otomatis), jadi langkah ini sengaja dilakukan manual dari dalam folder
      `simple-pos/`:

  #listing(```bash
  git init
    
  ```)

  #strong[Yang diharapkan]: pesan `Initialized empty Git
      repository in .../simple-pos/.git/`.
+ Tambahkan seluruh berkas proyek ke area staging, lalu buat commit
      pertama dengan pesan yang mengikuti konvensi `increment N`:

  #listing(```bash
  git add .
  git commit -m "increment 1: proyek Laravel kosong"
    
  ```)

  #strong[Yang diharapkan]: ringkasan jumlah berkas yang di-commit,
      diakhiri baris seperti `N files changed, M insertions(+)`.
      Perhatikan bahwa `vendor/`, `node_modules/`, dan
      `.env` tidak ikut disebutkan; `.gitignore` bawaan Laravel
      sudah mengecualikan ketiganya, persis seperti peringatan pada bagian
      sebelumnya.
+ Verifikasi commit itu benar-benar tersimpan:

  #listing(```bash
  git log --oneline
    
  ```)

  #strong[Yang diharapkan]: satu baris berisi hash pendek diikuti pesan
      `increment 1: proyek Laravel kosong` persis seperti yang baru
      saja ditulis.
+ #strong[Kalau `git commit` gagal] dengan pesan yang meminta
      `user.name`/`user.email`, ini komputer yang belum
      pernah dipakai Git sebelumnya; atur sekali saja dengan
      `git config --global user.name "Nama Kamu"` dan
      `git config --global user.email "email@kamu.com"`, lalu ulangi
      langkah 2.

#tipbox[
Kode lengkap setiap bab tersedia dalam dua bentuk. Repositori
`\repobase` menyimpan seluruh riwayatnya dalam satu tempat, dengan
satu branch per bab (`chapter-01` hingga `chapter-12`), setiap
branch dibangun di atas branch bab sebelumnya; cocok dibaca berurutan
seperti membaca riwayat commit sungguhan. Setiap akhir bagian Praktik pada
buku ini, seperti kotak di bawah, sebaliknya menunjuk ke repositori
template tersendiri untuk bab itu saja (mis. `\repoowner/simple-pos-ch04`
untuk Bab~4): klik tombol #strong[Use this template] di GitHub untuk
langsung mulai dari kondisi bab itu, tanpa perlu tahu cara `git
checkout` branch tertentu. Buku ini menampilkan potongan kode yang paling
penting untuk dipahami; kode penuh yang siap dijalankan selalu ada di
kedua repositori itu.
]

#branchref("chapter-01")

== Rangkuman <sec:arsitektur-web-modern-rangkuman>

- Monolith menyatukan seluruh lapisan aplikasi dalam satu basis kode
      dan satu proses deploy, cocok untuk skala Simple POS; microservices
      memecahnya menjadi layanan independen dengan ongkos operasional yang
      hanya sepadan untuk sistem berskala besar; serverless cocok untuk beban
      kerja sporadis, bukan aplikasi dengan koneksi basis data yang konsisten.
- Proyek Laravel 13 disiapkan dengan `composer create-project`,
      dihubungkan ke SQLite sebagai basis data zero-setup, lalu dijalankan
      dengan `migrate:fresh --seed` dan `serve`.
- Struktur folder Laravel (`routes/`, `app/Http/Controllers/`,
      `database/migrations/`) mewujudkan pola MVC; commit
      `increment N` pertama menandai repositori Git terinisialisasi,
      dengan konvensi yang sama memetakan pertumbuhan aplikasi bab demi bab
      dan kode lengkap tiap bab tersedia sebagai branch tersendiri di
      GitHub.

== Latihan

+ Jalankan seluruh perintah setup pada Bagian 2 (`composer
      create-project` sampai `serve`) di komputermu sendiri, lalu
      verifikasi bahwa `php artisan serve` menampilkan halaman selamat
      datang Laravel di `http://127.0.0.1:8000`; lanjutkan dengan
      ketiga perintah Git pada Praktik 1.2 dan pastikan `git log
      --oneline` menampilkan commit `increment 1` milikmu.
+ Buka `database/migrations/` pada proyek yang baru dibuat, lalu
      identifikasi berapa banyak berkas migrasi yang sudah ada secara bawaan
      (tanpa menulis kode apa pun) dan tabel apa saja yang dibuatnya.
+ Jelaskan dengan kata-katamu sendiri: mengapa sebuah warung dengan
      satu kasir lebih cocok memakai arsitektur monolith dibanding
      microservices, sementara sebuah platform e-commerce nasional dengan
      jutaan pengguna sering memakai microservices.
+ #strong[Evaluasi mandiri:] tanpa membuka kembali isi bab ini, coba
      jelaskan dengan kata-katamu sendiri: (a) perbedaan monolith dan
      microservices, (b) mengapa SQLite dipilih untuk buku ini, dan (c) apa
      fungsi opsi `--seed` pada `migrate:fresh`. Periksa kembali
      jawabanmu dengan isi bab ini, dan catat bagian mana yang masih perlu
      dipelajari ulang.

== Referensi

Pembahasan pada bab ini merujuk pada dokumentasi resmi Laravel
#cite(<laraveldocs>) untuk struktur proyek dan perintah Artisan, serta
Manual PHP #cite(<phpmanual>) untuk rujukan bahasa yang mendasari kerangka
kerja Laravel.
