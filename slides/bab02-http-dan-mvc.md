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

Pertemuan 2: **Protokol HTTP dan Pola MVC**

Siklus Request/Response & Arsitektur Aplikasi Web

---

## Yang Akan Kamu Pelajari

1. Menjelaskan siklus **request/response** HTTP (method, status code, header) dan memetakannya ke potongan kode routing

2. Membandingkan pola **MVC**, **MVVM**, dan **Clean Architecture**, serta menjelaskan bagaimana Laravel mengimplementasikan MVC

3. Mengenali peran **route**, **controller**, dan **middleware** dalam menangani sebuah permintaan web

<div class="tip-box">
Slide ini membahas konsep. Langkah menulis route, controller, dan middleware secara praktis dibahas terpisah di luar slide ini.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Siklus Request/Response HTTP

---

## Analogi Kantor Pos

<div class="cols">
<div>

**Sepucuk surat**
- Masuk lewat loket penerimaan
- Petugas loket membaca alamat & jenis surat
- Diteruskan ke bagian yang tepat
- Petugas loket tidak membuka amplop atau memutuskan isi balasan

</div>
<div>

**Request ke Simple POS**
- Masuk lewat satu pintu
- Disortir berdasarkan alamat & jenisnya
- Diteruskan ke bagian yang tepat untuk diproses
- Penyortir tidak memutuskan isi jawaban

</div>
</div>

<div class="warn-box">
Kalau penyortiran keliru &mdash; mis. permintaan hapus produk diteruskan tanpa memeriksa apakah pengirimnya admin &mdash; aplikasi kehilangan kendali atas siapa yang boleh mengubah apa.
</div>

---

## Anatomi Sebuah Request

<div class="term-box">
<b>Request:</b> permintaan yang dikirim browser ke server, berisi method, alamat (URL), header, dan kadang data (form, JSON).
</div>

<div class="term-box">
<b>Route:</b> aturan yang memetakan satu kombinasi method dan alamat URL ke kode yang akan menanganinya.
</div>

- Setiap request selalu membawa sebuah **method** yang menyatakan maksud permintaan
- Method inilah yang menentukan route mana yang cocok &mdash; bukan alamat URL saja

---

## Method HTTP

| Method | Maksud | Contoh pada Simple POS |
|---|---|---|
| `GET` | Meminta data, **tanpa mengubah** apa pun di server | Menampilkan halaman `/transactions` |
| `POST` | Mengirim data baru | Menyimpan transaksi kasir baru |
| `PATCH` | Mengubah sebagian data yang sudah ada | Memperbarui stok produk |
| `DELETE` | Menghapus data | Menghapus produk dari katalog |

<div class="warn-box">
Aturan ketat: <code>GET</code> tidak boleh mengubah data di server. Melanggar aturan ini membuat perilaku aplikasi sulit ditebak &mdash; mis. me-refresh halaman tanpa sengaja menghapus data.
</div>

---

## Anatomi Sebuah Response

<div class="term-box">
<b>Response:</b> jawaban yang dikirim server kembali ke browser, berisi status code, header, dan isi (HTML, JSON, redirect).
</div>

<div class="flow">
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Server</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Response</div>
</div>

<div class="tip-box" style="margin-top:30px;">
Response selalu membawa <b>status code</b>, angka tiga digit yang menyatakan hasil permintaan secara ringkas &mdash; sebelum satu byte pun dari isinya dibaca.
</div>

---

## Status Code

| Kode | Arti | Contoh pada Simple POS |
|---|---|---|
| 200 | OK | Halaman `/transactions` berhasil ditampilkan |
| 302 | Redirect | Setelah `/pos` disimpan, diarahkan ke halaman detail |
| 404 | Not Found | Membuka `/transactions/9999` untuk ID yang tidak ada |
| 422 | Unprocessable Entity | Form transaksi dikirim dengan stok tidak mencukupi |
| 500 | Server Error | Kesalahan tak tertangani di sisi server |

---

## Pola 302: Kirim-lalu-Redirect

<div class="flow">
  <div class="box">POST /pos</div>
  <div class="arrow">&rarr;</div>
  <div class="box">302 + Location</div>
  <div class="arrow">&rarr;</div>
  <div class="box">GET /transactions/{id}</div>
</div>

<div class="tip-box" style="margin-top:30px;">
Setelah <code>POST /pos</code> berhasil menyimpan transaksi, server tidak langsung mengirim HTML sebagai jawaban &mdash; ia mengirim response 302 berisi header <code>Location</code> yang memerintahkan browser meminta ulang ke alamat lain.
</div>

- Pola ini berulang di hampir setiap fitur tulis-data
- Mencegah pengguna menekan **refresh** dan tanpa sadar mengirim data yang sama dua kali

---

## Header: Metadata di Luar Isi

<div class="term-box">
<b>Header:</b> metadata yang menyertai request maupun response, di luar isi utamanya.
</div>

- `Content-Type` &mdash; memberi tahu format isi: `text/html`, `application/json`, dst.
- `Authorization` &mdash; membawa token untuk permintaan yang butuh identitas pengirim (dibahas lebih dalam saat topik API)

<div class="tip-box">
Header dibaca sebelum isi diproses &mdash; server bisa menolak atau mengarahkan request hanya berdasarkan header, tanpa membuka isinya.
</div>

---

## Melihat HTTP Secara Langsung

- Browser modern menyediakan **DevTools &rarr; tab Network** untuk melihat setiap request-response yang terjadi
- Setiap baris menampilkan: method, alamat, status code, dan waktu respons
- Cara paling langsung membuktikan bahwa "di balik setiap klik ada request HTTP yang nyata"

<div class="tip-box">
Konsep ini akan langsung kamu praktikkan: membuka DevTools dan mengamati request sungguhan dari route yang kamu buat sendiri.
</div>

---

<!-- _class: divider -->

# Bagian 2
## MVC, MVVM, dan Clean Architecture

---

## Masalah yang Dijawab MVC

- Menerima request dan mengirim response saja **belum cukup** untuk menjaga kode tetap rapi begitu aplikasi tumbuh
- Tanpa pemisahan tanggung jawab yang tegas, kode "menyortir permintaan", "mengambil data", dan "menyusun tampilan" bercampur dalam satu berkas
- Pola **MVC** (Model-View-Controller) menjawabnya dengan membagi tiga tanggung jawab secara tegas

---

## Model — View — Controller

<div class="term-box">
<b>MVC:</b> Model mengurus data, View mengurus tampilan, Controller mengurus alur permintaan di antara keduanya.
</div>

<div class="cols">
<div>

**Kembali ke analogi kantor pos**
- Controller = petugas loket yang menyortir
- Model = arsip berisi data sesungguhnya
- View = formulir balasan yang diserahkan ke pengirim

</div>
<div>

**Aturan praktis menaruh kode**
- Menyentuh data &rarr; Model
- Mengatur alur permintaan &rarr; Controller
- Menampilkan &rarr; View

</div>
</div>

<div class="warn-box">
Framework tidak memaksa aturan ini &mdash; query di dalam view tetap bisa jalan. Pola ini adalah disiplin yang dijaga penulis kodenya sendiri.
</div>

---

## MVC di Struktur Folder Laravel

| Folder | Peran MVC |
|---|---|
| `routes/web.php` | Controller &mdash; pendaftaran alamat URL |
| `app/Http/Controllers/` | Controller &mdash; kelas pemroses request |
| `app/Models/` | Model &mdash; representasi data & aturan bisnis |
| `resources/views/` | View &mdash; tampilan yang dilihat pengguna |

<div class="tip-box">
Struktur folder ini bukan kebetulan &mdash; ia mewujudkan pola MVC secara konsisten sejak proyek pertama kali dibuat.
</div>

---

## MVVM

<div class="term-box">
<b>MVVM (Model-View-ViewModel):</b> menyisipkan ViewModel di antara Model dan View; ViewModel menyimpan state tampilan dan otomatis menyinkronkannya ke View lewat binding dua arah.
</div>

- Populer pada aplikasi antarmuka **reaktif** &mdash; tampilan berubah terus-menerus tanpa reload halaman
- Lebih relevan untuk framework frontend (mis. Vue) dibanding aplikasi server-rendered seperti Simple POS saat ini

---

## Clean Architecture

<div class="term-box">
<b>Clean Architecture:</b> mengisolasi aturan bisnis inti (use case) sepenuhnya dari framework yang dipakai, sehingga bisa diuji dan dipindah ke framework lain tanpa disentuh.
</div>

- Manfaat: aturan bisnis bisa diuji dan dipindah tanpa bergantung pada framework
- Ongkos: lapisan abstraksi tambahan yang perlu dirawat

<div class="warn-box">
Untuk aplikasi seskala Simple POS, isolasi seketat ini menambah abstraksi yang belum sepadan manfaatnya &mdash; MVC bawaan Laravel sudah cukup rapi.
</div>

---

## Perbandingan Tiga Pola

| Pola | Pemisahan Utama | Contoh Pemakaian |
|---|---|---|
| **MVC** | Model, View, Controller | Laravel (bawaan) |
| **MVVM** | Model, View, ViewModel | Aplikasi dengan binding dua arah antara tampilan & state |
| **Clean Architecture** | Lapisan use case terisolasi dari framework | Sistem berskala besar dengan banyak aturan bisnis |

---

## Route, Controller, dan Middleware

<div class="term-box">
<b>Controller:</b> class berisi method-method penanganan request, dipanggil oleh route yang cocok.
</div>

<div class="term-box">
<b>Middleware:</b> lapisan yang memeriksa atau mengubah request sebelum sampai ke controller, misalnya memeriksa apakah pengguna sudah login.
</div>

- Route = alamat + method &rarr; kode yang menanganinya
- Middleware berdiri **di antara** router dan controller &mdash; request harus lolos dulu sebelum diproses
- Bagian praktikum akan menulis ketiganya untuk endpoint Simple POS

---

## Rangkuman

- Setiap request HTTP membawa **method** (`GET`/`POST`/`PATCH`/`DELETE`) dan setiap response membawa **status code** tiga digit yang menyatakan hasil sebelum isinya dibaca

- **MVC** memisahkan Model (data & aturan bisnis), View (tampilan), dan Controller (penyortir request); **MVVM** cocok untuk antarmuka reaktif, **Clean Architecture** cocok untuk sistem besar dengan aturan bisnis kompleks

- Laravel memetakan MVC langsung ke `routes/`, `app/Http/Controllers/`, `app/Models/`, dan `resources/views/`

- **Route**, **Controller**, dan **Middleware** bekerja berurutan: request dicocokkan lewat route, disaring middleware, baru diproses controller

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel &middot; Disertasi Fielding (2000) tentang REST

Kode lengkap: `github.com/se-polinema/simple-pos`

**Pertemuan berikutnya:** Frontend & Templating (Blade, Tailwind, Alpine)
