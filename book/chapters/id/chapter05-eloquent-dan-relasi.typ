#import "/template.typ": *

= Eloquent ORM dan Relasi <ch:eloquent-dan-relasi>

#chapterhero("teal", [Petakan relasi antar model Simple POS, hindari jebakan N+1 query, lalu buktikan paginasi bekerja benar pada data 2.500 transaksi.], [#icon("link")#h(1em)relasi Eloquent], [#icon("layer-group")#h(1em)eager loading], [#icon("tachometer-alt")#h(1em)paginasi skala nyata])

Pohon silsilah keluarga besar biasa digambar dalam satu lembar: nama
kakek-nenek di puncak, garis turun ke anak-anak mereka, garis turun lagi
ke cucu. Siapa pun yang membaca pohon itu langsung tahu siapa anak
siapa tanpa harus menelusuri satu per satu dokumen kelahiran yang
terpisah-pisah. Model Eloquent pada Simple POS bekerja seperti pohon
silsilah itu: `Category` adalah kakek-nenek, `Product`
adalah anak, `Transaction` dan `TransactionDetail`
adalah cucu. Relasi antar model mendeklarasikan garis keturunan itu
sekali di kelas model, dan setelah itu kode di mana pun boleh menanyakan
"siapa produk dari kategori ini" atau "detail apa saja milik transaksi
ini" tanpa menulis ulang query join secara manual setiap kali.

#strong[Yang Akan Kamu Pelajari]

+ memetakan relasi `hasOne`, `hasMany`, `belongsTo`, dan `belongsToMany` ke empat model Simple POS (`Category`, `Product`, `Transaction`, `TransactionDetail`);
+ menggunakan eager loading (`with()`) untuk menghindari masalah N+1 query saat menampilkan daftar transaksi beserta detail dan produknya;
+ menerapkan `paginate()` pada listing 300 produk dan 2.500 transaksi, dan membuktikan bahwa halaman kedua benar-benar mengembalikan baris berbeda dari halaman pertama.

== Relasi Eloquent pada Model Simple POS <sec:eloquent-dan-relasi-1>

#istilahpenting[
/ Relasi: Metode pada model Eloquent yang mendeskripsikan bagaimana satu tabel terhubung ke tabel lain, dipakai layaknya properti biasa (`$product->category`) meskipun sebenarnya menjalankan query di belakang layar.
/ Eager Loading: Teknik memuat relasi di muka lewat `with()`, dalam jumlah query yang tetap kecil, alih-alih memuatnya satu per satu saat baru dibutuhkan.
/ N+1: Pola query bermasalah: satu query untuk daftar utama, ditambah satu query terpisah untuk setiap baris guna memuat relasinya.
/ Lazy Loading: Kebalikan eager loading: relasi baru dimuat saat properti itu benar-benar diakses, baris demi baris, sumber utama masalah N+1.
/ Paginasi: Teknik membagi hasil query besar menjadi halaman-halaman kecil, mengembalikan hanya sebagian baris pada satu waktu beserta metadata jumlah halaman.
]

Keempat model Simple POS terhubung lewat pasangan relasi yang saling
berkebalikan. `Category` punya banyak `Product`
lewat `hasMany`, dan setiap `Product` menunjuk balik
ke satu `Category` lewat `belongsTo`.
`Transaction` punya banyak `TransactionDetail` lewat
`hasMany`, dan setiap `TransactionDetail` menunjuk
balik ke satu `Transaction` sekaligus satu `Product`,
masing-masing lewat `belongsTo`.

#listing(```php
class Category extends Model
{
    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }
}

class TransactionDetail extends Model
{
    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
```)

Nama metode relasi, `products()` pada `Category`, atau
`product()` pada `TransactionDetail`, bukan sekadar
konvensi kosmetik. Nama itu menjadi kunci yang dipakai di mana pun
relasi itu diminta, baik lewat pemanggilan metode
(`$category->products()`) yang mengembalikan query builder, maupun
lewat akses properti (`$category->products`) yang langsung
mengembalikan koleksi hasilnya, dan juga lewat string di dalam
`with('products')` yang akan dibahas di bagian berikutnya.

== Eager Loading dan Masalah N+1 <sec:eloquent-dan-relasi-2>

Bayangkan halaman riwayat transaksi menampilkan 15 transaksi, masing-masing
beserta nama produk yang dibeli. Ditulis tanpa eager loading, Blade akan
mengulang `$transaction->details` untuk tiap transaksi, dan
setiap kali properti itu diakses, Eloquent baru menjalankan query
`SELECT * FROM transaction_details WHERE transaction_id = ?`
saat itu juga, satu query per transaksi. Lalu di dalam loop detail
tersebut, mengakses `$detail->product` memicu satu query lagi
per baris detail. Untuk 15 transaksi dengan rata-rata 3 item, itu berarti
1 query daftar transaksi, ditambah 15 query detail, ditambah sekitar 45
query produk: 61 query total untuk menampilkan satu halaman.

#figure(
  table(
    columns: (1.4fr, 0.8fr, 0.8fr),
    align: (left, center, center),
    table.hline(stroke: 0.8pt),
    [Pendekatan], [Query daftar], [Query relasi],
    table.hline(stroke: 0.5pt),
    [Lazy loading (tanpa `with()`)], [1], [∼60 (N+1 berulang)],
    [Eager loading (`with('details.product')`)], [1], [2],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Jumlah query: lazy loading vs eager loading untuk 15 transaksi],
) <tab:lazy-vs-eager>

`with('details.product')` membalik urutan itu: Eloquent
menjalankan satu query untuk daftar transaksi, satu query tambahan yang
memuat seluruh `TransactionDetail` milik transaksi-transaksi
itu sekaligus (lewat `WHERE transaction_id IN (...)`), dan satu
query lagi yang memuat seluruh `Product` terkait sekaligus.
Titik dari `details.product` memberi tahu Eloquent untuk
memuat relasi berjenjang: detail transaksi, lalu produk dari
setiap detail itu, dalam rangkaian query yang sama.

#listing(```php
$transactions = Transaction::with('details.product')
    ->latest()
    ->paginate(15);
```)

#notebox[
Jumlah query lewat eager loading tidak bergantung pada berapa banyak
baris yang ditampilkan; ia bergantung pada berapa lapis relasi yang
dimuat. Menampilkan 15 transaksi atau 150 transaksi dengan
`with('details.product')` sama-sama memakan 3 query total, bukan
3 dikali jumlah baris.
]

== Praktik: Paginasi pada Data Skala Nyata <sec:eloquent-dan-relasi-3>

Menampilkan seluruh 300 produk atau 2.500 transaksi dalam satu halaman
sekaligus, lewat `get()` biasa, akan berjalan tapi membebani
baik server maupun browser dengan ribuan baris HTML yang sebagian besar
tidak akan pernah dilihat pengguna dalam satu waktu.
`paginate()` memecah hasil query itu menjadi potongan kecil,
membaca hanya sejumlah baris yang diminta lewat parameter `page`
pada URL, plus metadata seperti total halaman dan link
sebelumnya/berikutnya, siap dipakai langsung oleh komponen Blade
`{{ $products->links() }}`.

+ Buka `app/Http/Controllers/ProductController.php`, metode
      `index()`. Ganti pemanggilan `get()` yang sudah ada
      menjadi `paginate()`:

  #listing(file: "app/Http/Controllers/ProductController.php", ```php
  public function index()
  {
      $products = Product::with('category')
          ->orderBy('name')
          ->paginate(10);

      return view('products.index', compact('products'));
  }
    
  ```)
+ Buka `resources/views/products/index.blade.php`. Di bawah
      tabel atau grid produk yang sudah ada, tambahkan satu baris untuk
      menampilkan navigasi halaman:

  #listing(file: "resources/views/products/index.blade.php", ```php
  <div class="mt-4">
      {{ $products->links() }}
  </div>
    
  ```)

  `$products->links()` otomatis merender tautan
      sebelumnya/berikutnya dan nomor halaman; tidak ada berkas view
      tambahan yang perlu dibuat manual.
+ Jalankan `php artisan serve` kalau belum berjalan, lalu
      buka `http://127.0.0.1:8000/products`. #strong[Yang
      diharapkan]: hanya 10 produk pertama yang tampil, diikuti deretan
      tautan nomor halaman di bawahnya.
+ Klik tautan halaman 2 (atau ubah manual URL menjadi
      `?page=2`). #strong[Yang diharapkan]: 10 produk yang tampil
      berbeda dari halaman pertama, dan address bar browser menunjukkan
      `?page=2`.
+ #strong[Kalau muncul error `Method links does not
      exist`], itu tanda controller di langkah 1 masih memanggil
      `get()`, bukan `paginate()`; `links()`
      hanya tersedia pada hasil `paginate()`, bukan pada
      koleksi biasa.

#tipbox[
Pakai `paginate()` setiap kali jumlah baris berpotensi tumbuh
tak terbatas seiring waktu, seperti daftar produk atau riwayat
transaksi. `get()` biasa masih cukup untuk daftar yang memang
kecil dan tetap kecil, seperti daftar kategori pada dropdown filter.
]

Membuktikan bahwa paginasi benar-benar bekerja, bukan cuma memotong
tampilan tapi menyisakan data yang sama, bisa diverifikasi lebih lanjut
lewat Tinker, dengan membandingkan ID baris pertama pada dua halaman
berbeda:

#listing(```bash
php artisan tinker
>>> Product::orderBy('name')->paginate(10)->pluck('id');
>>> Product::orderBy('name')->paginate(10, ['*'], 'page', 2)->pluck('id');
```)

Argumen keempat pada `paginate()` di atas memaksa nomor
halaman secara manual (biasanya diambil otomatis dari query string
`?page=2` pada request nyata). Kedua daftar ID yang tercetak
harus sama sekali tidak beririsan; kalau ada ID yang muncul di kedua
halaman, itu tanda ada bug pada urutan (`orderBy`) yang dipakai
sebelum paginasi, karena paginasi mengasumsikan urutan hasil query
selalu konsisten antar-request.

#branchref("chapter-05")

== Rangkuman <sec:eloquent-dan-relasi-rangkuman>

- Keempat model Simple POS terhubung lewat pasangan relasi
      `hasMany`/`belongsTo`: `Category` ke
      `Product`, dan `Transaction` ke
      `TransactionDetail` yang juga menunjuk ke `Product`.
- Lazy loading memicu satu query tambahan per baris per relasi
      (masalah N+1), sementara `with('details.product')` memuat
      relasi berjenjang dalam jumlah query tetap, tidak bergantung pada
      jumlah baris yang ditampilkan.
- `paginate()` membagi listing 300 produk atau 2.500
      transaksi menjadi halaman-halaman kecil, dan halaman yang berbeda
      bisa dibuktikan benar-benar mengembalikan baris berbeda dengan
      membandingkan ID hasil antar halaman.

== Latihan

+ Hapus `with('details.product')` dari query riwayat
      transaksi, aktifkan query log Laravel, lalu hitung selisih jumlah
      query sebelum dan sesudah eager loading dikembalikan.
+ Tambahkan relasi baru: `Product::belongsToMany` ke
      model `Transaction` lewat tabel pivot
      `transaction_details`, sebagai cara alternatif mengakses
      seluruh transaksi yang pernah membeli satu produk.
+ Terapkan `paginate()` pada satu endpoint listing lain
      di Simple POS yang belum memakainya, lalu buktikan halaman
      keduanya tidak beririsan seperti pada bagian Praktik.
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) perbedaan `hasMany` dan
      `belongsTo`, (b) mengapa N+1 disebut masalah performa,
      dan (c) bagaimana cara membuktikan dua halaman paginasi tidak
      beririsan. Cocokkan jawabanmu dengan isi bab ini.

#challengebox[
Tulis satu query yang menampilkan lima produk terlaris berdasarkan
total quantity terjual, memakai relasi `TransactionDetail`
dan fungsi agregasi (`sum`, `groupBy`), bukan dengan
mengambil seluruh baris lalu menghitungnya manual di PHP.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel #cite(<laraveldocs>) untuk
relasi Eloquent, eager loading, dan paginasi.
