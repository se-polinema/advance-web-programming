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

Pertemuan 4: **Desain Basis Data, Migrasi, dan Seeding**

Skema, Riwayat Perubahan Skema, dan Kecepatan Query

---

## Yang Akan Kamu Pelajari

1. Menjelaskan konsep **skema** dan relasi antar tabel lewat **foreign key**

2. Memahami **migration** sebagai riwayat perubahan skema yang bisa dijalankan ulang, dan **seeder** untuk mengisi data awal dalam jumlah besar

3. Menjelaskan konsep **index** dan cara memverifikasi dampaknya terhadap kecepatan query

<div class="tip-box">
Slide ini membahas konsep. Merancang skema, menulis migration, dan seeder untuk Simple POS dikerjakan di jobsheet praktikum.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Skema dan Relasi Antar Tabel

---

## Gudang Berkatalog vs Tanpa Katalog

<div class="cols">
<div>

**Gudang dengan katalog kartu**
- Setiap barang ada di rak berlabel
- Katalog mencatat rak mana menyimpan barang apa
- Cari barang: baca katalog, langsung ke rak yang tepat

</div>
<div>

**Gudang tanpa katalog**
- Barang tetap ada di suatu tempat
- Mencari berarti menyusuri rak satu per satu
- Pada gudang besar, ini menyita banyak waktu

</div>
</div>

<div class="tip-box">
Skema tabel basis data adalah tata letak rak itu sendiri; index adalah katalog kartunya. Tanpa index yang tepat, mesin basis data tetap bisa menemukan datanya, hanya saja dengan menyusuri seluruh tabel satu per satu.
</div>

---

## Skema: Rancangan Struktur Tabel

<div class="term-box">
<b>Skema:</b> rancangan struktur tabel, yaitu nama kolom, tipe data, dan batasan (nullable, default, unique) yang berlaku pada setiap barisnya.
</div>

- Skema digambar di atas kertas sebelum satu baris migration pun ditulis
- Setiap kolom punya tipe data (angka, teks, tanggal) dan batasan yang menjaga data tetap valid

---

## Foreign Key: Menjaga Relasi Tetap Konsisten

<div class="term-box">
<b>Foreign Key:</b> kolom pada satu tabel yang menunjuk ke <code>id</code> baris pada tabel lain, menjaga agar sebuah baris tidak pernah menunjuk ke baris induk yang tidak ada.
</div>

<div class="flow">
  <div class="box">authors (satu)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">articles (banyak)</div>
</div>

- Satu `authors` punya banyak `articles`; setiap baris `articles` menyimpan `author_id` yang menunjuk balik ke penulisnya

---

## Contoh Skema: Relasi Satu ke Banyak

| Tabel | Kolom Utama |
|---|---|
| `authors` | `id`, `name` |
| `articles` | `id`, `author_id` (fk), `title`, `published_at` |
| `comments` | `id`, `article_id` (fk), `body` |

- Satu `authors` punya banyak `articles`
- Satu `articles` punya banyak `comments`
- Relasinya cukup lurus untuk digambar di atas kertas sebelum menulis kode

---

## Nilai yang Disimpan, Bukan Dihitung Ulang

- Sebagian kolom sengaja menyimpan nilai pada satu titik waktu, bukan menghitungnya ulang setiap kali dibaca
- Contoh: jumlah komentar saat artikel dipublikasikan, atau harga yang berlaku saat transaksi terjadi
- Nilai itu harus tetap sama persis seperti kondisi saat kejadian itu terjadi, meski data sumbernya berubah kemudian

<div class="tip-box">
Pertemuan validasi & keamanan nanti membahas mengapa nilai seperti ini tetap wajib dihitung ulang di server saat disimpan, bukan sekadar dipercaya dari input.
</div>

---

## Menulis Migration untuk Sebuah Tabel

```php
Schema::create('articles', function (Blueprint $table) {
    $table->id();
    $table->foreignId('author_id')->constrained();
    $table->string('title');
    $table->timestamps();
});
```

- `foreignId('author_id')` membuat kolom `author_id` bertipe unsigned big integer
- `->constrained()` menambahkan foreign key yang menunjuk ke `authors.id` berdasarkan konvensi penamaan Laravel
- Constraint ini menjaga integritas data, tapi belum tentu berarti kolomnya sudah punya index (lihat Bagian 3)

---

<!-- _class: divider -->

# Bagian 2
## Migration dan Seeding

Riwayat perubahan skema, dan mengisi data awal

---

## Migration: Riwayat Skema yang Bisa Dijalankan Ulang

<div class="term-box">
<b>Migration:</b> berkas PHP yang mendeskripsikan perubahan struktur tabel (membuat, mengubah, menghapus kolom) secara terprogram, sehingga skema basis data punya riwayat yang bisa dijalankan ulang di komputer lain.
</div>

<div class="flow">
  <div class="box">Migration 1: buat tabel</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Migration 2: tambah kolom</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Migration 3: tambah index</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Skema saat ini</div>
</div>

<div class="tip-box" style="margin-top:30px;">
Mirip riwayat commit git untuk kode: migration adalah riwayat commit untuk skema basis data, dijalankan berurutan sesuai stempel waktu nama berkasnya.
</div>

---

## Aturan Emas Migration: Jangan Ubah, Tambah Baru

<div class="warn-box">
Kalau skema perlu berubah, buat migration baru, jangan mengedit migration lama yang sudah pernah dijalankan. Migration lama yang diedit setelah dijalankan membuat riwayat skema di komputer lain jadi tidak sinkron dengan riwayat di komputermu.
</div>

- Perlakukan migration seperti version control untuk skema: perubahan baru selalu berarti berkas migration baru

---

## Seeder: Mengisi Data Awal

<div class="term-box">
<b>Seeder:</b> kelas PHP yang mengisi tabel dengan data awal atau data uji, dijalankan lewat <code>db:seed</code> atau sebagai bagian dari <code>migrate:fresh --seed</code>.
</div>

- Berguna untuk data contoh saat pengembangan, dan data uji berskala nyata untuk latihan performa

---

## Seeding Skala Besar: Satu-per-Satu vs Bulk Insert

<div class="cols">
<div>

**`Model::create()` di dalam loop**
- Satu query `INSERT` per baris
- Overhead: membentuk objek Eloquent, memicu event model
- Lambat untuk ratusan atau ribuan baris

</div>
<div>

**`DB::table()->insert()` dalam batch**
- Satu pernyataan `INSERT` untuk banyak baris sekaligus
- Jauh lebih sedikit round-trip ke basis data
- `array_chunk()` membagi batch karena sebagian mesin basis data membatasi jumlah baris per `INSERT`

</div>
</div>

```php
$articles = [];
foreach ($authorIds as $authorId) {
    for ($i = 0; $i < 30; $i++) {
        $articles[] = [
            'author_id' => $authorId,
            'title' => fake()->sentence(),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }
}

foreach (array_chunk($articles, 50) as $chunk) {
    DB::table('articles')->insert($chunk);
}
```

---

## Konsistensi Antar Tabel: `DB::transaction()`

<div class="warn-box">
Saat satu operasi menyentuh lebih dari satu tabel yang harus konsisten satu sama lain (mis. menyimpan sebuah pesanan beserta baris-baris itemnya), bungkus dalam satu <code>DB::transaction(function () { ... })</code>. Kalau prosesnya gagal di tengah jalan, seluruh perubahan di dalam blok itu dibatalkan bersama, sehingga data tidak pernah berakhir setengah tersimpan.
</div>

---

<!-- _class: divider -->

# Bagian 3
## Index dan Kecepatan Query

Membuktikan dampaknya dengan EXPLAIN QUERY PLAN

---

## Index: Struktur Data untuk Pencarian Cepat

<div class="term-box">
<b>Index:</b> struktur data tambahan yang dibangun mesin basis data di atas satu atau beberapa kolom, mempercepat pencarian baris pada kolom itu tanpa harus memindai seluruh tabel.
</div>

<div class="cols">
<div>

**Tanpa index (SCAN)**
- Mesin basis data memeriksa tiap baris satu per satu
- Waktu bertambah linear seiring tabel bertumbuh

</div>
<div>

**Dengan index (SEARCH)**
- Mesin basis data melompat langsung ke baris yang relevan
- Hampir tidak terpengaruh ukuran tabel

</div>
</div>

---

## `constrained()` Tidak Selalu Berarti Ada Index

- Di beberapa mesin basis data (mis. MySQL), `foreignId()->constrained()` otomatis membuat index sebagai efek samping
- Di SQLite, `constrained()` hanya menambahkan foreign key constraint, bukan index
- Constraint menjaga integritas data (menolak insert yang menunjuk ke baris tak ada), tapi tidak mempercepat pencarian

---

## Membuktikan dengan `EXPLAIN QUERY PLAN`

- `EXPLAIN QUERY PLAN`: perintah SQLite yang menampilkan strategi mesin basis data untuk menjalankan sebuah query, tanpa benar-benar menjalankannya

```bash
sqlite3 database/database.sqlite \
  "EXPLAIN QUERY PLAN SELECT * FROM articles WHERE author_id = 3;"
```

- **Sebelum index**: hasilnya memuat `SCAN articles`
- **Sesudah index ditambahkan**: hasilnya berubah menjadi `SEARCH articles USING INDEX articles_author_id_index`

<div class="tip-box">
Kalau perintah <code>sqlite3</code> tidak dikenali, jalur alternatifnya lewat <code>php artisan tinker</code> memakai <code>DB::select("EXPLAIN QUERY PLAN ...")</code>.
</div>

---

## Index Bukan Optimasi Prematur

<div class="warn-box">
Pada tabel berisi puluhan baris, perbedaan SCAN dan SEARCH nyaris tidak terasa. Pada tabel berisi ribuan baris, SCAN berarti setiap baris ikut diperiksa pada setiap query, dan waktu itu bertambah linear seiring tabel bertumbuh. Index bukan optimasi prematur; ia perbaikan atas bug performa yang sudah nyata begitu data mendekati skala produksi.
</div>

---

## Menerapkan pada Simple POS

- Konsep skema, migration, dan index ini akan kamu terapkan langsung pada studi kasus Simple POS di jobsheet praktikum
- Merancang tabel kategori-produk-transaksi, menulis seeder berskala ratusan-ribuan baris, dan membuktikan index lewat `EXPLAIN QUERY PLAN`

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos</code>, branch <code>chapter-04</code></div>

---

## Rangkuman

- Skema tabel didefinisikan lewat migration; migration adalah riwayat perubahan yang bisa dijalankan ulang di komputer lain, dan aturan emasnya: tambah migration baru, jangan edit yang lama

- Foreign key menjaga integritas relasi satu ke banyak antar tabel; seeder mengisi data awal, dan seeding skala besar memakai `DB::table()->insert()` dalam batch, jauh lebih efisien daripada `Model::create()` satu per satu

- Index mempercepat pencarian pada kolom yang sering difilter; foreign key constraint tidak otomatis berarti ada index, tergantung mesin basis data yang dipakai

- `EXPLAIN QUERY PLAN` membuktikan dampak index secara langsung: dari `SCAN` (memindai semua baris) menjadi `SEARCH` (melompat ke baris yang relevan)

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Migrations, Query Builder, Seeding)

Kode lengkap: `github.com/se-polinema/simple-pos`

**Pertemuan berikutnya:** ORM & Relasi Data
