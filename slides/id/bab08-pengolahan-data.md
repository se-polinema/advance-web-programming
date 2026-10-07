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
  section.divider h2 {
    color: #fff;
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

Pertemuan 9: **Pengolahan Data: Impor, Ekspor, dan Antrean**

Laporan dengan filter tanggal, ekspor dan impor CSV, dan kapan pekerjaan berat sebaiknya dipindah ke latar belakang

---

## Yang Akan Kamu Pelajari

1. Menyusun laporan yang mengagregasi data dalam rentang tanggal, dan menghindari jebakan umum saat memfilter tanggal

2. Mengekspor data ke CSV tanpa membebani memori server, dan mengimpor CSV dengan menangani baris yang cacat tanpa menghentikan seluruh proses

3. Mengenali kapan sebuah proses sebaiknya dipindah ke **antrean (queue)** alih-alih dijalankan langsung dalam siklus request

<div class="tip-box">
Slide ini membahas konsep. Menerapkan laporan, ekspor/impor, dan antrean pada Simple POS dikerjakan di jobsheet praktikum.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Laporan dan Agregasi Data

---

## Empat Istilah Dasar

<div class="term-box">
<b>ETL (Extract, Transform, Load):</b> pola umum mengambil data mentah, mengubah bentuknya, lalu menyimpan atau menyajikannya dalam bentuk baru.
</div>

<div class="term-box">
<b>Batch Processing:</b> memproses banyak data sekaligus dalam kelompok, bukan satu per satu.
</div>

<div class="term-box">
<b>Antrean (Queue):</b> mekanisme menunda pekerjaan berat agar dijalankan di latar belakang oleh proses terpisah, bukan langsung selama request pengguna berlangsung.
</div>

<div class="term-box">
<b>Import/Export:</b> membawa data masuk dari format eksternal (CSV, Excel) ke basis data, atau mengeluarkannya ke format eksternal untuk dibaca di luar aplikasi.
</div>

---

## Laporan Menjawab Pertanyaan yang Berbeda

Halaman daftar data biasa menjawab "apa saja yang ada": tampilkan semua artikel, semua transaksi, semua pengguna. Halaman laporan menjawab pertanyaan yang lebih sempit tapi lebih berat: "berapa total X pada rentang waktu tertentu".

```php
$articles = Article::whereBetween('published_at', [
    $from, $to,
])->get();

$totalKata = $articles->sum('word_count');
```

`whereBetween` memfilter baris yang tanggalnya berada di antara dua batas, lalu `sum()` menjumlahkan satu kolom dari hasil filter itu. Pola yang sama berlaku untuk menjumlahkan apa pun yang sudah tersimpan per baris.

---

## Jebakan Umum: Batas Hari yang Terpotong

<div class="warn-box">
Filter tanggal "1 Agustus sampai 31 Agustus" yang ditulis apa adanya secara harfiah berarti "sampai jam 00:00:00 tanggal 31", yang justru mengecualikan seluruh transaksi yang terjadi sepanjang tanggal 31 itu sendiri.
</div>

```php
$from = $request->date('from')->startOfDay();
$to = $request->date('to')->endOfDay();
```

`startOfDay()` mengubah tanggal awal menjadi jam 00:00:00, dan `endOfDay()` mengubah tanggal akhir menjadi jam 23:59:59, supaya seluruh hari terakhir ikut terhitung, bukan terpotong di tengah malam.

---

## Agregat yang Sudah Tersimpan, Bukan Dihitung Ulang

Pertemuan 6 menegaskan: nilai seperti total transaksi tidak boleh dipercaya kalau datang langsung dari input klien, dan harus dihitung ulang di server saat transaksi dibuat. Begitu nilai itu tersimpan dengan benar, laporan boleh memakainya apa adanya.

```php
// Laporan cukup menjumlahkan kolom yang sudah tersimpan
$totalPenjualan = $transactions->sum('total');
```

<div class="tip-box">
Menghitung ulang total dari baris detail transaksi satu per satu, setiap kali laporan dibuka, membebani server tanpa alasan: angkanya sudah benar sejak transaksi itu dibuat.
</div>

---

<!-- _class: divider -->

# Bagian 2
## Ekspor dan Impor CSV

---

## Mengekspor Tanpa Membebani Memori

Cara paling sederhana mengekspor CSV adalah mengumpulkan semua baris jadi satu string besar, lalu mengirimkannya sekaligus. Cara itu bekerja untuk puluhan baris, tapi begitu jumlah barisnya mencapai puluhan ribu, seluruh berkas harus muat dulu di memori server sebelum terkirim sama sekali.

```php
return response()->streamDownload(function () {
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Judul', 'Penulis', 'Tanggal']);
    foreach ($articles as $a) {
        fputcsv($out, [$a->title, $a->author->name, $a->published_at]);
    }
    fclose($out);
}, 'laporan-artikel.csv');
```

`streamDownload()` menulis setiap baris langsung ke output stream sambil mengirimkannya ke browser, tanpa menahan seluruh berkas di memori server terlebih dahulu.

---

## Mengimpor: Baris Cacat Tidak Boleh Menghentikan Semuanya

Impor berjalan ke arah sebaliknya: membaca berkas CSV yang diunggah, lalu mengubah tiap barisnya menjadi baris baru di database. Bagian yang rawan bukan baca-tulisnya, melainkan menangani baris cacat tanpa menghentikan seluruh proses gara-gara satu baris bermasalah.

```php
foreach ($rows as $row) {
    $validator = Validator::make($row, [
        'title' => ['required', 'string'],
        'author_id' => ['required', 'exists:authors,id'],
    ]);

    if ($validator->fails()) {
        continue; // lewati baris ini, lanjut ke baris berikutnya
    }

    Article::create($validator->validated());
}
```

---

<!-- _class: divider -->

# Bagian 3
## Kapan Memakai Antrean

---

## Dua Cara Memproses Pekerjaan

<div class="cols">
<div>

**Langsung (dalam request)**
- Pengguna menunggu sampai selesai
- Kalau gagal, pengguna langsung tahu
- Cocok untuk pekerjaan singkat, hasilnya dibutuhkan seketika

</div>
<div>

**Lewat Antrean (job)**
- Respons instan, pekerjaan berjalan di latar belakang
- Pengguna tidak menunggu di depan browser
- Cocok untuk pekerjaan berat atau berdurasi tidak pasti

</div>
</div>

<div class="tip-box">
Impor beberapa puluh baris selesai dalam hitungan detik, cukup dijalankan langsung. Begitu volumenya naik ke ribuan baris, proses yang sama bisa memakan waktu puluhan detik, dan permintaan HTTP punya batas waktu tunggu.
</div>

---

## Tanda-Tanda Proses Layak Dipindah ke Antrean

- Durasinya tidak bisa diprediksi di muka, tergantung ukuran data yang diproses
- Hasilnya tidak perlu dilihat pengguna seketika di halaman yang sama
- Melibatkan panggilan ke layanan eksternal yang lambat, misalnya mengirim email atau memanggil API pihak ketiga

<div class="warn-box">
Laporan yang dibuka dan dibaca langsung di halaman biasanya tetap lebih baik diproses langsung, karena pengguna memang menunggu hasilnya saat itu juga. Antrean bukan solusi untuk semua pekerjaan berat, hanya untuk yang tidak butuh hasil instan.
</div>

---

## Alur Job di Laravel

<div class="flow">
  <div class="box">Controller</div>
  <div class="arrow">&rarr;</div>
  <div class="box">dispatch() job</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Tabel jobs</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Worker (queue:work)</div>
</div>

```php
php artisan make:job ProcessArticleImport
```

```php
ProcessArticleImport::dispatch($csvPath);

return back()->with('success', 'Impor sedang diproses di latar belakang.');
```

Controller hanya menyimpan berkas dan mengirim satu job ke antrean, lalu segera merespons pengguna, tanpa menunggu prosesnya selesai sama sekali. Pekerjaan sesungguhnya (loop validasi dan penyimpanan) dipindah ke metode `handle()` pada class job itu.

---

## Worker: Proses Terpisah yang Menjalankan Job

<div class="term-box">
<b>Worker:</b> proses PHP terpisah yang terus berjalan, mengambil job dari tabel <code>jobs</code> satu per satu, lalu menjalankan metode <code>handle()</code>-nya.
</div>

```bash
php artisan queue:work
```

Tanpa worker yang berjalan, job hanya menumpuk di tabel `jobs` dan tidak pernah diproses, karena dispatch hanya menyimpan job ke antrean, tidak menjalankannya secara langsung.

<div class="warn-box">
Kalau <code>QUEUE_CONNECTION</code> di <code>.env</code> bertuliskan <code>sync</code>, job dijalankan langsung di tempat tanpa pernah masuk antrean sungguhan, menghilangkan seluruh manfaat memindahkannya ke latar belakang.
</div>

---

## Menerapkan pada Simple POS

Konsep laporan, ekspor/impor CSV, dan antrean ini akan kamu terapkan langsung pada Simple POS di jobsheet praktikum: menyusun laporan penjualan dengan filter tanggal, mengekspor laporan itu ke CSV, membangun impor produk dari CSV, lalu memindahkan impor itu ke job antrean supaya pengguna tidak menunggu di depan browser.

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos-ch08</code></div>

---

## Rangkuman (1/2)

- Laporan mengagregasi data dalam rentang tanggal lewat `whereBetween`, dengan `startOfDay()`/`endOfDay()` supaya hari terakhir tidak terpotong di tengah malam
- Nilai yang sudah tersimpan dengan benar (seperti total transaksi) boleh dipakai apa adanya di laporan, tidak perlu dihitung ulang setiap kali laporan dibuka
- Ekspor CSV memakai `streamDownload()` untuk menulis baris langsung ke output tanpa menahan seluruh berkas di memori

---

## Rangkuman (2/2)

- Impor CSV memvalidasi tiap baris satu per satu dan melewati baris yang gagal lewat `continue`, bukan menghentikan seluruh proses
- Proses berdurasi tidak terprediksi atau bervolume besar sebaiknya dipindah ke job antrean, supaya pengguna mendapat respons instan sementara prosesnya berjalan di latar belakang
- Job yang di-dispatch hanya masuk tabel `jobs`, dan baru benar-benar berjalan setelah worker (`queue:work`) memprosesnya

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Queues, File Storage, HTTP Responses)

Kode lengkap: `github.com/se-polinema/simple-pos-ch08`

**Pertemuan berikutnya:** Merancang dan Membangun REST API
