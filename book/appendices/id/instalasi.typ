#import "/template.typ": *

= Panduan Instalasi Lingkungan Pengembangan <app:instalasi>

Bab~1 mengasumsikan empat alat baris perintah sudah terpasang: PHP,
Composer, Node.js, dan Git (lihat kotak tip sebelum `composer
create-project` pada bab tersebut). Lampiran ini menuntun pemasangan
keempatnya dari nol, dipisah per sistem operasi, lalu ditutup dengan
langkah verifikasi yang sama untuk ketiganya.

#figure(
  table(
    columns: (0.8fr, 0.9fr, 1.6fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Alat]], [#strong[Versi Minimum]], [#strong[Kegunaan]],
    table.hline(stroke: 0.5pt),
    [PHP], [8.2], [Menjalankan Laravel 13 dan perintah Artisan],
    [Composer], [2.x], [Memasang dependensi PHP dari `composer.json`],
    [Node.js], [18 LTS], [Menjalankan `npm` untuk toolchain Vite + Tailwind (Bab~3)],
    [Git], [2.x], [Melacak versi kode dan mengikuti branch `chapter-NN`],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Alat yang dibutuhkan sebelum mengikuti Bab~1],
) <tab:instalasi-kebutuhan>

== Windows

Cara paling ringkas di Windows 10/11 adalah #pkg[winget], pengelola paket
bawaan yang sudah terpasang di sebagian besar instalasi modern. Buka
PowerShell lalu jalankan keempat perintah berikut satu per satu:

#listing(```bash
winget install PHP.PHP.8.3
winget install Composer.Composer
winget install OpenJS.NodeJS.LTS
winget install Git.Git
```)

#warningbox[
Berkas `php.ini` bawaan dari paket #pkg[PHP.PHP.8.3] mematikan
sebagian ekstensi secara default, termasuk `pdo_sqlite` yang
dibutuhkan Simple POS. Jalankan `php --ini` untuk menemukan lokasi
`php.ini` yang dipakai, buka berkas itu, lalu hapus tanda `;`
di depan baris `extension=pdo_sqlite` dan
`extension=fileinfo`. Lihat #xref(<sec:instalasi-ekstensi>) untuk
daftar lengkap ekstensi yang dibutuhkan.
]

#tipbox[
Tutup dan buka ulang jendela terminal setelah instalasi #pkg[winget]
selesai. Variabel PATH yang baru ditambahkan hanya dibaca ulang oleh
terminal yang baru dibuka, bukan yang sedang berjalan.
]

Alternatif lain adalah #pkg[Scoop], pengelola paket yang memasang semua
alat ke direktori milik pengguna sendiri (`~\
scoop`) tanpa memerlukan hak administrator maupun jendela konfirmasi UAC.
Cocok dipakai di komputer laboratorium kampus atau kantor yang akunnya
tidak diberi akses administrator. Buka PowerShell lalu jalankan:

#listing(```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
scoop install php composer nodejs-lts git
```)

#notebox[
Dua baris pertama memasang Scoop itu sendiri (mengizinkan menjalankan
skrip PowerShell yang ditandatangani lokal, lalu mengunduh dan menjalankan
installer Scoop); baris ketiga memasang keempat alat sekaligus dari
bucket `main` bawaan Scoop. Paket #pkg[php] dari Scoop memakai
`php.ini` bawaan Windows yang sama seperti paket #pkg[winget], jadi
peringatan ekstensi `pdo_sqlite` di atas berlaku sama persis di
sini. Pilih satu pengelola paket saja, #pkg[winget] atau #pkg[Scoop],
tidak keduanya sekaligus; dua instalasi PHP yang bersaing di PATH adalah
sumber kebingungan paling umum saat `php -v` menampilkan versi yang
tidak diharapkan (lihat kotak peringatan pada bagian Verifikasi
Instalasi).
]

== macOS

#pkg[Homebrew] adalah pengelola paket pihak ketiga paling umum dipakai di
macOS. Kalau belum terpasang, ikuti instruksi di #link("https://brew.sh")
terlebih dahulu, lalu jalankan:

#listing(```bash
brew install php composer node git
```)

#notebox[
Paket #pkg[php] dari Homebrew sudah menyertakan `pdo_sqlite` dan
seluruh ekstensi pada #xref(<sec:instalasi-ekstensi>) secara aktif, jadi
langkah edit `php.ini` pada bagian Windows tidak diperlukan di
macOS.
]

#warningbox[
macOS menyertakan PHP bawaan sistem di `/usr/bin/php`, biasanya versi
lama yang tidak didukung Laravel 13. Setelah `brew install php`,
pastikan `which php` menunjuk ke `/opt/homebrew/bin/php` (Apple
Silicon) atau `/usr/local/bin/php` (Intel), bukan ke
`/usr/bin/php`. Kalau masih menunjuk ke versi sistem, tambahkan baris
`export PATH="/opt/homebrew/bin:$PATH"` ke `~
/.zshrc`, lalu buka terminal baru.
]

== Linux (Debian/Ubuntu)

#listing(```bash
sudo apt update
sudo apt install php php-cli php-sqlite3 php-mbstring php-xml php-curl unzip
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo apt install nodejs npm git
```)

#notebox[
Repositori paket bawaan Ubuntu LTS kadang tertinggal beberapa versi PHP
di belakang rilis terbaru. Kalau `php -v` menampilkan versi di bawah
8.2 setelah `apt install`, tambahkan PPA
#pkg[ondrej/php] (`sudo add-apt-repository ppa:ondrej/php`) sebelum
menjalankan ulang `apt update && apt install php8.3`. Pengguna
Fedora dan Arch Linux memakai nama paket serupa lewat `dnf install
php composer nodejs npm git` atau `pacman -S php composer nodejs npm
git`.
]

== Verifikasi Instalasi

Setelah salah satu jalur di atas selesai, jalankan keempat perintah
berikut di terminal untuk memastikan semuanya terpasang dan terjangkau
lewat PATH:

#listing(```bash
php -v
composer -V
node -v
git --version
```)

#figure(
  image("/images/verifikasi-instalasi.png", width: 85%),
  caption: [Contoh keluaran terminal setelah keempat perintah verifikasi
dijalankan berurutan; nomor versi persis pada layarmu akan berbeda
tergantung kapan alat dipasang, yang penting tidak ada pesan
`command not found`],
) <fig:verifikasi-instalasi>

#warningbox[
Kalau `php -v` menampilkan versi lama padahal baru saja memasang versi
baru, kemungkinan ada instalasi PHP lain yang lebih dulu ditemukan di
PATH (umum terjadi di macOS dengan PHP bawaan sistem, atau Windows dengan
XAMPP lama yang masih terpasang). Jalankan `which php` (macOS/Linux)
atau `where.exe php` (Windows) untuk melihat urutan lokasi yang
diperiksa, lalu sesuaikan PATH agar instalasi yang benar muncul lebih
dulu.
]

== Ekstensi PHP yang Dibutuhkan Laravel <sec:instalasi-ekstensi>

Laravel 13 memeriksa keberadaan sembilan ekstensi PHP saat
`composer create-project` maupun `php artisan serve` dijalankan.
Kebanyakan sudah aktif secara default pada instalasi PHP modern, tetapi
paket minimal (terutama build manual dari sumber, atau image Docker
`php:cli` tanpa tambahan) sering melewatkan sebagian.

#figure(
  table(
    columns: (1fr, 1.8fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Ekstensi]], [#strong[Kegunaan]],
    table.hline(stroke: 0.5pt),
    [OpenSSL], [Enkripsi sesi, cookie, dan kunci aplikasi],
    [PDO & `pdo_sqlite`], [Koneksi Eloquent ke berkas `database.sqlite`],
    [Mbstring], [Manipulasi string aman-UTF-8 (nama produk, label transaksi)],
    [Tokenizer], [Parser internal Composer dan Blade],
    [XML], [Parser konfigurasi paket Composer],
    [Ctype & JSON], [Validasi input dan respons API (Bab~9)],
    [BCMath], [Perhitungan desimal presisi tinggi untuk total transaksi],
    [Fileinfo], [Deteksi tipe berkas saat impor CSV (Bab~8)],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Ekstensi PHP wajib untuk Laravel 13 dan Simple POS],
) <tab:instalasi-ekstensi>

#tipbox[
Perintah `php -m` mencetak seluruh ekstensi yang aktif pada instalasi
PHP saat ini. Gabungkan dengan `grep` untuk memeriksa satu per satu,
misalnya `php -m | grep -i sqlite` untuk memastikan
`pdo_sqlite` sudah aktif sebelum menjalankan
`php artisan migrate:fresh --seed` pertama kali.
]
