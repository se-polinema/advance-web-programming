---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    padding: 56px 72px;
    justify-content: center;
  }
  section.lead {
    background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 55%, #2563eb 100%);
    color: #fff;
    justify-content: center;
  }
  section.lead h1, section.lead h2, section.lead p {
    color: #fff;
  }
  section.divider {
    background: #1d4ed8;
    color: #fff;
  }
  section.divider h1 {
    color: #fff;
    font-size: 2.2em;
  }
  section.divider p {
    color: #bfdbfe;
  }
  h1 {
    color: #1d4ed8;
    font-size: 1.6em;
  }
  h2 {
    color: #1d4ed8;
  }
  table {
    font-size: 0.72em;
    width: 100%;
  }
  table.small {
    font-size: 0.75em;
  }
  th, td {
    padding: 4px 10px;
  }
  th {
    background: #1d4ed8;
    color: #fff;
  }
  code {
    background: #f1f5f9;
    color: #0f172a;
  }
  pre {
    font-size: 0.68em;
  }
  .term-box {
    border-left: 6px solid #1d4ed8;
    background: #eff6ff;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.82em;
  }
  .term-box b {
    color: #1d4ed8;
  }
  .tip-box {
    border-left: 6px solid #16a34a;
    background: #f0fdf4;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .warn-box {
    border-left: 6px solid #dc2626;
    background: #fef2f2;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .cols {
    display: flex;
    gap: 24px;
  }
  .cols > div {
    flex: 1;
  }
  .flow {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-top: 30px;
    flex-wrap: wrap;
  }
  .flow .box {
    background: #1d4ed8;
    color: #fff;
    padding: 12px 18px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 0.85em;
  }
  .flow .arrow {
    font-size: 1.4em;
    color: #1d4ed8;
  }
  .stack .box {
    background: #1d4ed8;
    color: #fff;
    padding: 10px;
    border-radius: 6px;
    text-align: center;
    margin: 4px 0;
    font-weight: bold;
  }
  .footnote {
    font-size: 0.55em;
    color: #64748b;
    position: absolute;
    bottom: 20px;
  }
---

<!-- _class: lead -->

# Pemrograman Web Lanjut
## SIB245007 &nbsp;|&nbsp; D-IV Sistem Informasi Bisnis

Pertemuan 1: **Arsitektur Web Modern dan Ekosistem Laravel**

Rencana Pembelajaran Semester (RPS) & Materi Pertemuan 1

---

<!-- _class: divider -->

# Bagian 1
## Rencana Pembelajaran Semester (RPS)

---

## Identitas Mata Kuliah

| | |
|---|---|
| **Program Studi** | D-IV Sistem Informasi Bisnis |
| **Kode Mata Kuliah** | SIB245007 |
| **Nama Mata Kuliah** | Pemrograman Web Lanjut |

<div class="tip-box">
Mata kuliah ini memakai <b>Simple POS</b>, aplikasi kasir/point-of-sale UMKM yang kodenya nyata dan berkembang commit demi commit, sebagai studi kasus berjalan sepanjang satu semester.
</div>

---

## Rencana Pembelajaran Semester

<div class="cols">
<div>

<table class="small">
<tr><th>Pertemuan</th><th>Materi</th></tr>
<tr><td>1</td><td>Arsitektur Web Modern</td></tr>
<tr><td>2</td><td>HTTP &amp; Arsitektur MVC</td></tr>
<tr><td>3</td><td>Frontend &amp; Templating</td></tr>
<tr><td>4</td><td>Desain Basis Data &amp; Migrasi</td></tr>
<tr><td>5</td><td>ORM &amp; Relasi Data</td></tr>
<tr><td>6</td><td>Validasi &amp; Keamanan Input</td></tr>
<tr><td>7</td><td>Autentikasi &amp; Otorisasi</td></tr>
<tr><td>8</td><td><b>UTS</b></td></tr>
<tr><td>9</td><td>Pengolahan &amp; Ekspor Data</td></tr>
</table>

</div>
<div>

<table class="small">
<tr><th>Pertemuan</th><th>Materi</th></tr>
<tr><td>10</td><td>Arsitektur &amp; Desain API</td></tr>
<tr><td>11</td><td>Perencanaan Proyek PBL</td></tr>
<tr><td>12</td><td>Pengembangan Fitur PBL</td></tr>
<tr><td>13</td><td>Integrasi &amp; Pengujian PBL</td></tr>
<tr><td>14</td><td>Optimasi &amp; Deployment PBL</td></tr>
<tr><td>15</td><td>Finalisasi Proyek PBL</td></tr>
<tr><td>16</td><td>Persiapan Ujian Akhir PBL</td></tr>
<tr><td>17</td><td><b>UAS</b></td></tr>
</table>

</div>
</div>

<div class="tip-box">
Pertemuan 1&ndash;10 membangun fondasi teknis Laravel; Pertemuan 11&ndash;17 mengalihkannya menjadi proyek <i>Project Based Learning</i> (PBL) mandiri.
</div>

---

## Komponen Evaluasi

| Basis Evaluasi | Bobot |
|---|---:|
| Aktivitas Partisipatif (Case Method) | 0% |
| Hasil Proyek (Project Based Learning) | 55% |
| Kognitif &ndash; Tugas mingguan (increment) | 15% |
| Kognitif &ndash; Quiz | 0% |
| Kognitif &ndash; UTS (progress proyek + presentasi) | 5% |
| Kognitif &ndash; UAS (proyek final + presentasi) | 25% |
| **Total** | **100%** |

<div class="term-box">
<b>Tugas mingguan</b>: implementasi bertahap (<i>increment</i>) aplikasi Simple POS, dikumpulkan sebagai bukti kode dan dokumentasi sesuai rubrik.
</div>

---

<!-- _class: divider -->

# Bagian 2
## Pertemuan 1: Arsitektur Web Modern dan Ekosistem Laravel

---

## Yang Akan Kamu Pelajari

1. Membandingkan arsitektur **monolith**, **microservices**, dan **serverless** untuk menjelaskan alasan Laravel dipilih sebagai kerangka kerja Simple POS

2. Memahami alasan **Laravel 13** dengan **SQLite** sebagai basis data zero-setup dipilih untuk Simple POS

3. Mengenali struktur folder proyek Laravel (`routes/`, `app/Http/Controllers/`, `database/migrations/`) sebagai perwujudan pola **MVC**

<div class="tip-box">
Slide ini membahas konsep. Langkah instalasi, setup proyek, dan latihan praktik lengkap dibahas terpisah di luar slide ini.
</div>

---

## Apa itu Arsitektur Web?

<div class="term-box">
<b>Arsitektur web:</b> cara lapisan-lapisan aplikasi (antarmuka, logika bisnis, akses data) diorganisasi dan di-deploy &mdash; satu unit, atau banyak unit terpisah.
</div>

- Pilihan arsitektur bukan sekadar teknis &mdash; ia menentukan berapa banyak proses deploy, titik gagal, dan komunikasi jaringan yang harus dikelola tim
- Arsitektur yang "lebih canggih" bukan berarti lebih baik: membangun food court untuk bisnis satu dapur hanya menghabiskan usaha untuk pipa penghubung, bukan fitur
- Tiga gaya yang akan kita bandingkan: **monolith**, **microservices**, **serverless**

---

## Monolith

<div class="term-box">
<b>Monolith:</b> Aplikasi yang seluruh lapisannya &mdash; antarmuka, logika bisnis, akses data &mdash; berjalan dalam satu basis kode dan satu proses deploy.
</div>

- Menambah fitur = menambah kode pada proyek yang sama
- Deploy pembaruan = mengganti satu unit dengan versi baru
- Sering disalahpahami sebagai "kode berantakan"
- Monolith terstruktur (mis. dengan MVC) tetap rapi
- Lawan katanya bukan "modular", melainkan **"terdistribusi"**

---

## Microservices

<div class="term-box">
<b>Microservices:</b> Arsitektur yang memecah aplikasi menjadi layanan independen, masing-masing berjalan dan di-deploy sendiri, saling berkomunikasi lewat jaringan.
</div>

- Setiap layanan: bahasa berbeda, jadwal deploy berbeda, skala sendiri-sendiri
- **Harganya:** 8 layanan = 8 proses deploy + 8 titik gagal + komunikasi jaringan antar-layanan
- Sepadan untuk **tim besar** dengan sistem berskala jutaan pengguna
- Untuk Simple POS: ongkos jauh melebihi manfaatnya

---

## Analogi: Restoran Keluarga vs. Food Court

Dua arsitektur yang baru saja kita definisikan, dalam analogi sehari-hari:

<div class="cols">
<div>

**Restoran keluarga (monolith)**
- Satu dapur, satu kasir, satu tim
- Semua orang tahu semua hal
- Ramai? Tambah kompor, bukan cabang baru

</div>
<div>

**Food court (microservices)**
- Setiap tenant: dapur, kasir, resep sendiri
- Unit-unit independen
- Satu tenant sepi tidak mengganggu yang lain

</div>
</div>

<div class="tip-box">
Simple POS dipilih sebagai <b>monolith</b> (restoran keluarga) bukan karena keterbatasan, tapi karena skalanya cocok: satu warung dengan satu-dua kasir tidak butuh sepuluh layanan terpisah.
</div>

---

## Serverless

<div class="term-box">
<b>Serverless:</b> Kode dieksekusi sebagai fungsi-fungsi kecil yang hanya berjalan saat dipicu peristiwa, tanpa proses server yang menyala terus-menerus.
</div>

- Namanya menyesatkan: server tetap ada, hanya bukan tanggung jawabmu
- Ada jeda **cold start** saat fungsi lama tidak dipanggil
- Biaya dihitung per eksekusi, bukan per jam server menyala
- Cocok: beban kerja naik-turun tajam (mis. proses gambar saat upload)
- Kurang cocok: Simple POS yang butuh koneksi basis data konsisten

---

## Perbandingan Ketiga Arsitektur

| Arsitektur | Deployment | Kompleksitas Awal | Cocok Untuk |
|---|---|---|---|
| **Monolith** | Satu unit | Rendah | Simple POS, MVP, tim kecil |
| **Microservices** | Banyak unit independen | Tinggi | Sistem skala besar, tim besar |
| **Serverless** | Fungsi per event | Sedang | Beban kerja sporadis |

<div class="cols" style="margin-top: 30px;">
<div class="stack">
<div class="box">Antarmuka (UI)</div>
<div class="box">Logika Bisnis</div>
<div class="box">Akses Data</div>
<p style="text-align:center; font-weight:bold;">Monolith</p>
</div>
<div class="stack">
<div class="box">Layanan Produk</div>
<div class="box">Layanan Pembayaran</div>
<div class="box">Layanan Pengguna</div>
<p style="text-align:center; font-weight:bold;">Microservices</p>
</div>
</div>

---

## Mengapa Laravel?

<div class="term-box">
<b>MVC (Model-View-Controller):</b> Model mengurus data, View mengurus tampilan, Controller mengurus alur permintaan di antara keduanya.
</div>

- Satu proyek PHP: routing, autentikasi, ORM, template &mdash; siap pakai
- Dibanding PHP polos: struktur MVC konsisten sejak baris kode pertama
- Dibanding framework microservices-first: tetap produktif untuk tim 1&ndash;2 orang
- Ekosistem paket kuat: **Sanctum** (API), **Excel** (impor/ekspor), **Cashier** (pembayaran)
- Filosofi mirip Django (Python) & Ruby on Rails: *convention over configuration*

---

## Satu Pintu Masuk: `public/index.php`

<div class="cols">
<div>

**PHP polos**
- URL memetakan langsung ke berkas
- `/produk.php` &rarr; menjalankan `produk.php`
- Setiap berkas berpotensi diakses langsung lewat URL

</div>
<div>

**Laravel**
- Semua request masuk lewat satu berkas: `public/index.php`
- Alamat URL didaftarkan di `routes/web.php`
- Berkas lain (Controller, Model) tidak bisa diakses langsung lewat URL

</div>
</div>

<div class="tip-box">
Satu pintu masuk berarti setiap request bisa diproses seragam sebelum sampai ke kode aplikasi &mdash; dasar dari routing, middleware, dan autentikasi terpusat.
</div>

---

## Alur Satu Request Laravel

<div class="flow">
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Router</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Controller</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Model</div>
  <div class="arrow">&rarr;</div>
  <div class="box">View / Response</div>
</div>

<div class="tip-box" style="margin-top:40px;">
Pola alur ini berulang di setiap fitur Simple POS &mdash; dari halaman POS sederhana hingga endpoint REST API, semua mengikuti jalur yang sama.
</div>

---

## Menyiapkan Proyek: Kenapa SQLite?

- Basis data disimpan dalam **satu berkas biasa**
- Tanpa proses server terpisah yang harus dinyalakan & dikonfigurasi
- Migrasi bisa langsung dijalankan di menit pertama
- Simple POS berjalan di atas SQLite bahkan untuk demonstrasi kelas

<div class="warn-box">
Sebelum lanjut, pastikan empat alat berikut sudah terpasang: <code>php -v</code> (8.2+), <code>composer -V</code>, <code>node -v</code>, dan <code>git --version</code>.
</div>

---

## Composer & npm: Manajer Dependensi

<div class="term-box">
<b>Composer:</b> manajer dependensi PHP &mdash; membaca <code>composer.json</code>, mengunduh paket ke <code>vendor/</code>, lalu membuat <code>vendor/autoload.php</code>.
</div>

- Berkat <code>autoload.php</code>, setiap class langsung bisa dipakai &mdash; tidak perlu <code>require</code>/<code>include</code> manual seperti PHP polos
- **npm** adalah rekannya di dunia JavaScript: `package.json` mendaftarkan paket, `node_modules/` menyimpannya &mdash; dipakai Laravel untuk Vite & Tailwind
- Kedua folder (`vendor/`, `node_modules/`) hasil unduhan, tidak pernah di-commit ke Git

---

## `.env` & Lapisan Konfigurasi

<div class="term-box">
<b>.env:</b> berkas konfigurasi yang memisahkan kredensial dan pengaturan lingkungan dari kode sumber.
</div>

- Alur baca konfigurasi: `.env` &rarr; helper `env()` &rarr; `config/*.php` &rarr; helper `config()` yang dipakai kode aplikasi
- App key di dalamnya dipakai untuk mengenkripsi session dan cookie
- Pemisahan ini memungkinkan konfigurasi berbeda per lingkungan (lokal, staging, produksi) tanpa mengubah kode

<div class="warn-box">
Berkas <code>.env</code> menyimpan data sensitif dan tidak boleh ikut di-commit &mdash; <code>.gitignore</code> bawaan Laravel sudah mengecualikannya.
</div>

---

## Artisan & Migrasi

<div class="term-box">
<b>Artisan:</b> CLI bawaan Laravel untuk tugas pengembangan sehari-hari (migrasi, seeding, membuat boilerplate) &mdash; alat bantu develop, bukan bagian dari aplikasi yang dilayani ke pengguna.
</div>

<div class="term-box">
<b>Migrasi:</b> berkas PHP yang mendefinisikan perubahan skema basis data secara terprogram, sehingga skema bisa dibangun ulang secara konsisten di mesin mana pun.
</div>

- Perlakukan migrasi seperti version control untuk skema: perubahan baru = berkas migrasi baru, jangan mengubah migrasi lama yang sudah dijalankan di tempat lain
- Opsi `--seed` mengisi tabel dengan data contoh yang realistis untuk latihan dan demonstrasi

---

## Struktur Folder Laravel = Wujud MVC

| Folder | Peran MVC | Isi |
|---|---|---|
| `routes/web.php` | Controller | Pendaftaran alamat URL |
| `app/Http/Controllers/` | Controller | Kelas pemroses request |
| `database/migrations/` | Model | Definisi skema basis data |
| `resources/views/` | View | Berkas Blade (Pertemuan 3) |
| `vendor/` | &mdash; | Paket Composer, tidak di-commit |

<div class="tip-box">
Struktur ini bukan kebetulan &mdash; ia mewujudkan pola MVC yang sama dengan diagram alur request sebelumnya.
</div>

---

## Rangkuman

- **Monolith** menyatukan seluruh lapisan dalam satu basis kode & satu deploy, cocok untuk skala Simple POS; **microservices** memecahnya dengan ongkos yang sepadan hanya untuk sistem besar; **serverless** cocok untuk beban kerja sporadis

- Laravel dipilih sebagai kerangka kerja Simple POS karena strukturnya konsisten sejak awal (MVC) dan produktif untuk tim kecil; **SQLite** dipilih sebagai basis data karena zero-setup &mdash; satu berkas, tanpa server terpisah

- **Composer**/npm mengelola dependensi; **.env** memisahkan konfigurasi dari kode; **Artisan** & **migrasi** membangun skema basis data secara terprogram

- Struktur folder Laravel mewujudkan pola **MVC**, memisahkan tanggung jawab routing, logika bisnis, dan tampilan secara konsisten

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel &middot; Manual PHP

Kode lengkap: `github.com/dhanifudin/simple-pos`

**Pertemuan berikutnya:** HTTP & Arsitektur MVC
