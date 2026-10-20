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

Pertemuan 9: **Pengolahan Data: Import, Export, dan Queue**

Dari pipeline ETL, dataset besar, dan memory, sampai pekerjaan berat yang dititipkan ke background

---

## Yang Akan Kamu Pelajari

1. Menjelaskan pola **ETL** dan **batch processing**, dan memakainya untuk memproses data dalam jumlah besar
2. Menyusun laporan yang merekap data dalam rentang tanggal, dan memilih teknik yang tepat untuk **dataset besar**
3. Memahami kenapa **memory** bisa habis, dan memilih cara membaca data yang hemat memory
4. Memilih format **CSV, Excel, atau PDF** sesuai kebutuhan, dan mengenal library untuk membuatnya
5. Mengenali kapan sebuah pekerjaan sebaiknya dititipkan ke **queue**, dan membuatnya tahan gagal

<div class="tip-box">
Slide ini membahas konsep. Menerapkan laporan, export/import, dan queue pada Simple POS dikerjakan di jobsheet praktikum.
</div>

---

## Peta Pertemuan: Seperti Dapur Restoran

<div class="flow">
  <div class="box">Data mentah</div>
  <div class="arrow">&rarr;</div>
  <div class="box">ETL + Batch</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Laporan</div>
  <div class="arrow">&rarr;</div>
  <div class="box">CSV / Excel / PDF</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Queue</div>
</div>

<div class="tip-box">
Bayangkan dapur restoran. Bahan mentah masuk (<b>extract</b>), dimasak jadi hidangan (<b>transform</b>), lalu disajikan ke meja (<b>load</b>). Kalau pesanan membludak, dapur tidak menyuruh tamu berdiri di depan kompor: tamu diberi nomor meja, lalu hidangan diantar belakangan. Itulah gambaran besar pertemuan ini.
</div>

---

<!-- _class: divider -->

# Bagian 1
## ETL dan Batch Processing

---

## Empat Istilah Dasar

<div class="term-box">
<b>ETL (Extract, Transform, Load):</b> pola umum mengambil data mentah, mengubah bentuknya, lalu menyimpan atau menyajikannya dalam bentuk baru.
</div>

<div class="term-box">
<b>Batch Processing:</b> memproses banyak data sekaligus dalam kelompok, bukan satu per satu.
</div>

<div class="term-box">
<b>Queue:</b> mekanisme menitipkan pekerjaan berat agar dikerjakan di background oleh proses terpisah, bukan langsung selama request pengguna berlangsung.
</div>

<div class="term-box">
<b>Import/Export:</b> membawa data masuk dari format eksternal (CSV, Excel) ke database, atau mengeluarkannya ke format eksternal (CSV, Excel, PDF) untuk dibaca di luar aplikasi.
</div>

---

## ETL: Tiga Tahap yang Selalu Muncul

<svg viewBox="0 0 1000 300" width="100%" style="display:block;margin:0 auto;max-height:340px" font-family="Helvetica Neue, Arial, sans-serif" font-size="20">
<defs><marker id="e1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1d4ed8"/></marker></defs>
<rect x="30" y="40" width="270" height="130" rx="14" fill="#1d4ed8"/>
<text x="165" y="92" text-anchor="middle" fill="#fff" font-size="30" font-weight="bold">Extract</text>
<text x="165" y="132" text-anchor="middle" fill="#bfdbfe" font-size="20">CSV, database, API</text>
<rect x="365" y="40" width="270" height="130" rx="14" fill="#1d4ed8"/>
<text x="500" y="92" text-anchor="middle" fill="#fff" font-size="30" font-weight="bold">Transform</text>
<text x="500" y="132" text-anchor="middle" fill="#bfdbfe" font-size="20">validasi, bersihkan, petakan</text>
<rect x="700" y="40" width="270" height="130" rx="14" fill="#1d4ed8"/>
<text x="835" y="92" text-anchor="middle" fill="#fff" font-size="30" font-weight="bold">Load</text>
<text x="835" y="132" text-anchor="middle" fill="#bfdbfe" font-size="20">database, CSV, Excel, PDF</text>
<line x1="304" y1="105" x2="359" y2="105" stroke="#1d4ed8" stroke-width="4" marker-end="url(#e1)"/>
<line x1="639" y1="105" x2="694" y2="105" stroke="#1d4ed8" stroke-width="4" marker-end="url(#e1)"/>
<text x="165" y="222" text-anchor="middle" fill="#64748b" font-size="22">bahan mentah</text>
<text x="500" y="222" text-anchor="middle" fill="#64748b" font-size="22">dimasak</text>
<text x="835" y="222" text-anchor="middle" fill="#64748b" font-size="22">disajikan</text>
</svg>

Hampir semua pengolahan data mengikuti urutan ini, baik import maupun export. Memisahkan tahapnya membuat tiap bagian mudah diuji dan diganti: sumber datanya boleh berubah, aturan validasinya boleh berubah, tujuannya boleh berubah.

---

## Import dan Export Adalah ETL Dua Arah

| | Extract | Transform | Load |
|---|---|---|---|
| **Import** | baca file CSV / Excel | validasi tiap row, petakan column | simpan ke database |
| **Export** | query database | pilih column, format tanggal dan angka | tulis CSV / Excel / PDF |

<div class="tip-box">
Pertanyaan yang berguna untuk setiap fitur import atau export: dari mana datanya (extract), apa yang harus dibersihkan atau diubah (transform), dan ke mana hasilnya (load)?
</div>

---

## Batch: Satu per Satu vs Satu Truk

Kurir yang mengantar satu paket per perjalanan akan kalah efisien dari kurir yang membawa satu truk penuh. Hal yang sama berlaku untuk database: setiap query punya ongkos perjalanan (round trip) ke database.

```php
// 10.000 row = 10.000 query
foreach ($rows as $row) {
    Article::create($row);
}

// 10.000 row = 20 query (batch 500 row)
foreach (array_chunk($rows, 500) as $batch) {
    Article::insert($batch);
}
```

<div class="warn-box">
<code>insert()</code> massal tidak mengisi <code>created_at</code>/<code>updated_at</code> otomatis dan tidak menjalankan model event. Isi timestamp-nya sendiri kalau dibutuhkan.
</div>

---

## Ukuran Batch dan Membaca per Batch

<div class="cols">
<div>

**Batch terlalu kecil**
- Terlalu banyak round trip
- Lambat, seperti kurir motor

**Batch terlalu besar**
- Memory membengkak
- Satu kegagalan menggagalkan banyak row

</div>
<div>

**Membaca per batch**

```php
Article::where('status', 'draft')
    ->chunkById(500, function ($articles) {
        foreach ($articles as $a) {
            // proses tiap row
        }
    });
```

</div>
</div>

<div class="tip-box">
Titik awal yang wajar: ratusan sampai seribu row per batch, lalu ukur. Bungkus tiap batch dengan <code>DB::transaction()</code> kalau satu batch harus berhasil atau gagal seluruhnya.
</div>

---

## Idempotent: Aman Dijalankan Berkali-kali

Bagaimana kalau file import yang sama di-upload dua kali? Tanpa penjagaan, semua row tercatat dobel. Bayangkan daftar hadir: kalau namamu sudah ada, petugas memperbarui barisnya, bukan menulis nama yang sama lagi.

```php
Article::updateOrCreate(
    ['slug' => $row['slug']],     // kunci pencarian
    ['title' => $row['title']],   // nilai yang diperbarui
);

// versi batch: satu query untuk banyak row
Article::upsert($batch, ['slug'], ['title']);
```

<div class="warn-box">
<code>upsert()</code> mensyaratkan <b>unique index</b> pada column kuncinya. Tanpa itu, database tidak tahu mana row yang dianggap sama.
</div>

---

<!-- _class: divider -->

# Bagian 2
## Laporan dan Dataset Besar

---

## Daftar vs Laporan: Tumpukan Struk vs Rekap Akhir Bulan

Halaman daftar itu seperti tumpukan struk di laci kasir: semua ada, tapi kamu yang harus menghitungnya sendiri. Halaman laporan itu seperti rekap akhir bulan: sudah dijumlahkan dan siap dibaca. Pertanyaannya lebih sempit tapi lebih berat: "berapa total X pada rentang waktu tertentu".

```php
$totalKata = Article::whereBetween('published_at', [
    $from, $to,
])->sum('word_count');
```

`whereBetween` memfilter row yang tanggalnya berada di antara dua batas, lalu `sum()` menjumlahkan satu column dari hasil filter itu.

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

<svg viewBox="0 0 1000 270" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="23">
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
<text x="500" y="84" text-anchor="middle" fill="#dc2626" font-size="22">transaksi tanggal 31 ikut hilang</text>
<text x="300" y="164" text-anchor="middle" fill="#64748b" font-size="21">00:00</text>
<text x="700" y="164" text-anchor="middle" fill="#64748b" font-size="21">24:00</text>
<text x="170" y="196" text-anchor="middle" fill="#64748b">30 Agt</text>
<text x="500" y="196" text-anchor="middle" fill="#1d4ed8" font-weight="bold">31 Agt</text>
<text x="830" y="196" text-anchor="middle" fill="#64748b">1 Sep</text>
<line x1="40" y1="224" x2="700" y2="224" stroke="#16a34a" stroke-width="7"/>
<line x1="700" y1="212" x2="700" y2="236" stroke="#16a34a" stroke-width="5"/>
<text x="40" y="256" fill="#16a34a" font-weight="bold">Dengan endOfDay(): filter berhenti di 31 Agt 23:59:59, seluruh hari terhitung</text>
</svg>

---

## Hitung di Database, Bukan di PHP

Bayangkan menanyakan saldo rekening. Kamu bisa meminta bank mengirim seluruh mutasi lalu menjumlahkannya sendiri, atau cukup meminta bank menyebutkan saldonya. Database adalah banknya.

```php
// berat: semua row dimuat ke memory, dijumlahkan di PHP
$total = Article::all()->sum('word_count');

// ringan: database yang menjumlahkan
$total = Article::sum('word_count');

// rekap per author: 5 author dengan kata terbanyak
Article::selectRaw('author_id, COUNT(*) AS jumlah, SUM(word_count) AS total_kata')
    ->groupBy('author_id')
    ->orderByDesc('total_kata')
    ->limit(5)
    ->get();
```

---

## Total yang Sudah Tersimpan, Tidak Dihitung Ulang

Pertemuan 6 menegaskan: nilai turunan seperti total tidak boleh dipercaya kalau datang dari input klien, dan harus dihitung ulang di server saat data dibuat. Begitu nilai itu tersimpan dengan benar, laporan boleh memakainya apa adanya. Ini seperti total di nota yang sudah dicetak: saat rekap, kamu cukup menjumlahkan angka di nota, bukan mengecek ulang tiap item di dalamnya.

```php
// word_count dihitung sekali saat artikel disimpan
$article->word_count = str_word_count($article->body);

// laporan cukup menjumlahkan column yang sudah tersimpan
$totalKata = Article::whereBetween('published_at', [$from, $to])
    ->sum('word_count');
```

<div class="tip-box">
Menghitung ulang nilai dari data mentah (misalnya menghitung kata dari seluruh isi artikel) setiap kali laporan dibuka membebani server tanpa alasan: angkanya sudah benar sejak artikel itu disimpan.
</div>

---

## Perkakas untuk Dataset Besar

| Teknik | Dipakai saat | Catatan |
|---|---|---|
| `paginate()` | menampilkan daftar ke pengguna | satu halaman per request |
| `chunkById()` | memproses atau meng-update banyak row | memory per chunk, aman saat row berubah |
| `lazyById()` | membaca banyak row seperti `foreach` | memory datar, kode sederhana |
| `cursor()` | membaca satu query panjang | praktis, tapi kurang aman kalau data berubah |
| `select([...])` | hanya butuh sebagian column | tiap model jadi lebih kecil |
| `with()` | memakai relasi di dalam loop | menghindari N+1 query |
| index | filter atau urut pada column tertentu | query tidak scan seluruh tabel |

---

## Index: Daftar Isi untuk Tabel

Filter tanggal pada laporan akan dijalankan terus-menerus. Tanpa index pada column itu, database harus membaca seluruh tabel row demi row, seperti mencari satu kata di kamus dengan membaca halaman demi halaman. Dengan index, database melompat langsung ke halaman yang tepat lewat daftar isi.

```php
Schema::table('articles', function (Blueprint $table) {
    $table->index('published_at');
});
```

```sql
EXPLAIN SELECT * FROM articles WHERE published_at BETWEEN '2026-08-01' AND '2026-08-31';
-- type: ALL    = scan seluruh tabel (lambat)
-- type: range  = memakai index (cepat)
```

<div class="ref-link">Mengingat Pertemuan 4: strategi index dan <code>EXPLAIN</code></div>

---

<!-- _class: divider -->

# Bagian 3
## Memory Management

---

## Kenapa Memory Bisa Habis

PHP punya batas `memory_limit` (umumnya 128 MB). Setiap row yang dimuat Eloquent menjadi sebuah **object model** lengkap dengan atribut dan metadata, jauh lebih besar daripada data mentahnya. Bayangkan meja kerja: `get()` menaruh semua dokumen di atas meja sekaligus. Begitu dokumennya ribuan, mejanya penuh dan pekerjaan berhenti.

<div class="warn-box">
Contoh pengukuran di jobsheet: membaca 52.500 transaksi dengan <code>get()</code> memakai sekitar 96 MB, sedangkan <code>lazyById()</code> hanya sekitar 38 MB. Tambah datanya sedikit lagi, dan <code>get()</code> menabrak <code>memory_limit</code>: error <i>Allowed memory size exhausted</i>.
</div>

---

## `get` vs `chunk` vs `lazy` vs `cursor`

| Cara | Memory | Query | Cocok untuk |
|---|---|---|---|
| `get()` | semua row sekaligus | 1 | data kecil, hasil ditampilkan |
| `chunkById(n)` | n row per giliran | banyak (per chunk) | update massal, proses per batch |
| `lazyById(n)` | n row per giliran | banyak (per chunk) | export, `foreach` biasa |
| `cursor()` | satu row per giliran | 1 | pembacaan sekali jalan, data tidak berubah |

<div class="tip-box">
Aturan praktis: kalau datanya bisa ratusan ribu row atau lebih, jangan <code>get()</code>. Pakai <code>lazyById()</code> untuk membaca dan <code>chunkById()</code> untuk meng-update.
</div>

---

## Ember vs Keran: Dua Cara Mengirim File Besar

<svg viewBox="0 0 1000 310" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="22">
<text x="40" y="28" font-size="23" font-weight="bold" fill="#1d4ed8">Ember: tampung dulu</text>
<text x="40" y="50" font-size="20" fill="#64748b">get() lalu susun satu string besar</text>
<line x1="60" y1="60" x2="60" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="260" x2="460" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="84" x2="460" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="458" y="76" text-anchor="end" font-size="20" fill="#dc2626">batas memori</text>
<polyline points="60,250 160,218 260,172 360,124 436,88" fill="none" stroke="#1d4ed8" stroke-width="5"/>
<circle cx="436" cy="88" r="8" fill="#dc2626"/>
<text x="330" y="108" text-anchor="end" font-weight="bold" fill="#dc2626">memori habis</text>
<text x="260" y="288" text-anchor="middle" font-size="20" fill="#64748b">jumlah row yang diproses &rarr;</text>
<text transform="rotate(-90 32 160)" x="32" y="160" text-anchor="middle" font-size="20" fill="#64748b">memori server</text>
<text x="540" y="28" font-size="23" font-weight="bold" fill="#16a34a">Keran: alirkan per row</text>
<text x="540" y="50" font-size="20" fill="#64748b">lazyById() + streamDownload()</text>
<line x1="560" y1="60" x2="560" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="260" x2="960" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="84" x2="960" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="958" y="76" text-anchor="end" font-size="20" fill="#dc2626">batas memori</text>
<polyline points="560,236 660,232 760,237 860,231 936,235" fill="none" stroke="#16a34a" stroke-width="5"/>
<text x="760" y="214" text-anchor="middle" font-weight="bold" fill="#16a34a">tetap datar</text>
<text x="760" y="288" text-anchor="middle" font-size="20" fill="#64748b">jumlah row yang diproses &rarr;</text>
<text transform="rotate(-90 532 160)" x="532" y="160" text-anchor="middle" font-size="20" fill="#64748b">memori server</text>
</svg>

---

## Export dengan `streamDownload()` dan `lazyById()`

Cara keran: ambil data per chunk kecil, tulis ke output, lalu lupakan.

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

`lazyById()` membaca database per chunk, dan `streamDownload()` mengirim tiap row sambil jalan, jadi memory tetap datar.

<div class="ref-link">Laravel docs: <code>HTTP Responses &rarr; File Downloads</code> dan <code>Eloquent &rarr; Chunking / lazyById()</code></div>

---

## Jangan Menebak, Ukur

```php
gc_collect_cycles();
memory_reset_peak_usage();      // mulai hitung peak dari nol

foreach (Article::lazyById() as $a) {
    // ... pekerjaan ...
}

printf("peak %.1f MB\n", memory_get_peak_usage() / 1048576);
```

- `memory_get_peak_usage()` mencatat titik tertinggi pemakaian memory
- `memory_reset_peak_usage()` (PHP 8.2+) membuat tiap pengukuran berdiri sendiri
- Bandingkan dua cara pada data yang sama, dan catat angkanya

<div class="tip-box">
Optimasi tanpa pengukuran hanyalah tebakan. Angka sebelum dan sesudah membuat keputusan "pakai <code>lazyById()</code>" bisa dipertanggungjawabkan.
</div>

---

## Jebakan `chunk()`: Row yang Terlewat

```php
// BERBAHAYA: filter berdasarkan 'draft', lalu mengubah 'draft' itu sendiri
Article::where('status', 'draft')->chunk(100, function ($articles) {
    foreach ($articles as $a) {
        $a->update(['status' => 'published']);
    }
});
```

Setiap row yang di-update keluar dari filter, sehingga daftar bergeser dan chunk berikutnya melompati sebagian row. Seperti nomor urut di loket: kalau orang yang sudah dilayani langsung pergi, posisi orang di belakangnya ikut bergeser.

<div class="tip-box">
Solusinya <code>chunkById(100, ...)</code>: ia memakai <code>id</code> terakhir sebagai penanda halaman, bukan nomor urut, sehingga aman walau row berubah.
</div>

---

<!-- _class: divider -->

# Bagian 4
## Format dan Library: CSV, Excel, PDF

---

## Memilih Format: CSV, Excel, atau PDF

| | CSV | Excel (.xlsx) | PDF |
|---|---|---|---|
| **Cocok untuk** | data mentah, pertukaran antar sistem | analisis, laporan keuangan | dibaca atau dicetak, tidak diolah lagi |
| **Format** | teks polos | zip berisi XML, ada styling | dokumen tetap |
| **Memory** | sangat hemat (stream) | sedang (library mengurus chunk) | berat (seluruh dokumen di memory) |
| **Library** | PHP bawaan (`fputcsv`) | Laravel Excel | DomPDF |
| **Data besar** | ya | ya (pakai `FromQuery`) | tidak, batasi row |

---

## CSV: Sederhana tapi Penuh Jebakan

- **Delimiter**: Excel versi Indonesia sering memakai titik koma (`;`), bukan koma
- **Quoting**: nilai yang mengandung koma atau baris baru harus diapit tanda kutip (`fputcsv` mengurusnya)
- **Encoding**: file UTF-8 dari Excel sering diawali karakter tak terlihat (**BOM**) yang merusak header pertama
- **Tanpa tipe**: semua nilai berupa teks, validasi tipe tetap tugasmu

<div class="warn-box">
Kalau semua row tiba-tiba ditolak saat import, cek header-nya dulu: delimiter dan BOM adalah tersangka utama.
</div>

---

## Laravel Excel: Export

Library spreadsheet mengurus format `.xlsx` yang rumit. Kamu cukup mendeskripsikan isinya lewat interface kecil (`concern`).

```php
class ArticlesExport implements FromQuery, WithHeadings, WithMapping, ShouldAutoSize
{
    public function query()
    {
        return Article::with('author')->orderBy('id');
    }

    public function headings(): array { return ['Judul', 'Penulis', 'Tanggal']; }

    public function map($article): array
    {
        return [$article->title, $article->author->name, $article->published_at];
    }
}

return Excel::download(new ArticlesExport, 'artikel.xlsx');
```

<div class="ref-link">docs.laravel-excel.com &rarr; Exports</div>

---

## Laravel Excel: Import

```php
class ArticlesImport implements ToModel, WithHeadingRow, WithValidation,
    WithChunkReading, WithBatchInserts
{
    public function model(array $row): Article
    {
        return new Article(['title' => $row['title'], 'author_id' => $row['author_id']]);
    }

    public function rules(): array
    {
        return ['title' => ['required'], 'author_id' => ['exists:authors,id']];
    }

    public function chunkSize(): int { return 1000; }   // baca 1000 row per giliran
    public function batchSize(): int { return 500; }    // insert 500 row per query
}

Excel::import(new ArticlesImport, $request->file('file'));
```

<div class="warn-box">
Secara default, <code>WithValidation</code> menghentikan import pada row cacat pertama. Untuk melewati dan mengumpulkan row cacat, tambahkan <code>SkipsOnFailure</code>.
</div>

---

## PDF dengan DomPDF: HTML Jadi Dokumen

<div class="flow">
  <div class="box">View Blade</div>
  <div class="arrow">&rarr;</div>
  <div class="box">HTML + CSS</div>
  <div class="arrow">&rarr;</div>
  <div class="box">DomPDF</div>
  <div class="arrow">&rarr;</div>
  <div class="box">File PDF</div>
</div>

```php
$pdf = Pdf::loadView('reports.articles', ['articles' => $articles])
    ->setPaper('a4', 'landscape');   // tabel lebar: pakai landscape

return $pdf->download('artikel.pdf');
```

- View-nya Blade biasa, jadi `@foreach`, `{{ }}`, dan CSS dasar langsung dipakai
- `download()` memaksa browser men-download file, `stream()` menampilkannya di browser

<div class="warn-box">
DomPDF hanya mendukung sebagian CSS dan memuat seluruh dokumen di memory. Pakai untuk ringkasan dan tabel kecil, bukan untuk puluhan ribu row: untuk data besar pilih CSV atau Excel.
</div>

---

## Import: Seperti Kasir yang Memindai Belanjaan

Import berjalan ke arah sebaliknya: membaca file CSV, lalu mengubah tiap row-nya jadi row baru di database. Bayangkan kasir memindai belanjaan. Kalau satu barcode rusak, kasir menyisihkan barang itu dan terus memindai sisanya, bukan menyuruh semua pelanggan pulang.

<svg viewBox="0 0 1000 285" width="100%" style="display:block;margin:0 auto;max-height:330px" font-family="Helvetica Neue, Arial, sans-serif" font-size="19">
<defs>
<marker id="g1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
<marker id="g2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="g3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#dc2626"/></marker>
</defs>
<text x="40" y="28" font-size="17" fill="#64748b">file CSV: name, category_id, price</text>
<rect x="40" y="44" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="69" font-family="monospace" font-size="18">Kopi Hitam,1,15000</text>
<rect x="40" y="94" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="119" font-family="monospace" font-size="18">Teh Manis,1,10000</text>
<rect x="40" y="144" width="260" height="38" rx="5" fill="#fef2f2" stroke="#dc2626" stroke-width="2"/>
<text x="56" y="169" font-family="monospace" font-size="18">Tanpa Kategori,999,5000</text>
<line x1="304" y1="113" x2="376" y2="113" stroke="#64748b" stroke-width="3" marker-end="url(#g1)"/>
<rect x="380" y="53" width="170" height="120" rx="10" fill="#1d4ed8"/>
<text x="465" y="108" text-anchor="middle" fill="#fff" font-size="25" font-weight="bold">Validator</text>
<text x="465" y="134" text-anchor="middle" fill="#bfdbfe" font-size="18">cek tiap row</text>
<line x1="554" y1="90" x2="676" y2="78" stroke="#16a34a" stroke-width="3" marker-end="url(#g2)"/>
<line x1="554" y1="140" x2="676" y2="198" stroke="#dc2626" stroke-width="3" marker-end="url(#g3)"/>
<rect x="700" y="50" width="130" height="70" fill="#dcfce7"/>
<ellipse cx="765" cy="120" rx="65" ry="14" fill="#dcfce7" stroke="#16a34a" stroke-width="2.5"/>
<line x1="700" y1="50" x2="700" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<line x1="830" y1="50" x2="830" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<ellipse cx="765" cy="50" rx="65" ry="14" fill="#bbf7d0" stroke="#16a34a" stroke-width="2.5"/>
<text x="765" y="92" text-anchor="middle" font-weight="bold" fill="#166534">database</text>
<text x="860" y="90" font-weight="bold" fill="#16a34a" font-size="22">2 tersimpan</text>
<path d="M690 186 L690 236 L850 236 L850 186" fill="#fef2f2" stroke="#dc2626" stroke-width="3.5"/>
<text x="770" y="218" text-anchor="middle" fill="#dc2626" font-weight="bold">dilewati</text>
<text x="870" y="218" font-weight="bold" fill="#dc2626" font-size="22">1 dilewati</text>
<text x="500" y="272" text-anchor="middle" font-size="17" fill="#64748b">satu row cacat tidak menghentikan row lain</text>
</svg>

---

## Import: Validasi Tiap Row, Lewati yang Cacat

```php
$rows = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
$rows = array_map('str_getcsv', $rows);
$header = array_shift($rows);

foreach ($rows as $row) {
    $data = array_combine($header, $row);

    $validator = Validator::make($data, [
        'slug' => ['required', 'string'],
        'title' => ['required', 'string'],
        'author_id' => ['required', 'exists:authors,id'],
    ]);

    if ($validator->fails()) {
        continue; // lewati row ini, lanjut ke row berikutnya
    }

    Article::updateOrCreate(['slug' => $data['slug']], $validator->validated());
}
```

---

## Apa yang Dilakukan dengan Row Cacat?

| Strategi | Cara kerja | Cocok untuk |
|---|---|---|
| **Skip tanpa jejak** | row cacat dilewati tanpa catatan | hampir tidak pernah: data hilang tanpa ada yang tahu |
| **Skip dan catat** | row cacat dilewati, nomor row dan alasannya disimpan | import umum (disarankan): pengguna bisa memperbaiki file |
| **Abort semua** | satu row cacat membatalkan seluruh import (`DB::transaction`) | data keuangan atau data yang harus utuh |

<div class="tip-box">
Seperti kasir tadi: barang yang barcode-nya rusak disisihkan, <b>dan</b> dicatat di nota "tidak terbaca" supaya pelanggan tahu apa yang perlu diurus.
</div>

---

<!-- _class: divider -->

# Bagian 5
## Queue: Pekerjaan di Background

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

**Lewat Queue (job)**
- Response instan, pekerjaan berjalan di background
- Pengguna tidak menunggu di depan browser
- Cocok untuk pekerjaan berat atau berdurasi tidak pasti

</div>
</div>

<div class="tip-box">
Analogi laundry: ada cucian satu kaus, kamu rela menunggu di tempat. Ada cucian satu karung, kamu titip, dapat nota, lalu pulang. Import puluhan row itu satu kaus. Import ribuan row itu satu karung, dan HTTP request punya batas waktu tunggu.
</div>

---

## Queue = Laundry Kiloan

<svg viewBox="0 0 1000 400" width="100%" style="display:block;margin:0 auto;max-height:440px" font-family="Helvetica Neue, Arial, sans-serif" font-size="19">
<defs>
<marker id="q1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1e293b"/></marker>
<marker id="q2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="q3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<rect x="70" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="160" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">Browser</text>
<text x="160" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">pelanggan</text>
<rect x="310" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="400" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">Controller</text>
<text x="400" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">kasir laundry</text>
<rect x="550" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="640" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">Tabel jobs</text>
<text x="640" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">rak nota</text>
<rect x="790" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="880" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">Worker</text>
<text x="880" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">petugas cuci</text>
<line x1="160" y1="72" x2="160" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="400" y1="72" x2="400" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="640" y1="72" x2="640" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="880" y1="72" x2="880" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="30" y1="90" x2="30" y2="380" stroke="#64748b" stroke-width="2.5" marker-end="url(#q3)"/>
<text transform="rotate(-90 16 235)" x="16" y="235" text-anchor="middle" font-size="17" fill="#64748b">waktu</text>
<line x1="162" y1="108" x2="396" y2="108" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="280" y="98" text-anchor="middle" font-size="18">POST /import</text>
<line x1="402" y1="150" x2="636" y2="150" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="520" y="140" text-anchor="middle" font-size="18">dispatch(): simpan job</text>
<line x1="398" y1="192" x2="164" y2="192" stroke="#16a34a" stroke-width="2.5" stroke-dasharray="7 5" marker-end="url(#q2)"/>
<text x="280" y="182" text-anchor="middle" font-size="18" fill="#16a34a">response instan</text>
<rect x="68" y="214" width="184" height="40" rx="6" fill="#f1f5f9" stroke="#94a3b8" stroke-dasharray="5 4"/>
<text x="160" y="239" text-anchor="middle" font-size="17" fill="#475569">pengguna sudah pergi</text>
<text x="520" y="248" text-anchor="middle" font-size="17" font-style="italic" fill="#64748b">... beberapa saat kemudian ...</text>
<line x1="878" y1="290" x2="644" y2="290" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="760" y="280" text-anchor="middle" font-size="18">ambil job berikutnya</text>
<rect x="790" y="314" width="180" height="56" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="880" y="338" text-anchor="middle" font-weight="bold" fill="#1d4ed8" font-size="19">handle()</text>
<text x="880" y="358" text-anchor="middle" font-size="16" fill="#475569">validasi &amp; simpan</text>
</svg>

---

## Perjalanan Sebuah Job

<svg viewBox="0 0 1000 380" width="100%" style="display:block;margin:0 auto;max-height:440px" font-family="Helvetica Neue, Arial, sans-serif" font-size="22">
<defs>
<marker id="l1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1e293b"/></marker>
<marker id="l2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="l3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#dc2626"/></marker>
<marker id="l4" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#ca8a04"/></marker>
</defs>
<rect x="130" y="120" width="160" height="76" rx="12" fill="#1d4ed8"/>
<text x="210" y="168" text-anchor="middle" fill="#fff" font-size="26" font-weight="bold">pending</text>
<rect x="470" y="120" width="160" height="76" rx="12" fill="#1d4ed8"/>
<text x="550" y="168" text-anchor="middle" fill="#fff" font-size="26" font-weight="bold">reserved</text>
<rect x="790" y="20" width="190" height="70" rx="12" fill="#dcfce7" stroke="#16a34a" stroke-width="3"/>
<text x="885" y="64" text-anchor="middle" fill="#166534" font-size="26" font-weight="bold">selesai</text>
<rect x="770" y="226" width="220" height="70" rx="12" fill="#fee2e2" stroke="#dc2626" stroke-width="3"/>
<text x="880" y="270" text-anchor="middle" fill="#991b1b" font-size="24" font-weight="bold">failed_jobs</text>
<rect x="470" y="280" width="160" height="70" rx="12" fill="#fef9c3" stroke="#ca8a04" stroke-width="3"/>
<text x="550" y="324" text-anchor="middle" fill="#854d0e" font-size="26" font-weight="bold">retry</text>
<line x1="12" y1="158" x2="126" y2="158" stroke="#1e293b" stroke-width="3" marker-end="url(#l1)"/>
<text x="12" y="142" font-size="20">dispatch()</text>
<line x1="294" y1="158" x2="466" y2="158" stroke="#1e293b" stroke-width="3" marker-end="url(#l1)"/>
<text x="380" y="144" text-anchor="middle" font-size="20">worker mengambil</text>
<line x1="634" y1="136" x2="786" y2="70" stroke="#16a34a" stroke-width="3" marker-end="url(#l2)"/>
<text x="690" y="96" text-anchor="end" fill="#16a34a" font-size="22">berhasil</text>
<line x1="634" y1="180" x2="766" y2="240" stroke="#dc2626" stroke-width="3" marker-end="url(#l3)"/>
<text x="758" y="268" text-anchor="end" fill="#dc2626" font-size="20">attempt habis</text>
<line x1="550" y1="200" x2="550" y2="276" stroke="#ca8a04" stroke-width="3" marker-end="url(#l4)"/>
<text x="538" y="244" text-anchor="end" fill="#854d0e" font-size="20">gagal, masih ada attempt</text>
<path d="M466 315 L210 315 L210 200" fill="none" stroke="#ca8a04" stroke-width="3" marker-end="url(#l4)"/>
<text x="338" y="302" text-anchor="middle" fill="#854d0e" font-size="20">backoff selesai</text>
<text x="990" y="372" text-anchor="end" font-size="20" fill="#64748b" font-family="monospace">$tries = 3, $backoff = [10, 60]</text>
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

return back()->with('success', 'Import sedang diproses di background.');
```

Controller hanya menyimpan file dan mengirim satu job ke queue, lalu segera memberi response ke pengguna. Pekerjaan sesungguhnya (loop validasi dan penyimpanan) pindah ke metode `handle()` pada class job itu.

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
Worker adalah proses yang hidup lama, jadi ia <b>tidak</b> otomatis memuat kode baru. Setelah mengubah class job, restart worker (di server production: <code>php artisan queue:restart</code>).
</div>

---

## Driver Queue dan Worker di Production

| Driver | Penyimpanan | Cocok untuk |
|---|---|---|
| `sync` | tidak ada: job dijalankan langsung di tempat | development dan testing |
| `database` | tabel `jobs` | proyek kecil sampai menengah, setup paling mudah |
| `redis` | Redis (in-memory) | trafik tinggi, butuh throughput besar |

Di production, `queue:work` harus **terus hidup**. Program seperti **Supervisor** bertugas memantau worker dan menyalakannya kembali kalau mati, ibarat supervisor shift yang memastikan petugas cuci selalu ada di tempat.

<div class="ref-link">Laravel docs: <code>Queues &rarr; Supervisor Configuration</code></div>

---

## `sync` vs `database`: Siapa yang Menunggu?

<svg viewBox="0 0 1000 250" width="100%" style="display:block;margin:0 auto;max-height:340px" font-family="Helvetica Neue, Arial, sans-serif" font-size="19">
<defs>
<marker id="s1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<text x="20" y="76" font-size="23" font-weight="bold" fill="#dc2626">sync</text>
<rect x="200" y="45" width="600" height="50" rx="6" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
<text x="500" y="76" text-anchor="middle" fill="#991b1b">job dikerjakan di tempat, pengguna menunggu</text>
<line x1="800" y1="95" x2="800" y2="108" stroke="#dc2626" stroke-width="2"/>
<text x="800" y="126" text-anchor="middle" font-size="17" fill="#dc2626">response baru sampai</text>
<text x="20" y="166" font-size="23" font-weight="bold" fill="#16a34a">database</text>
<rect x="200" y="140" width="76" height="50" rx="6" fill="#dcfce7" stroke="#16a34a" stroke-width="2"/>
<text x="238" y="170" text-anchor="middle" font-size="17" fill="#166534">response</text>
<text x="238" y="212" text-anchor="middle" font-size="17" fill="#16a34a">pengguna bebas</text>
<rect x="420" y="140" width="380" height="50" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="610" y="171" text-anchor="middle" fill="#1e3a8a">worker mengerjakan job di background</text>
<line x1="200" y1="232" x2="960" y2="232" stroke="#64748b" stroke-width="2.5" marker-end="url(#s1)"/>
<text x="960" y="222" text-anchor="end" font-size="17" fill="#64748b">waktu</text>
</svg>

<div class="warn-box">
Kalau <code>QUEUE_CONNECTION</code> di <code>.env</code> bertuliskan <code>sync</code>, job tidak pernah masuk queue sungguhan. Ini seperti kasir yang menyuruhmu menunggu sampai cucian kering padahal kamu sudah memegang nota.
</div>

---

## Job yang Tahan Gagal

Job berjalan di background, jadi tidak ada pengguna yang melihat error-nya. Karena itu job harus dirancang untuk gagal dengan rapi.

```php
class ProcessArticleImport implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;               // maksimal 3 attempt
    public array $backoff = [10, 60];    // jeda 10 detik, lalu 60 detik
    public int $timeout = 120;           // batalkan kalau lebih dari 120 detik
}
```

```bash
php artisan queue:failed        # lihat daftar job yang gagal
php artisan queue:retry all     # coba jalankan ulang semuanya
php artisan queue:flush         # hapus catatan job gagal
```

<div class="ref-link">Laravel docs: <code>Queues &rarr; Dealing With Failed Jobs</code></div>

---

## Aturan Merancang Job

<div class="cols">
<div>

**Lakukan**
- Rancang job **idempotent**: aman dicoba ulang (`updateOrCreate`)
- Bawa ID atau path file, bukan data besar
- Atur `$tries`, `$backoff`, dan `$timeout`
- Gunakan `->afterCommit()` kalau job bergantung pada data di transaksi database

</div>
<div>

**Hindari**
- Memakai `request()`, session, atau user yang sedang login di dalam `handle()`: di background, semuanya tidak ada
- Menyimpan seluruh isi file di payload job
- Mengandalkan urutan job tanpa dirancang
- Membiarkan job gagal tanpa ada yang memantau

</div>
</div>

---

## Memberi Kabar ke Pengguna

Pengguna yang meng-upload file lalu melihat "sedang diproses" ingin tahu kapan selesai. Pilihannya:

- **Column status** pada tabel import (`pending`, `processing`, `done`, `failed`) yang di-update oleh job, lalu ditampilkan di halaman
- **Notifikasi** (email atau notifikasi di aplikasi) saat job selesai atau gagal
- **Job batch**: `Bus::batch($jobs)->dispatch()` melacak banyak job sekaligus, dan `$batch->progress()` memberi persentase selesai

<div class="ref-link">Laravel docs: <code>Queues &rarr; Job Batching</code></div>

---

## Tanda-Tanda Pekerjaan Layak Masuk Queue

- Durasinya tidak bisa diprediksi di muka, tergantung ukuran data yang diproses
- Hasilnya tidak perlu dilihat pengguna seketika di halaman yang sama
- Melibatkan panggilan ke layanan eksternal yang lambat, misalnya mengirim email atau memanggil API pihak ketiga
- Bisa dicoba ulang dengan aman (idempotent)

<div class="warn-box">
Laporan yang dibuka dan dibaca langsung di halaman biasanya tetap lebih baik dikerjakan langsung, karena pengguna memang menunggu hasilnya saat itu juga. Queue bukan solusi untuk semua pekerjaan berat, hanya untuk yang tidak butuh hasil instan.
</div>

---

## Menerapkan pada Simple POS

Konsep pada pertemuan ini akan kamu terapkan langsung pada Simple POS di jobsheet praktikum:

1. Laporan penjualan dengan filter tanggal, dihitung di database
2. Export laporan ke CSV (streaming), Excel (Laravel Excel), dan PDF (DomPDF)
3. Mengukur memory `get()` vs `lazyById()` pada 50.000 row
4. Import produk dari CSV yang validasi per row dan aman diulang
5. Memindahkan import ke queued job dengan `$tries` dan `backoff`, lalu menelusuri job yang gagal

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos-ch08</code></div>

---

## Rangkuman (1/3): ETL, Batch, dan Dataset Besar

- ETL memisahkan pengolahan data jadi extract, transform, load; import dan export adalah ETL dua arah
- Batch mengurangi round trip ke database (`array_chunk` + `insert`, `chunkById`); ukuran batch perlu diukur
- Import yang baik itu idempotent: `updateOrCreate()` atau `upsert()` (dengan unique index)
- Laporan merekap lewat `whereBetween`, `startOfDay()`/`endOfDay()` mencegah hari terakhir terpotong
- Hitung di database (`sum`, `groupBy`), jangan di PHP; index mempercepat filter

---

## Rangkuman (2/3): Memory dan Format

- Memory habis karena `get()` memuat semua row sebagai object; pakai `lazyById()` untuk membaca dan `chunkById()` untuk meng-update
- `chunk()` bisa melewatkan row kalau column filter ikut di-update: pakai `chunkById()`
- Ukur dengan `memory_get_peak_usage()`, jangan menebak
- CSV untuk data mentah, Excel (Laravel Excel) untuk analisis, PDF (DomPDF) untuk dokumen ringkas
- Row cacat saat import: skip dan catat adalah pilihan umum, abort untuk data yang harus utuh

---

## Rangkuman (3/3): Queue

- Pekerjaan berdurasi tidak terprediksi atau bervolume besar dititipkan ke queue: response instan, pekerjaan menyusul
- `dispatch()` hanya menyimpan job ke tabel `jobs`; worker (`queue:work`) yang menjalankannya
- Job tahan gagal: `$tries`, `$backoff`, `$timeout`, dan tabel `failed_jobs` dengan `queue:retry`
- Rancang job idempotent, bawa ID atau path (bukan data besar), jangan bergantung pada request atau session
- Di production, worker dijaga Supervisor dan di-restart saat deploy

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Queues, File Storage, HTTP Responses, Eloquent Chunking), docs.laravel-excel.com, dan laravel-dompdf

Kode lengkap: `github.com/se-polinema/simple-pos-ch08`

**Pertemuan berikutnya:** Merancang dan Membangun REST API
