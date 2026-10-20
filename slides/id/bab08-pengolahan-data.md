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

Dari rekap laporan, berkas CSV, sampai pekerjaan berat yang dititipkan ke latar belakang

---

## Yang Akan Kamu Pelajari

1. Menyusun laporan yang merekap data dalam rentang tanggal, dan menghindari jebakan umum saat memfilter tanggal

2. Mengekspor data ke CSV tanpa membebani memori server, dan mengimpor CSV dengan menangani baris yang cacat tanpa menghentikan seluruh proses

3. Mengenali kapan sebuah pekerjaan sebaiknya dititipkan ke **antrean (queue)** alih-alih dikerjakan langsung selama pengguna menunggu

<div class="tip-box">
Slide ini membahas konsep. Menerapkan laporan, ekspor/impor, dan antrean pada Simple POS dikerjakan di jobsheet praktikum.
</div>

---

## Peta Pertemuan: Seperti Dapur Restoran

<div class="flow">
  <div class="box">Data mentah</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Laporan</div>
  <div class="arrow">&rarr;</div>
  <div class="box">CSV keluar / masuk</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Antrean</div>
</div>

<div class="tip-box">
Bayangkan dapur restoran. Bahan mentah masuk (<b>extract</b>), dimasak jadi hidangan (<b>transform</b>), lalu disajikan ke meja (<b>load</b>). Kalau pesanan membludak, dapur tidak menyuruh tamu berdiri di depan kompor: tamu diberi nomor meja, lalu hidangan diantar belakangan. Itulah gambaran besar pertemuan ini.
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
<b>Antrean (Queue):</b> mekanisme menitipkan pekerjaan berat agar dikerjakan di latar belakang oleh proses terpisah, bukan langsung selama request pengguna berlangsung.
</div>

<div class="term-box">
<b>Import/Export:</b> membawa data masuk dari format eksternal (CSV, Excel) ke basis data, atau mengeluarkannya ke format eksternal untuk dibaca di luar aplikasi.
</div>

---

## Daftar vs Laporan: Tumpukan Struk vs Rekap Akhir Bulan

Halaman daftar itu seperti tumpukan struk di laci kasir: semua ada, tapi kamu yang harus menghitungnya sendiri. Halaman laporan itu seperti rekap akhir bulan: sudah dijumlahkan dan siap dibaca. Pertanyaannya lebih sempit tapi lebih berat: "berapa total X pada rentang waktu tertentu".

```php
$totalKata = Article::whereBetween('published_at', [
    $from, $to,
])->sum('word_count');
```

`whereBetween` memfilter baris yang tanggalnya berada di antara dua batas, lalu `sum()` menjumlahkan satu kolom dari hasil filter itu. Penjumlahan dikerjakan oleh database, jadi Laravel tidak perlu memuat ribuan baris ke memori hanya untuk dijumlahkan.

---

## Jebakan Umum: Batas Hari yang Terpotong

<div class="warn-box">
Filter "1 Agustus sampai 31 Agustus" yang ditulis apa adanya berarti "sampai jam 00:00:00 tanggal 31". Seluruh transaksi yang terjadi sepanjang tanggal 31 ikut hilang, seperti toko yang menghitung omzet bulan Agustus tapi berhenti saat baru buka pintu di hari terakhir.
</div>

```php
$from = $request->date('from')->startOfDay();
$to = $request->date('to')->endOfDay();
```

`startOfDay()` mengubah tanggal awal menjadi jam 00:00:00, dan `endOfDay()` mengubah tanggal akhir menjadi jam 23:59:59, supaya seluruh hari terakhir ikut terhitung.

---

## Jebakan Batas Hari, Digambar di Garis Waktu

<svg viewBox="0 0 1000 270" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="17">
<line x1="40" y1="40" x2="300" y2="40" stroke="#dc2626" stroke-width="7"/>
<line x1="300" y1="28" x2="300" y2="52" stroke="#dc2626" stroke-width="5"/>
<text x="40" y="24" fill="#dc2626" font-weight="bold">Tanpa endOfDay(): filter berhenti di 31 Agt 00:00</text>
<rect x="300" y="92" width="400" height="56" fill="#eff6ff"/>
<line x1="40" y1="120" x2="960" y2="120" stroke="#1e293b" stroke-width="3"/>
<line x1="300" y1="104" x2="300" y2="136" stroke="#1e293b" stroke-width="3"/>
<line x1="700" y1="104" x2="700" y2="136" stroke="#1e293b" stroke-width="3"/>
<circle cx="200" cy="120" r="9" fill="#16a34a"/>
<circle cx="380" cy="120" r="9" fill="#dc2626"/>
<circle cx="500" cy="120" r="9" fill="#dc2626"/>
<circle cx="620" cy="120" r="9" fill="#dc2626"/>
<text x="500" y="84" text-anchor="middle" fill="#dc2626" font-size="16">transaksi tanggal 31 ikut hilang</text>
<text x="300" y="164" text-anchor="middle" fill="#64748b" font-size="15">00:00</text>
<text x="700" y="164" text-anchor="middle" fill="#64748b" font-size="15">24:00</text>
<text x="170" y="196" text-anchor="middle" fill="#64748b">30 Agt</text>
<text x="500" y="196" text-anchor="middle" fill="#1d4ed8" font-weight="bold">31 Agt</text>
<text x="830" y="196" text-anchor="middle" fill="#64748b">1 Sep</text>
<line x1="40" y1="224" x2="700" y2="224" stroke="#16a34a" stroke-width="7"/>
<line x1="700" y1="212" x2="700" y2="236" stroke="#16a34a" stroke-width="5"/>
<text x="40" y="256" fill="#16a34a" font-weight="bold">Dengan endOfDay(): filter berhenti di 31 Agt 23:59:59, seluruh hari terhitung</text>
</svg>

---

## Total yang Sudah Tersimpan, Tidak Dihitung Ulang

Pertemuan 6 menegaskan: nilai seperti total transaksi tidak boleh dipercaya kalau datang dari input klien, dan harus dihitung ulang di server saat transaksi dibuat. Begitu nilai itu tersimpan dengan benar, laporan boleh memakainya apa adanya. Ini seperti total di nota yang sudah dicetak: saat rekap, kamu cukup menjumlahkan angka di nota, bukan mengecek ulang tiap item di dalamnya.

```php
// Laporan cukup menjumlahkan kolom yang sudah tersimpan
$totalPenjualan = Transaction::whereBetween('created_at', [$from, $to])
    ->sum('total');
```

<div class="tip-box">
Menghitung ulang total dari baris detail satu per satu, setiap kali laporan dibuka, membebani server tanpa alasan: angkanya sudah benar sejak transaksi itu dibuat.
</div>

---

<!-- _class: divider -->

# Bagian 2
## Ekspor dan Impor CSV

---

## Ember vs Keran: Dua Cara Mengirim Berkas Besar

<svg viewBox="0 0 1000 310" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<text x="40" y="28" font-size="19" font-weight="bold" fill="#1d4ed8">Ember: tampung dulu, kirim belakangan</text>
<text x="40" y="50" font-size="14" fill="#64748b">get() lalu susun satu string besar</text>
<line x1="60" y1="60" x2="60" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="260" x2="460" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="84" x2="460" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="458" y="76" text-anchor="end" font-size="14" fill="#dc2626">batas memori</text>
<polyline points="60,250 160,218 260,172 360,124 436,88" fill="none" stroke="#1d4ed8" stroke-width="5"/>
<circle cx="436" cy="88" r="8" fill="#dc2626"/>
<text x="330" y="108" text-anchor="end" font-weight="bold" fill="#dc2626">memori habis</text>
<text x="260" y="288" text-anchor="middle" font-size="14" fill="#64748b">jumlah baris yang diproses &rarr;</text>
<text transform="rotate(-90 32 160)" x="32" y="160" text-anchor="middle" font-size="14" fill="#64748b">memori server</text>
<text x="540" y="28" font-size="19" font-weight="bold" fill="#16a34a">Keran: alirkan baris demi baris</text>
<text x="540" y="50" font-size="14" fill="#64748b">lazyById() + streamDownload()</text>
<line x1="560" y1="60" x2="560" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="260" x2="960" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="84" x2="960" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="958" y="76" text-anchor="end" font-size="14" fill="#dc2626">batas memori</text>
<polyline points="560,236 660,232 760,237 860,231 936,235" fill="none" stroke="#16a34a" stroke-width="5"/>
<text x="760" y="214" text-anchor="middle" font-weight="bold" fill="#16a34a">tetap datar</text>
<text x="760" y="288" text-anchor="middle" font-size="14" fill="#64748b">jumlah baris yang diproses &rarr;</text>
<text transform="rotate(-90 532 160)" x="532" y="160" text-anchor="middle" font-size="14" fill="#64748b">memori server</text>
</svg>

---

## Ekspor dengan `streamDownload()` dan `lazyById()`

Cara keran: ambil data per potongan kecil, tulis ke output, lalu lupakan.

```php
$articles = Article::with('author')
    ->whereBetween('published_at', [$from, $to]);

return response()->streamDownload(function () use ($articles) {
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Judul', 'Penulis', 'Tanggal']);
    foreach ($articles->lazyById() as $a) {
        fputcsv($out, [$a->title, $a->author->name, $a->published_at]);
    }
    fclose($out);
}, 'laporan-artikel.csv');
```

`lazyById()` membaca database per potongan, dan `streamDownload()` mengirim tiap baris sambil jalan, jadi memori tetap datar.

<div class="ref-link">Laravel docs: <code>HTTP Responses &rarr; File Downloads</code> dan <code>Eloquent &rarr; Chunking / lazyById()</code></div>

---

## Impor: Seperti Kasir yang Memindai Belanjaan

Impor berjalan ke arah sebaliknya: membaca berkas CSV, lalu mengubah tiap barisnya jadi baris baru di database. Bayangkan kasir memindai belanjaan. Kalau satu barcode rusak, kasir menyisihkan barang itu dan terus memindai sisanya, bukan menyuruh semua pelanggan pulang.

<svg viewBox="0 0 1000 285" width="100%" style="display:block;margin:0 auto;max-height:330px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<defs>
<marker id="g1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
<marker id="g2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="g3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#dc2626"/></marker>
</defs>
<text x="40" y="28" font-size="14" fill="#64748b">berkas CSV: name, category_id, price</text>
<rect x="40" y="44" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="69" font-family="monospace" font-size="15">Kopi Hitam,1,15000</text>
<rect x="40" y="94" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="119" font-family="monospace" font-size="15">Teh Manis,1,10000</text>
<rect x="40" y="144" width="260" height="38" rx="5" fill="#fef2f2" stroke="#dc2626" stroke-width="2"/>
<text x="56" y="169" font-family="monospace" font-size="15">Tanpa Kategori,999,5000</text>
<line x1="304" y1="113" x2="376" y2="113" stroke="#64748b" stroke-width="3" marker-end="url(#g1)"/>
<rect x="380" y="53" width="170" height="120" rx="10" fill="#1d4ed8"/>
<text x="465" y="108" text-anchor="middle" fill="#fff" font-size="21" font-weight="bold">Validator</text>
<text x="465" y="134" text-anchor="middle" fill="#bfdbfe" font-size="15">cek tiap baris</text>
<line x1="554" y1="90" x2="676" y2="78" stroke="#16a34a" stroke-width="3" marker-end="url(#g2)"/>
<line x1="554" y1="140" x2="676" y2="198" stroke="#dc2626" stroke-width="3" marker-end="url(#g3)"/>
<rect x="700" y="50" width="130" height="70" fill="#dcfce7"/>
<ellipse cx="765" cy="120" rx="65" ry="14" fill="#dcfce7" stroke="#16a34a" stroke-width="2.5"/>
<line x1="700" y1="50" x2="700" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<line x1="830" y1="50" x2="830" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<ellipse cx="765" cy="50" rx="65" ry="14" fill="#bbf7d0" stroke="#16a34a" stroke-width="2.5"/>
<text x="765" y="92" text-anchor="middle" font-weight="bold" fill="#166534">database</text>
<text x="860" y="90" font-weight="bold" fill="#16a34a" font-size="18">2 tersimpan</text>
<path d="M690 186 L690 236 L850 236 L850 186" fill="#fef2f2" stroke="#dc2626" stroke-width="3.5"/>
<text x="770" y="218" text-anchor="middle" fill="#dc2626" font-weight="bold">dilewati</text>
<text x="870" y="218" font-weight="bold" fill="#dc2626" font-size="18">1 dilewati</text>
<text x="500" y="272" text-anchor="middle" font-size="14" fill="#64748b">satu baris cacat tidak menghentikan baris lain</text>
</svg>

---

## Impor: Validasi Tiap Baris, Lewati yang Cacat

```php
$rows = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
$rows = array_map('str_getcsv', $rows);
$header = array_shift($rows);

foreach ($rows as $row) {
    $validator = Validator::make(array_combine($header, $row), [
        'title' => ['required', 'string'],
        'author_id' => ['required', 'exists:authors,id'],
    ]);

    if ($validator->fails()) {
        continue; // lewati baris ini, lanjut ke baris berikutnya
    }

    Article::create($validator->validated());
}
```

<div class="warn-box">
CSV dari Excel versi Indonesia sering memakai titik koma (<code>;</code>) sebagai pemisah dan menyisipkan karakter tak terlihat (BOM) di awal berkas. Akibatnya header pertama tidak terbaca dan semua baris gagal validasi. Cek header-nya dulu kalau semua baris tiba-tiba ditolak.
</div>

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
Analogi laundry: ada cucian satu kaus, kamu rela menunggu di tempat. Ada cucian satu karung, kamu titip, dapat nota, lalu pulang. Impor puluhan baris itu satu kaus. Impor ribuan baris itu satu karung, dan permintaan HTTP punya batas waktu tunggu.
</div>

---

## Antrean = Laundry Kiloan

<svg viewBox="0 0 1000 400" width="100%" style="display:block;margin:0 auto;max-height:440px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<defs>
<marker id="q1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1e293b"/></marker>
<marker id="q2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="q3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<rect x="70" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="160" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">Browser</text>
<text x="160" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">pelanggan</text>
<rect x="310" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="400" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">Controller</text>
<text x="400" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">kasir laundry</text>
<rect x="550" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="640" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">Tabel jobs</text>
<text x="640" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">rak nota</text>
<rect x="790" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="880" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">Worker</text>
<text x="880" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">petugas cuci</text>
<line x1="160" y1="72" x2="160" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="400" y1="72" x2="400" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="640" y1="72" x2="640" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="880" y1="72" x2="880" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="30" y1="90" x2="30" y2="380" stroke="#64748b" stroke-width="2.5" marker-end="url(#q3)"/>
<text transform="rotate(-90 16 235)" x="16" y="235" text-anchor="middle" font-size="14" fill="#64748b">waktu</text>
<line x1="162" y1="108" x2="396" y2="108" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="280" y="98" text-anchor="middle" font-size="15">POST /import</text>
<line x1="402" y1="150" x2="636" y2="150" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="520" y="140" text-anchor="middle" font-size="15">dispatch(): simpan job</text>
<line x1="398" y1="192" x2="164" y2="192" stroke="#16a34a" stroke-width="2.5" stroke-dasharray="7 5" marker-end="url(#q2)"/>
<text x="280" y="182" text-anchor="middle" font-size="15" fill="#16a34a">respons instan</text>
<rect x="68" y="214" width="184" height="40" rx="6" fill="#f1f5f9" stroke="#94a3b8" stroke-dasharray="5 4"/>
<text x="160" y="239" text-anchor="middle" font-size="14" fill="#475569">pengguna sudah pergi</text>
<text x="520" y="248" text-anchor="middle" font-size="14" font-style="italic" fill="#64748b">... beberapa saat kemudian ...</text>
<line x1="878" y1="290" x2="644" y2="290" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="760" y="280" text-anchor="middle" font-size="15">ambil job berikutnya</text>
<rect x="790" y="314" width="180" height="56" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="880" y="338" text-anchor="middle" font-weight="bold" fill="#1d4ed8" font-size="16">handle()</text>
<text x="880" y="358" text-anchor="middle" font-size="13" fill="#475569">validasi &amp; simpan</text>
</svg>

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

```bash
php artisan make:job ProcessArticleImport
```

```php
ProcessArticleImport::dispatch($csvPath);

return back()->with('success', 'Impor sedang diproses di latar belakang.');
```

Controller hanya menyimpan berkas dan mengirim satu job ke antrean, lalu segera merespons pengguna. Pekerjaan sesungguhnya (loop validasi dan penyimpanan) pindah ke metode `handle()` pada class job itu.

---

## Worker: Petugas yang Mengerjakan Tumpukan Nota

<div class="term-box">
<b>Worker:</b> proses PHP terpisah yang terus berjalan, mengambil job dari tabel <code>jobs</code> satu per satu, lalu menjalankan metode <code>handle()</code>-nya.
</div>

```bash
php artisan queue:work
```

Tanpa worker, job hanya menumpuk di tabel `jobs`. Sama seperti laundry tanpa petugas cuci: nota terus bertambah, tapi tidak ada satu pun cucian yang selesai, karena `dispatch()` hanya menyimpan nota, bukan mencuci.

<div class="warn-box">
Kalau <code>QUEUE_CONNECTION</code> di <code>.env</code> bertuliskan <code>sync</code>, job dikerjakan langsung di tempat dan tidak pernah masuk antrean sungguhan. Itu seperti kasir yang menyuruhmu menunggu sampai cucian kering padahal kamu sudah memegang nota.
</div>

---

## `sync` vs `database`: Siapa yang Menunggu?

<svg viewBox="0 0 1000 250" width="100%" style="display:block;margin:0 auto;max-height:340px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<defs>
<marker id="s1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<text x="20" y="76" font-size="19" font-weight="bold" fill="#dc2626">sync</text>
<rect x="200" y="45" width="600" height="50" rx="6" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
<text x="500" y="76" text-anchor="middle" fill="#991b1b">job dikerjakan di tempat, pengguna menunggu</text>
<line x1="800" y1="95" x2="800" y2="108" stroke="#dc2626" stroke-width="2"/>
<text x="800" y="126" text-anchor="middle" font-size="14" fill="#dc2626">respons baru sampai</text>
<text x="20" y="166" font-size="19" font-weight="bold" fill="#16a34a">database</text>
<rect x="200" y="140" width="76" height="50" rx="6" fill="#dcfce7" stroke="#16a34a" stroke-width="2"/>
<text x="238" y="170" text-anchor="middle" font-size="14" fill="#166534">respons</text>
<text x="238" y="212" text-anchor="middle" font-size="14" fill="#16a34a">pengguna bebas</text>
<rect x="420" y="140" width="380" height="50" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="610" y="171" text-anchor="middle" fill="#1e3a8a">worker mengerjakan job di latar belakang</text>
<line x1="200" y1="232" x2="960" y2="232" stroke="#64748b" stroke-width="2.5" marker-end="url(#s1)"/>
<text x="960" y="222" text-anchor="end" font-size="14" fill="#64748b">waktu</text>
</svg>

---

## Tanda-Tanda Pekerjaan Layak Masuk Antrean

- Durasinya tidak bisa diprediksi di muka, tergantung ukuran data yang diproses
- Hasilnya tidak perlu dilihat pengguna seketika di halaman yang sama
- Melibatkan panggilan ke layanan eksternal yang lambat, misalnya mengirim email atau memanggil API pihak ketiga

<div class="warn-box">
Laporan yang dibuka dan dibaca langsung di halaman biasanya tetap lebih baik dikerjakan langsung, karena pengguna memang menunggu hasilnya saat itu juga. Antrean bukan solusi untuk semua pekerjaan berat, hanya untuk yang tidak butuh hasil instan.
</div>

---

## Kalau Job Gagal: Catatan Komplain Laundry

Cucian yang bermasalah tidak dibuang diam-diam. Job yang gagal dicatat di tabel `failed_jobs` lengkap dengan pesan errornya, dan bisa dicoba ulang setelah masalahnya diperbaiki.

```bash
php artisan queue:failed        # lihat daftar job yang gagal
php artisan queue:retry all     # coba jalankan ulang semuanya
```

```php
class ProcessArticleImport implements ShouldQueue
{
    use Queueable;

    public int $tries = 3; // maksimal 3 kali percobaan
}
```

<div class="tip-box">
Kalau job "sudah jalan tapi hasilnya kosong", cek <code>queue:failed</code> lebih dulu: pesan errornya hampir selalu ada di sana.
</div>

<div class="ref-link">Laravel docs: <code>Queues &rarr; Dealing With Failed Jobs</code></div>

---

## Menerapkan pada Simple POS

Konsep laporan, ekspor/impor CSV, dan antrean ini akan kamu terapkan langsung pada Simple POS di jobsheet praktikum: menyusun laporan penjualan dengan filter tanggal, mengekspor laporan itu ke CSV, membangun impor produk dari CSV, lalu memindahkan impor itu ke job antrean supaya pengguna tidak menunggu di depan browser.

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos-ch08</code></div>

---

## Rangkuman (1/2)

- Laporan merekap data dalam rentang tanggal lewat `whereBetween`, dan agregasinya (`sum()`) sebaiknya dikerjakan oleh database
- `startOfDay()`/`endOfDay()` mencegah hari terakhir terpotong di tengah malam
- Nilai yang sudah tersimpan dengan benar (seperti total transaksi) boleh dipakai apa adanya, tidak perlu dihitung ulang setiap laporan dibuka
- Ekspor CSV memakai `lazyById()` dan `streamDownload()`: seperti keran, bukan ember, sehingga memori tetap datar

---

## Rangkuman (2/2)

- Impor CSV memvalidasi tiap baris dan melewati yang gagal lewat `continue`, bukan menghentikan seluruh proses
- Pekerjaan berdurasi tidak terprediksi atau bervolume besar sebaiknya dititipkan ke job antrean, seperti laundry kiloan: respons instan, pekerjaan menyusul
- Job yang di-dispatch hanya masuk tabel `jobs`, dan baru berjalan setelah worker (`queue:work`) memprosesnya
- Job yang gagal tercatat di `failed_jobs` dan bisa dicoba ulang dengan `queue:retry`

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Queues, File Storage, HTTP Responses)

Kode lengkap: `github.com/se-polinema/simple-pos-ch08`

**Pertemuan berikutnya:** Merancang dan Membangun REST API
