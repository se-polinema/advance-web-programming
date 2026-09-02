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

Pertemuan 2: **Protokol HTTP dan Pola MVC**

Siklus Request/Response & Arsitektur Aplikasi Web

---

## Yang Akan Kamu Pelajari

1. Menjelaskan siklus **request/response** HTTP (method, status code, header) dan memetakannya ke potongan kode routing

2. Membandingkan pola **MVC**, **MVVM**, dan **Clean Architecture**, serta menjelaskan bagaimana Laravel mengimplementasikan MVC

3. Mengenali peran **route**, **controller**, dan **middleware**, termasuk pola routing modern: **route parameter**, **named route**, **route group**, dan **resource routing**

4. Menjelaskan cara mengorganisasi controller: **resource controller**, **single-action controller**, dan prinsip *thin controller*

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
Kalau penyortiran keliru (mis. permintaan hapus produk diteruskan tanpa memeriksa apakah pengirimnya admin), aplikasi kehilangan kendali atas siapa yang boleh mengubah apa.
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
- Method inilah yang menentukan route mana yang cocok, bukan alamat URL saja

---

## Method HTTP

| Method | Maksud | Contoh pada Simple POS |
|---|---|---|
| `GET` | Meminta data, **tanpa mengubah** apa pun di server | Menampilkan halaman `/transactions` |
| `POST` | Mengirim data baru | Menyimpan transaksi kasir baru |
| `PATCH` | Mengubah sebagian data yang sudah ada | Memperbarui stok produk |
| `DELETE` | Menghapus data | Menghapus produk dari katalog |

Method lain yang perlu kamu kenal: **`PUT`** (mengganti seluruh data sekaligus), **`HEAD`** (seperti `GET` tapi hanya meminta header, tanpa isi), **`OPTIONS`** (menanyakan method apa saja yang diizinkan server).

<div class="ref-link">Daftar lengkap method: <code>developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods</code></div>

---

## Aturan Main Method: Aman & Idempoten

<div class="term-box">
<b>Aman (safe):</b> method yang tidak mengubah apa pun di server: <code>GET</code>, <code>HEAD</code>. <b>Idempoten:</b> method yang hasilnya sama meski dikirim berulang: <code>GET</code>, <code>PUT</code>, <code>DELETE</code>; sedangkan <code>POST</code> tidak.
</div>

- Browser & server berasumsi aturan ini dipatuhi: refresh, tombol back, dan cache semuanya bergantung padanya
- `POST` tidak idempoten, inilah alasan pola kirim-lalu-redirect di slide berikutnya diperlukan

<div class="warn-box">
Aturan ketat: <code>GET</code> tidak boleh mengubah data di server. Melanggar aturan ini membuat perilaku aplikasi sulit ditebak, mis. me-refresh halaman tanpa sengaja menghapus data.
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
Response selalu membawa <b>status code</b>, angka tiga digit yang menyatakan hasil permintaan secara ringkas, sebelum satu byte pun dari isinya dibaca.
</div>

---

## Lima Kelas Status Code

Ratusan status code dikelompokkan lewat digit pertamanya: kamu cukup hafal lima kelasnya, bukan setiap kodenya.

| Kelas | Arti | Intinya |
|---|---|---|
| `1xx` | Informational | "Diterima, masih diproses", jarang kamu temui langsung |
| `2xx` | Success | Permintaan berhasil diproses |
| `3xx` | Redirection | Browser diminta pergi ke alamat lain |
| `4xx` | Client Error | Kesalahan di sisi pengirim (alamat salah, data tidak valid) |
| `5xx` | Server Error | Kesalahan di sisi server |

<div class="ref-link">Daftar lengkap: <code>developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status</code></div>

---

## Status Code pada Simple POS

| Kode | Arti | Contoh pada Simple POS |
|---|---|---|
| 200 | OK | Halaman `/transactions` berhasil ditampilkan |
| 302 | Redirect | Setelah `/pos` disimpan, diarahkan ke halaman detail |
| 404 | Not Found | Membuka `/transactions/9999` untuk ID yang tidak ada |
| 422 | Unprocessable Entity | Form transaksi dikirim dengan stok tidak mencukupi |
| 500 | Server Error | Kesalahan tak tertangani di sisi server |

- Perhatikan polanya: 2xx = sukses, 3xx = pindah alamat, 4xx = salah di sisi pengirim, 5xx = salah di sisi server

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
Setelah <code>POST /pos</code> berhasil menyimpan transaksi, server tidak langsung mengirim HTML sebagai jawaban: ia mengirim response 302 berisi header <code>Location</code> yang memerintahkan browser meminta ulang ke alamat lain.
</div>

- Pola ini berulang di hampir setiap fitur tulis-data
- Mencegah pengguna menekan **refresh** dan tanpa sadar mengirim data yang sama dua kali

---

## Header: Metadata di Luar Isi

<div class="term-box">
<b>Header:</b> metadata yang menyertai request maupun response, di luar isi utamanya.
</div>

<div class="cols">
<div>

**Header request** (browser &rarr; server)
- `Content-Type`: format data yang dikirim
- `Accept`: format jawaban yang diinginkan
- `Authorization`: token identitas pengirim
- `Cookie`: data sesi yang dikirim balik

</div>
<div>

**Header response** (server &rarr; browser)
- `Content-Type`: format isi jawaban
- `Location`: alamat tujuan redirect
- `Set-Cookie`: server menitipkan data sesi
- `Cache-Control`: boleh-tidaknya jawaban disimpan

</div>
</div>

<div class="ref-link">Daftar lengkap header: <code>developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers</code></div>

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

## Model, View, dan Controller

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
Framework tidak memaksa aturan ini: query di dalam view tetap bisa jalan. Pola ini adalah disiplin yang dijaga penulis kodenya sendiri.
</div>

---

## MVC di Struktur Folder Laravel

| Folder | Peran MVC |
|---|---|
| `routes/web.php` | Controller: pendaftaran alamat URL |
| `app/Http/Controllers/` | Controller: kelas pemroses request |
| `app/Models/` | Model: representasi data & aturan bisnis |
| `resources/views/` | View: tampilan yang dilihat pengguna |

<div class="tip-box">
Struktur folder ini bukan kebetulan: ia mewujudkan pola MVC secara konsisten sejak proyek pertama kali dibuat.
</div>

---

## MVVM

<div class="term-box">
<b>MVVM (Model-View-ViewModel):</b> menyisipkan ViewModel di antara Model dan View; ViewModel menyimpan state tampilan dan otomatis menyinkronkannya ke View lewat binding dua arah.
</div>

- Populer pada aplikasi antarmuka **reaktif**: tampilan berubah terus-menerus tanpa reload halaman
- Lebih relevan untuk framework frontend (mis. Vue) dibanding aplikasi server-rendered seperti Simple POS saat ini

---

## Clean Architecture

<div class="term-box">
<b>Clean Architecture:</b> mengisolasi aturan bisnis inti (use case) sepenuhnya dari framework yang dipakai, sehingga bisa diuji dan dipindah ke framework lain tanpa disentuh.
</div>

- Manfaat: aturan bisnis bisa diuji dan dipindah tanpa bergantung pada framework
- Ongkos: lapisan abstraksi tambahan yang perlu dirawat

<div class="warn-box">
Untuk aplikasi seskala Simple POS, isolasi seketat ini menambah abstraksi yang belum sepadan manfaatnya. MVC bawaan Laravel sudah cukup rapi.
</div>

---

## Perbandingan Tiga Pola

| Pola | Pemisahan Utama | Contoh Pemakaian |
|---|---|---|
| **MVC** | Model, View, Controller | Laravel (bawaan) |
| **MVVM** | Model, View, ViewModel | Aplikasi dengan binding dua arah antara tampilan & state |
| **Clean Architecture** | Lapisan use case terisolasi dari framework | Sistem berskala besar dengan banyak aturan bisnis |

---

<!-- _class: divider -->

# Bagian 3
## Routing Modern dan Organisasi Controller

Dari alamat URL sampai controller yang rapi

---

## Route, Controller, dan Middleware

<div class="term-box">
<b>Controller:</b> class berisi method-method penanganan request, dipanggil oleh route yang cocok.
</div>

<div class="term-box">
<b>Middleware:</b> lapisan yang memeriksa atau mengubah request sebelum sampai ke controller, misalnya memeriksa apakah pengguna sudah login.
</div>

<div class="flow">
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Route</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Middleware</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Controller</div>
</div>

- Bagian praktikum akan menulis ketiganya untuk endpoint Simple POS

---

## Route Parameter: Alamat yang Dinamis

<div class="term-box">
<b>Route parameter:</b> bagian alamat yang ditulis dalam kurung kurawal, mis. <code>{id}</code>, yang nilainya diisi dari URL sesungguhnya dan diteruskan ke controller.
</div>

```php
Route::get('/transactions/{id}', [TransactionController::class, 'show']);
```

- `/transactions/1`, `/transactions/2`, `/transactions/9999`: satu route melayani semuanya
- Nilai `{id}` diterima method `show` sebagai argumen
- ID yang tidak ada &rarr; **404** (lihat kembali tabel status code di Bagian 1)

---

## Named Route: Alamat Boleh Berubah, Nama Tidak

<div class="term-box">
<b>Named route:</b> label unik yang ditempelkan ke sebuah route lewat <code>-&gt;name()</code>, sehingga bagian lain aplikasi merujuk nama itu, bukan alamat mentahnya.
</div>

```php
Route::get('/pos', [TransactionController::class, 'create'])
    ->name('pos.create');
Route::post('/pos', [TransactionController::class, 'store'])
    ->name('transactions.store');
```

- `GET /pos` dan `POST /pos` adalah **dua route berbeda** meski alamatnya sama, dibedakan oleh method-nya
- Link/redirect ditulis `route('pos.create')`. Alamat berubah dari `/pos` ke `/kasir`? Tidak ada pemanggil yang perlu diedit
- Konvensi penamaan: `sumber.aksi`, contoh `transactions.index`, `transactions.store`, dst.

---

## Route Group: Aturan yang Dibagikan Bersama

<div class="term-box">
<b>Route group:</b> membungkus beberapa route agar berbagi middleware, prefix alamat, atau prefix nama yang sama, ditulis sekali, berlaku untuk semuanya.
</div>

```php
Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])
        ->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])
        ->name('transactions.store');
});
```

<div class="warn-box">
Route baru yang lupa dibungkus group middleware yang benar adalah lubang keamanan yang mudah luput: route hapus kategori yang seharusnya khusus admin bisa diakses siapa pun yang tahu alamatnya. Selalu periksa posisi route baru sebelum menganggapnya selesai.
</div>

---

## Resource Controller: Tujuh Aksi Konvensi

Fitur CRUD apa pun selalu butuh tujuh aksi yang sama. Laravel membakukannya jadi konvensi nama method controller.

<table class="small">
<tr><th>Aksi</th><th>Method</th><th>URL</th><th>Tugas</th></tr>
<tr><td><code>index</code></td><td>GET</td><td><code>/products</code></td><td>Daftar semua produk</td></tr>
<tr><td><code>create</code></td><td>GET</td><td><code>/products/create</code></td><td>Form tambah produk</td></tr>
<tr><td><code>store</code></td><td>POST</td><td><code>/products</code></td><td>Simpan produk baru</td></tr>
<tr><td><code>show</code></td><td>GET</td><td><code>/products/{id}</code></td><td>Detail satu produk</td></tr>
<tr><td><code>edit</code></td><td>GET</td><td><code>/products/{id}/edit</code></td><td>Form ubah produk</td></tr>
<tr><td><code>update</code></td><td>PATCH</td><td><code>/products/{id}</code></td><td>Simpan perubahan</td></tr>
<tr><td><code>destroy</code></td><td>DELETE</td><td><code>/products/{id}</code></td><td>Hapus produk</td></tr>
</table>

---

## `Route::resource`: Tujuh Route, Satu Baris

```php
Route::resource('products', ProductController::class);
```

- Satu baris ini mendaftarkan ke-7 route pada slide sebelumnya sekaligus, lengkap dengan named route (`products.index`, `products.show`, dst.)
- Butuh sebagian saja? `->only(['index', 'show'])`
- Konvensi yang sama di setiap fitur membuat siapa pun di tim langsung tahu di mana sebuah aksi berada

<div class="tip-box">
Perintah <code>php artisan route:list</code> menampilkan tabel seluruh route yang terdaftar (method, URL, nama, dan middleware-nya) tanpa membuka berkas route satu per satu.
</div>

---

## Single-Action Controller

<div class="term-box">
<b>Single-action controller:</b> controller dengan satu method <code>__invoke()</code> untuk satu tugas tunggal, dipakai ketika sebuah aksi tidak masuk akal digabung ke tujuh aksi resource.
</div>

```php
Route::get('/transactions/{id}/receipt', PrintReceiptController::class);
```

- Mencetak struk transaksi bukan `show`, bukan `update`: ia aksi berdiri sendiri
- Route-nya menunjuk class-nya langsung, tanpa nama method
- Tanda kamu membutuhkannya: sebuah aksi terus "dipaksakan" masuk ke method resource yang tidak pas

---

## Prinsip Thin Controller

<div class="term-box">
<b>Thin controller:</b> controller hanya mengurus alur: menerima request, memanggil pihak yang tepat, memilih response. Aturan bisnis tinggal di Model (atau lapisan service), bukan di controller.
</div>

<div class="cols">
<div>

**Controller gemuk (hindari)**
- Hitung total, kurangi stok, validasi, format tampilan: semua di satu method
- Sulit diuji, sulit dipakai ulang

</div>
<div>

**Controller tipis (tujuan)**
- `store` hanya memvalidasi input, menyerahkan perhitungan ke Model, lalu redirect
- Logika stok bisa dipakai ulang dari mana pun

</div>
</div>

<div class="warn-box">
Ingat aturan dari Bagian 2: menyentuh data &rarr; Model, mengatur alur &rarr; Controller. Controller gemuk adalah pelanggaran pelan-pelan terhadap MVC: tiap baris terasa kecil, sampai suatu hari method <code>store</code>-mu 200 baris.
</div>

---

## Rangkuman

- Request membawa **method** (`GET`/`POST`/`PATCH`/`DELETE` + `PUT`/`HEAD`/`OPTIONS`); response membawa **status code** yang terbagi lima kelas (`1xx`&ndash;`5xx`); **header** membawa metadata di kedua arah

- **MVC** memisahkan Model (data), View (tampilan), Controller (alur); **MVVM** untuk antarmuka reaktif; **Clean Architecture** untuk sistem besar. Laravel memetakan MVC langsung ke struktur foldernya

- Routing modern: **route parameter** (`{id}`), **named route** (`->name()`), **route group** (middleware/prefix bersama), dan **`Route::resource`** yang mendaftarkan tujuh aksi sekaligus

- Organisasi controller: **resource controller** untuk CRUD, **single-action controller** untuk aksi tunggal, dan prinsip **thin controller**: alur di controller, aturan bisnis di Model

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel &middot; MDN Web Docs (developer.mozilla.org) &middot; Disertasi Fielding (2000) tentang REST

Kode lengkap: `github.com/se-polinema/simple-pos`

**Pertemuan berikutnya:** Frontend & Templating (Blade, Tailwind, Alpine)
