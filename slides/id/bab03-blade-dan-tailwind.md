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
  .ref-link {
    display: inline-block;
    font-size: 0.62em;
    color: #1d4ed8;
    background: #eff6ff;
    border-left: 4px solid #93c5fd;
    border-radius: 0 6px 6px 0;
    padding: 6px 14px;
    margin-top: 14px;
  }
  .ref-link code {
    background: transparent;
    color: #1d4ed8;
  }
---

<!-- _class: lead -->

# Pemrograman Web Lanjut
## SIB245007 &nbsp;|&nbsp; D-IV Sistem Informasi Bisnis

Pertemuan 3: **Frontend & Templating (Blade, Tailwind, Alpine)**

Ekosistem Frontend, Templating di Server, dan Interaktivitas Ringan

---

## Yang Akan Kamu Pelajari

1. Membandingkan pola **MPA** dan **SPA**, serta menjelaskan posisi Blade dan Alpine.js sebagai pendekatan hibrida

2. Memahami konsep **template engine** dan pendekatan **utility-first CSS**, serta bagaimana keduanya bekerja sama menyusun tampilan halaman

3. Menjelaskan cara **Alpine.js** menambahkan interaktivitas sisi klien tanpa reload halaman, dengan server tetap sebagai sumber kebenaran

<div class="tip-box">
Slide ini membahas konsep. Langkah membangun layout, halaman kasir, dan keranjang belanja dikerjakan di jobsheet praktikum, kali ini secara berkelompok.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Ekosistem Frontend: MPA vs SPA

---

## Etalase Kaca vs Pramuniaga yang Sigap

<div class="cols">
<div>

**Etalase kaca**
- Tidak pernah berubah sampai pemiliknya turun tangan menata ulang
- Pembeli yang ingin tahu sisa stok harus memanggil pramuniaga dan menunggu jawaban

</div>
<div>

**Pramuniaga yang sigap**
- Begitu pembeli mengambil satu barang, ia langsung tahu
- Menghitung ulang total di tempat, siap membatalkan pilihan tanpa pembeli mengulang dari awal

</div>
</div>

<div class="warn-box">
Sebuah halaman yang dibangun murni dengan Blade, tanpa sentuhan JavaScript, berperilaku seperti etalase kaca: tiap kali pengguna menambah satu item ke keranjang, seluruh halaman dimuat ulang. Aplikasi dengan volume interaksi tinggi tidak punya waktu untuk reload puluhan kali dalam satu sesi.
</div>

---

## MPA: Muat Ulang Seluruh Halaman

<div class="term-box">
<b>Multi-page application (MPA):</b> setiap kali pengguna berpindah tautan atau mengirim form, browser membuang HTML lama, meminta yang baru, dan merender dari nol.
</div>

<div class="flow">
  <div class="box">Klik</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">HTML penuh</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Render ulang</div>
</div>

- Sederhana dipahami dan gampang di-debug: setiap request punya jawaban HTML yang lengkap
- Terasa lambat untuk interaksi kecil yang sering berulang, mis. menambah satu produk ke keranjang

---

## SPA: JavaScript Mengambil Alih

<div class="term-box">
<b>Single-page application (SPA):</b> satu halaman HTML dimuat sekali di awal, lalu seluruh perubahan berikutnya ditangani JavaScript di browser lewat request tersembunyi, memperbarui sebagian DOM saja tanpa reload.
</div>

- React, Vue, dan Angular adalah pustaka yang dibangun khusus untuk pola ini
- Cocok untuk interaksi yang sangat sering dan state yang kompleks
- Ongkosnya: kompleksitas build dan state yang tersebar di dua tempat (klien dan server)

---

## Bukan Pilihan Hitam-Putih

<div class="flow">
  <div class="box">MPA murni</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Server-rendered + sedikit JavaScript</div>
  <div class="arrow">&rarr;</div>
  <div class="box">SPA murni</div>
</div>

- Kebanyakan aplikasi nyata berada di tengah, bukan di salah satu ujung
- Ekosistem punya nama untuk titik tengah ini: **Livewire** (Laravel), **Hotwire** (Rails), **htmx**

<div class="tip-box">
Pada pendekatan ini, server tetap jadi sumber kebenaran; JavaScript hanya bertugas mempercepat bagian yang terasa lambat kalau harus reload penuh.
</div>

---

## Perbandingan Tiga Pola

| Pola | Sumber Render | Cocok Untuk |
|---|---|---|
| MPA murni | Server, HTML penuh tiap navigasi | Halaman dengan interaksi jarang, SEO penting |
| SPA murni | Klien, JavaScript merender DOM | Aplikasi dengan interaksi sangat sering, state kompleks |
| Blade + Alpine.js | Server untuk struktur, klien untuk interaksi lokal | Aplikasi dengan halaman umumnya statis, sebagian kecil butuh reaktif |

---

## Kapan Blade + Alpine.js Cukup

- Halaman yang jarang berubah dalam satu sesi kerja (mis. daftar, laporan): render server biasa lewat Blade sudah cukup cepat
- Bagian yang butuh interaktivitas berulang tanpa reload (mis. keranjang belanja): Alpine.js mengisi celah itu
- Tidak perlu memaksa seluruh aplikasi pindah arsitektur hanya demi satu bagian kecil ini

<div class="warn-box">
Memindahkan seluruh aplikasi ke SPA hanya demi satu komponen kecil adalah ongkos arsitektur yang tidak sepadan.
</div>

---

<!-- _class: divider -->

# Bagian 2
## Blade, Tailwind, dan Vite

Merender halaman dari server

---

## Konsep Template Engine: Cetakan + Data &rarr; HTML

<div class="term-box">
<b>Template engine:</b> alat yang menggabungkan sebuah cetakan (template) berisi placeholder dengan data sesungguhnya, menghasilkan dokumen akhir yang siap ditampilkan.
</div>

<div class="flow">
  <div class="box">Template (placeholder)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">+ Data</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Template Engine</div>
  <div class="arrow">&rarr;</div>
  <div class="box">HTML Akhir</div>
</div>

- Contoh sederhana: template `<h1>Halo, {{ $nama }}</h1>` + data `$nama = "Rani"` &rarr; hasil `<h1>Halo, Rani</h1>`
- Konsep yang sama dipakai lintas bahasa: Blade (Laravel/PHP), Jinja (Python), EJS (JavaScript), Twig (PHP)

<div class="tip-box">
Blade adalah salah satu implementasi konsep ini di ekosistem Laravel, bukan konsep itu sendiri.
</div>

---

## Blade: Mesin Templating Laravel

<div class="term-box">
<b>Blade:</b> mesin templating bawaan Laravel yang merender HTML di server, memakai sintaks direktif seperti <code>@if</code> dan <code>@foreach</code> langsung di dalam berkas <code>.blade.php</code>.
</div>

<div class="term-box">
<b>Directive:</b> instruksi Blade yang diawali <code>@</code>, misalnya <code>@extends</code>, <code>@section</code>, dan <code>@yield</code>, dikompilasi Laravel menjadi PHP biasa sebelum dijalankan.
</div>

- Blade bukan bahasa baru, hanya cara ringkas menulis PHP di dalam template

---

## Layout: Kerangka Ditulis Sekali

Hampir setiap halaman aplikasi web berbagi kerangka yang sama: judul tab, menu navigasi, dan area konten yang berubah-ubah. Layout Blade menghindari pengulangan kerangka itu di setiap berkas.

```php
<!-- resources/views/layouts/app.blade.php -->
<!DOCTYPE html>
<html lang="id">
<head>
    <title>@yield('title', 'Nama Aplikasi')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <x-nav />
    <main>@yield('content')</main>
</body>
</html>
```

---

## Halaman Mengisi Lubang Layout

```php
<!-- resources/views/articles/index.blade.php -->
@extends('layouts.app')

@section('title', 'Daftar Artikel')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Daftar Artikel</h1>
    <div class="grid grid-cols-3 gap-4">
        @foreach ($articles as $article)
            <div class="border rounded-md p-3">
                <p class="font-medium">{{ $article->title }}</p>
            </div>
        @endforeach
    </div>
@endsection
```

- Halaman tidak menulis ulang `<html>`, `<head>`, atau menu navigasi

<div class="ref-link">Daftar lengkap directive Blade: <code>laravel.com/docs/blade</code></div>

---

## `{{ }}` dan `{!! !!}`: Menampilkan Data ke HTML

<div class="term-box">
<b>{{ }}:</b> sintaks Blade untuk menampilkan nilai sebuah variabel atau ekspresi PHP ke dalam HTML, otomatis melakukan escaping karakter HTML.
</div>

<div class="term-box">
<b>{!! !!}:</b> sintaks Blade yang juga menampilkan nilai sebuah variabel, tapi tanpa escaping sama sekali; isinya dicetak apa adanya sebagai HTML mentah.
</div>

- Contoh: `{{ $article->title }}` menampilkan judul artikel, otomatis aman dari karakter seperti `<` yang bisa disalahgunakan untuk menyuntikkan markup asing

<div class="warn-box">
Data yang berasal dari input pengguna, termasuk judul artikel yang diketik lewat form, selalu wajib ditampilkan lewat <code>{{ }}</code>, bukan <code>{!! !!}</code>. Sintaks kedua melewati escaping sama sekali dan membuka celah <i>cross-site scripting</i> kalau isinya pernah datang dari input yang tidak dipercaya.
</div>

- Pembahasan tuntas soal keamanan input ada di pertemuan validasi & keamanan

---

## Component: Potongan yang Dipakai Ulang

<div class="term-box">
<b>Component:</b> potongan Blade yang bisa dipakai ulang lintas halaman, misalnya kartu produk atau tombol, didaftarkan sebagai berkas terpisah dan dipanggil lewat tag <code>&lt;x-nama-component&gt;</code>.
</div>

- `<x-nav />` pada layout sebelumnya adalah component
- Kartu artikel dan tombol adalah kandidat component berikutnya

---

## Vite: Build Tool Frontend

<div class="term-box">
<b>Vite:</b> build tool frontend yang dipakai Laravel secara bawaan, menjalankan dev server dengan hot reload lewat <code>npm run dev</code> selama pengembangan, dan menggabungkan (<i>bundle</i>) serta memperkecil ukuran (<i>minify</i>) seluruh CSS & JavaScript jadi berkas produksi lewat <code>npm run build</code>.
</div>

<div class="flow">
  <div class="box">app.css / app.js</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Vite</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Tag lewat @vite</div>
</div>

- `@vite([...])` menggantikan tag `<script>`/`<link>` manual

---

## Tiga Berkas di Balik `@vite`

1. `resources/css/app.css`: baris pertama `@import 'tailwindcss';`, tanpa berkas konfigurasi `tailwind.config.js` terpisah
2. `vite.config.js`: mendaftarkan plugin `laravel()` dan `tailwindcss()`
3. `package.json`: mendaftarkan kedua paket itu sebagai `devDependencies`

<div class="tip-box">
Ketiganya sudah ada di proyekmu sejak Pertemuan 1. Pertemuan ini kamu mulai benar-benar memakainya.
</div>

---

## Dua Terminal: `artisan serve` + `npm run dev`

- Vite berjalan sebagai dev server terpisah dari `php artisan serve`, di terminal kedua
- Yang diharapkan: `VITE vX.X.X ready` diikuti alamat lokal
- Mengedit `app.css` atau berkas Blade langsung terlihat tanpa refresh (hot reload)

<div class="warn-box">
Kalau <code>npm run dev</code> dihentikan, direktif <code>@vite</code> pada halaman yang dimuat ulang akan gagal menemukan dev server dan melempar <code>ViteManifestNotFoundException</code>.
</div>

<div class="tip-box">
<code>composer run dev</code> menjalankan artisan serve, npm run dev, dan proses lain sekaligus dalam satu terminal. Mulailah dengan dua terminal terpisah supaya jelas proses mana yang gagal.
</div>

---

## Tailwind: Utility-First CSS

- Class utility ditempel langsung di elemen, bukan aturan CSS terpisah di berkas lain
- Contoh: `class="bg-slate-900 text-white rounded-md px-4 py-2"` untuk tombol gelap dengan sudut membulat dan padding
- Satu class = satu keputusan gaya kecil, mudah ditebak dan dihapus

<div class="ref-link">Referensi lengkap class utility: <code>tailwindcss.com/docs</code> (jangan dihafalkan, cari saat butuh)</div>

---

<!-- _class: divider -->

# Bagian 3
## Interaktivitas Ringan dengan Alpine.js

Keranjang belanja tanpa reload halaman

---

## Alpine.js: State di Dalam Markup

<div class="term-box">
<b>Alpine.js:</b> pustaka JavaScript ringan yang menambahkan state dan interaktivitas langsung lewat atribut HTML (<code>x-data</code>, <code>x-model</code>, <code>@click</code>), diinstal lewat npm seperti dependensi JavaScript lain.
</div>

- Bukan framework SPA mini, melainkan pelengkap halaman yang sudah dirender Blade
- Elemen apa pun di dalam `x-data`, termasuk elemen anaknya, bisa membaca dan mengubah state lewat atribut Alpine lain

---

## Mekanisme Inti: `x-data`

```html
<div x-data="{ cart: [] }">
  <button @click="cart.push({ id: 1, price: 15000 })">
    Tambah
  </button>
  <span x-text="cart.length"></span> item di keranjang
</div>
```

- `cart` dimulai sebagai array kosong, tombol Tambah mendorong satu objek baru setiap kali diklik
- `x-text="cart.length"` otomatis memperbarui angka, tanpa satu baris kode pun yang memerintahkan DOM untuk refresh
- Alpine mengamati perubahan pada `cart` dan menyinkronkan tampilan sendiri

---

## Atribut Alpine yang Akan Kamu Pakai

| Atribut | Fungsi |
|---|---|
| `x-data` | Mendeklarasikan state lokal |
| `@click` | Menjalankan kode saat elemen diklik |
| `x-text` | Menampilkan nilai reaktif |
| `x-for` | Mengulang elemen untuk setiap item |
| `x-model` | Mengikat input ke state |

<div class="ref-link">Daftar lengkap atribut: <code>alpinejs.dev</code></div>

---

## Instalasi lewat npm, Bukan CDN

```bash
npm install alpinejs
```

```js
// resources/js/app.js
import Alpine from 'alpinejs';

window.Alpine = Alpine;
Alpine.start();
```

- `app.js` sudah dimuat `@vite` di layout, tidak ada tag `<script>` baru yang perlu ditambahkan
- Urutan pemuatan lewat bundler otomatis menghindari masalah yang biasanya diatasi atribut `defer` pada CDN

---

## Pola Interaktivitas: Klik untuk Memperbarui State

<div class="flow">
  <div class="box">Klik item</div>
  <div class="arrow">&rarr;</div>
  <div class="box">addToCart(id, name, price)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">cart berubah</div>
  <div class="arrow">&rarr;</div>
  <div class="box">x-for + x-text update</div>
</div>

- `x-data` membungkus daftar item yang relevan, mendefinisikan `cart`, `addToCart`, dan `subtotal()`
- `subtotal()` memakai `reduce` untuk menjumlahkan harga tiap item

<div class="tip-box" style="margin-top:30px;">
Bukti tidak ada reload: address bar dan favicon tab tidak berkedip seperti biasanya.
</div>

---

## Aturan Emas: Server Menghitung Ulang

<div class="warn-box">
Subtotal yang dihitung Alpine di sisi klien murni untuk tampilan. Setiap kali form dikirim, server menghitung ulang totalnya dari data di basis data, bukan dari angka yang sempat ditampilkan Alpine di browser. Apa pun yang berasal dari browser tetap bisa dimanipulasi sebelum sampai ke server.
</div>

<div class="tip-box">
Aturan praktis: logika kosmetik (menampilkan subtotal, menyorot item baru) aman ditaruh di Alpine. Keputusan bisnis (total final, validitas data) wajib dihitung ulang di server.
</div>

---

## Versi Lengkap: `Alpine.data`

- Objek `x-data` inline cukup untuk belajar mekanismenya
- Pada studi kasus Simple POS yang kamu bangun di jobsheet, keranjang didaftarkan lewat `Alpine.data('posCart', ...)` di `app.js`, lengkap dengan scan SKU, diskon, dan `sessionStorage`
- Konsep yang sama, skala yang berbeda

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos</code>, branch <code>chapter-03</code></div>

---

## Rangkuman

- MPA memuat ulang seluruh halaman tiap navigasi, SPA merender semuanya di klien, Blade + Alpine.js mengambil jalan tengah: server tetap merender struktur, Alpine hanya menambah reaktivitas pada bagian yang butuh

- Layout Blade lewat `@extends`/`@section`/`@yield` menghindari pengulangan kerangka HTML; `@vite` memuat Tailwind CSS dan JavaScript lewat Vite, dengan `npm run dev` memberi hot reload

- Tailwind bekerja lewat class utility yang ditempel di elemen; `{{ }}` melakukan escaping otomatis, `{!! !!}` tidak dan membuka celah XSS

- Alpine.js diinstal lewat npm; `x-data` mendeklarasikan state di markup, `@click` dan `x-text` membaca serta mengubahnya secara reaktif, dan subtotal yang dihitung klien tetap wajib diverifikasi ulang di server

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Blade, Vite) &middot; Tailwind CSS (tailwindcss.com) &middot; Alpine.js (alpinejs.dev)

Kode lengkap: `github.com/se-polinema/simple-pos`

**Pertemuan berikutnya:** Desain Basis Data, Migrasi, dan Seeding
