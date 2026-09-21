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

Pertemuan 5: **Eloquent ORM dan Relasi**

Pemetaan Objek ke Tabel, Relasi Antar Model, dan Query yang Efisien

---

## Yang Akan Kamu Pelajari

1. Menjelaskan konsep **ORM** dan bagaimana Eloquent memetakan class ke tabel basis data

2. Mendefinisikan **relasi** antar model (`hasOne`, `hasMany`, `belongsTo`, `belongsToMany`)

3. Memahami **eager loading** dan cara menghindari masalah **N+1**

4. Menerapkan **paginasi** untuk listing data berskala besar

<div class="tip-box">
Slide ini membahas konsep. Menerapkan relasi, eager loading, dan paginasi pada Simple POS dikerjakan di jobsheet praktikum.
</div>

---

<!-- _class: divider -->

# Bagian 1
## ORM dan Relasi Antar Model

---

## Tanpa Relasi vs Dengan Relasi Eloquent

<div class="cols">
<div>

**Tanpa relasi Eloquent**
- Setiap butuh data terkait, tulis ulang query join secara manual
- Rawan salah ketik nama kolom join, berulang di banyak tempat

</div>
<div>

**Dengan relasi Eloquent**
- Dideklarasikan sekali di model
- Dipakai di mana saja lewat properti atau method, tanpa menulis ulang join

</div>
</div>

<div class="tip-box">
Mirip pohon silsilah keluarga: garis keturunan digambar sekali, lalu siapa pun yang membaca pohon itu langsung tahu hubungannya, tanpa menelusuri dokumen satu per satu.
</div>

---

## Konsep ORM: Memetakan Class ke Tabel

<div class="term-box">
<b>ORM (Object-Relational Mapping):</b> teknik yang memetakan class dalam kode ke tabel di basis data, dan objek ke baris, sehingga operasi basis data ditulis lewat method dan properti object, bukan query SQL mentah.
</div>

<div class="flow">
  <div class="box">Class (Model)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">ORM</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Tabel (baris)</div>
</div>

- Eloquent memakai pola **Active Record**: satu class model merepresentasikan satu tabel, sekaligus menyediakan method untuk query, simpan, dan hapus datanya sendiri

---

## Relasi: Menghubungkan Model

<div class="term-box">
<b>Relasi:</b> metode pada model Eloquent yang mendeskripsikan bagaimana satu tabel terhubung ke tabel lain, dipakai layaknya properti biasa, meskipun sebenarnya menjalankan query di belakang layar.
</div>

```php
class Author extends Model
{
    public function articles(): HasMany
    {
        return $this->hasMany(Article::class);
    }
}

class Article extends Model
{
    public function author(): BelongsTo
    {
        return $this->belongsTo(Author::class);
    }
}
```

<div class="flow">
  <div class="box">authors (satu)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">articles (banyak)</div>
</div>

---

## hasOne: Relasi Satu ke Satu

```php
class Author extends Model
{
    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }
}
```

- Mirip `hasMany`, tapi memastikan hanya ada **satu** baris terkait, bukan banyak
- Contoh: satu penulis punya satu profil, bukan beberapa

---

## belongsToMany: Relasi Banyak ke Banyak

```php
class Article extends Model
{
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class);
    }
}
```

- Satu artikel bisa punya banyak tag, satu tag bisa dipakai banyak artikel
- Butuh tabel pivot di tengah, mis. `article_tag`, memakai konvensi nama: kedua nama model tunggal, urut abjad, dipisah garis bawah

---

## Empat Jenis Relasi: Ringkasan

| Relasi | Arti | Contoh |
|---|---|---|
| `hasOne` | Satu baris induk punya satu baris terkait | Author punya satu Profile |
| `hasMany` | Satu baris induk punya banyak baris terkait | Author punya banyak Article |
| `belongsTo` | Baris ini menunjuk balik ke satu baris induk | Article menunjuk ke satu Author |
| `belongsToMany` | Banyak ke banyak lewat tabel pivot | Article dan Tag saling terhubung |

---

## Nama Metode Relasi Bukan Sekadar Kosmetik

- Nama itu menjadi kunci yang dipakai di tiga tempat berbeda:
  - **Pemanggilan metode** `$author->articles()`: mengembalikan query builder, bisa dirangkai dengan `->where()`, `->orderBy()`, dst.
  - **Akses properti** `$author->articles`: langsung mengembalikan koleksi hasilnya
  - **String di dalam** `with('articles')`: memberi tahu Eloquent relasi mana yang harus dimuat lebih awal

---

<!-- _class: divider -->

# Bagian 2
## Eager Loading dan Masalah N+1

---

## Masalah N+1

<div class="term-box">
<b>Lazy Loading:</b> relasi baru dimuat saat properti itu benar-benar diakses, baris demi baris, sumber utama masalah N+1.
</div>

<div class="term-box">
<b>N+1:</b> pola query bermasalah, satu query untuk daftar utama, ditambah satu query terpisah untuk setiap baris guna memuat relasinya.
</div>

- Menampilkan 15 artikel beserta nama penulisnya, tanpa eager loading: 1 query daftar + 15 query penulis = **16 query**

| Pendekatan | Jumlah Query |
|---|---|
| Lazy loading (tanpa `with()`) | 1 query daftar + N query relasi (N+1) |
| Eager loading (`with('author')`) | 2 query total |

---

## Eager Loading

<div class="term-box">
<b>Eager Loading:</b> teknik memuat relasi di muka lewat <code>with()</code>, dalam jumlah query yang tetap kecil, alih-alih memuatnya satu per satu saat baru dibutuhkan.
</div>

```php
$articles = Article::with('author')
    ->latest()
    ->paginate(15);
```

<div class="tip-box">
Jumlah query lewat eager loading tidak bergantung pada berapa banyak baris ditampilkan, hanya pada berapa lapis relasi yang dimuat. Menampilkan 15 artikel atau 150 artikel dengan <code>with('author')</code> sama-sama memakan 2 query total, bukan 2 dikali jumlah baris.
</div>

---

## Eager Loading Berjenjang: Notasi Titik

```php
$authors = Author::with('articles.comments')->get();
```

- Memuat setiap author, relasi `articles`-nya, **dan** relasi `comments` di dalam tiap article sekaligus
- Tetap dalam jumlah query tetap, tidak bertambah seiring jumlah baris

---

<!-- _class: divider -->

# Bagian 3
## Paginasi untuk Data Berskala Besar

---

## Paginasi

<div class="term-box">
<b>Paginasi:</b> teknik membagi hasil query besar menjadi halaman-halaman kecil, mengembalikan hanya sebagian baris pada satu waktu beserta metadata jumlah halaman.
</div>

```php
public function index()
{
    $articles = Article::with('author')
        ->orderBy('title')
        ->paginate(10);

    return view('articles.index', compact('articles'));
}
```

```php
<!-- resources/views/articles/index.blade.php -->
<div class="mt-4">
    {{ $articles->links() }}
</div>
```

---

## Kapan Pakai Paginasi

<div class="tip-box">
Pakai <code>paginate()</code> setiap kali jumlah baris berpotensi tumbuh tak terbatas seiring waktu, seperti daftar artikel atau riwayat komentar. <code>get()</code> biasa masih cukup untuk daftar yang memang kecil dan tetap kecil, seperti daftar tag pada dropdown filter.
</div>

---

## Membuktikan Paginasi Bekerja

```bash
php artisan tinker
>>> Article::orderBy('title')->paginate(10)->pluck('id');
>>> Article::orderBy('title')->paginate(10, ['*'], 'page', 2)->pluck('id');
```

- Bandingkan hasil kedua perintah
- ID yang tumpang tindih antara halaman 1 dan halaman 2 berarti ada masalah pada `orderBy` atau datanya

---

## Menerapkan pada Simple POS

- Konsep relasi, eager loading, dan paginasi ini akan kamu terapkan langsung pada studi kasus Simple POS di jobsheet praktikum
- Memetakan relasi `Category`-`Product` dan `Transaction`-`TransactionDetail`-`Product`, menghindari N+1 pada listing 2.500 transaksi, dan membuktikan paginasi pada 300 produk

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos-ch05</code></div>

---

## Rangkuman

- Relasi (`hasOne`, `hasMany`, `belongsTo`, `belongsToMany`) dideklarasikan sekali di model, lalu dipakai lewat pemanggilan metode, akses properti, atau string di dalam `with()`

- Lazy loading memicu satu query tambahan per baris per relasi (masalah N+1); eager loading, termasuk notasi titik berjenjang, memuat relasi dalam jumlah query tetap, tidak bergantung jumlah baris

- ORM seperti Eloquent (memakai pola Active Record) memetakan class ke tabel dan objek ke baris, menggantikan query SQL mentah dengan method dan properti object

- `paginate()` membagi listing besar jadi halaman-halaman kecil; halaman berbeda bisa dibuktikan benar-benar berbeda dengan membandingkan ID hasil antar halaman

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Eloquent, Relationships, Pagination)

Kode lengkap: `github.com/se-polinema/simple-pos`

**Pertemuan berikutnya:** Validasi & Keamanan Input
