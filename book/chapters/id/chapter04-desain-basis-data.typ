#import "/template.typ": *

= Desain Basis Data, Migrasi, dan Seeding <ch:desain-basis-data>

#chapterhero("teal", [Rancang skema basis data Simple POS, isi dengan data seed berskala nyata, lalu buktikan kenapa index foreign key bukan hal opsional.], [#icon("database")#h(1em)skema Simple POS], [#icon("table")#h(1em)migrasi & seeding], [#icon("key")#h(1em)index FK])

Gudang kelontong yang baik menaruh setiap barang di rak berlabel, dengan
katalog kartu yang mencatat rak mana menyimpan barang apa. Pegawai baru
yang mencari stok gula pasir tinggal membaca katalog, langsung ke rak
nomor sekian, tanpa menyusuri seluruh gudang satu per satu. Gudang yang
tidak punya katalog seperti itu masih bisa dipakai, barang tetap ada di
suatu tempat, tapi mencarinya berarti menyusuri baris demi baris rak
sampai ketemu. Basis data Simple POS bekerja dengan logika yang sama:
skema tabel adalah tata letak rak itu sendiri, dan index adalah katalog
kartunya. Tanpa index yang tepat pada kolom yang sering dicari, mesin
basis data tetap bisa menemukan barisnya, hanya saja dengan menyusuri
seluruh tabel satu per satu, dan pada tabel berisi ribuan baris transaksi
perbedaan itu terasa nyata.

#strong[Yang Akan Kamu Pelajari]

+ merancang skema basis data Simple POS (`categories`, `products`, `transactions`, `transaction_details`) beserta relasinya;
+ menulis migrasi dan seeder skala nyata (300 produk, 2.500 transaksi) memakai bulk insert lewat `DB::table()->insert()` dalam batch, bukan `Model::create()` satu per satu;
+ menjelaskan mengapa `constrained()` pada SQLite tidak otomatis membuat index pada kolom foreign key, dampaknya pada query listing produk, dan cara memverifikasinya dengan `EXPLAIN QUERY PLAN`.

== Merancang Skema Simple POS <sec:desain-basis-data-1>

#istilahpenting[
/ Migrasi: Berkas PHP yang mendeskripsikan perubahan struktur tabel (membuat, mengubah, menghapus kolom) secara terprogram, sehingga skema basis data punya riwayat yang bisa dijalankan ulang di komputer lain.
/ Skema: Rancangan struktur tabel: nama kolom, tipe data, dan batasan (nullable, default, unique) yang berlaku pada setiap barisnya.
/ Foreign Key: Kolom pada satu tabel yang menunjuk ke `id` baris pada tabel lain, menjaga agar sebuah `transaction_details` tidak pernah menunjuk ke produk yang tidak ada.
/ Index: Struktur data tambahan yang dibangun mesin basis data di atas satu atau beberapa kolom, mempercepat pencarian baris pada kolom itu tanpa harus memindai seluruh tabel.
/ Seeder: Kelas PHP yang mengisi tabel dengan data awal atau data uji, dijalankan lewat `db:seed` atau sebagai bagian dari `migrate:fresh --seed`.
]

Simple POS bertumpu pada empat tabel inti, dan relasinya cukup lurus
untuk digambar di atas kertas sebelum satu baris migrasi pun ditulis.
Satu `categories` punya banyak `products`. Satu
`products` bisa muncul di banyak `transaction_details`,
dan satu `transactions` juga punya banyak
`transaction_details`, masing-masing mencatat satu baris item
yang dibeli. `transactions` sendiri menunjuk balik ke
`users`, mencatat kasir mana yang memproses transaksi itu.

#figure(
  table(
    columns: (0.9fr, 2.1fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [Tabel], [Kolom utama],
    table.hline(stroke: 0.5pt),
    [`categories`], [`id`, `name`],
    [`products`], [`id`, `category_id` (fk), `name`, `price`, `stock`],
    [`transactions`], [`id`, `user_id` (fk), `total`, `created_at`],
    [`transaction_details`], [`id`, `transaction_id` (fk), `product_id` (fk), `qty`, `subtotal`],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Skema kolom empat tabel inti Simple POS],
) <tab:skema-inti>

Perhatikan bahwa `transactions.total` dan
`transaction_details.subtotal` adalah kolom yang disimpan, bukan
dihitung ulang setiap kali dibaca. Itu keputusan sadar: total transaksi
harus tetap sama persis seperti nilai saat transaksi itu terjadi, meskipun
harga produk berubah di kemudian hari. Bab~6 membahas mengapa nilai ini
juga wajib dihitung ulang di server saat transaksi disimpan, bukan
sekadar dipercaya begitu saja dari input.

#listing(file: "database/migrations/2026_08_20_122440_create_products_table.php", ```php
Schema::create('products', function (Blueprint $table) {
    $table->id();
    $table->foreignId('category_id')->constrained();
    $table->string('name');
    $table->unsignedInteger('price');
    $table->unsignedInteger('stock')->default(0);
    $table->timestamps();
});
```)

`foreignId('category_id')->constrained()` adalah pasangan yang
sering dipakai bersama: baris pertama membuat kolom
`category_id` bertipe unsigned big integer, baris kedua
menambahkan #emph[constraint] foreign key yang menunjuk ke
`categories.id` berdasarkan konvensi penamaan Laravel. Constraint
ini menjaga integritas data, mencegah baris produk menunjuk ke kategori
yang sudah dihapus, tapi seperti akan terlihat di bagian Praktik, itu
tidak otomatis berarti kolomnya sudah punya index.

== Migrasi dan Seeding Skala Nyata <sec:desain-basis-data-2>

Seeder Simple POS mengisi basis data dengan 300 produk dan 2.500
transaksi, masing-masing dengan beberapa baris `transaction_details`.
Menulis seeder itu dengan `Product::create()` dipanggil 300
kali di dalam loop akan berjalan, tapi setiap panggilan
`Model::create()` membuka satu query `INSERT` sendiri
ke basis data, lengkap dengan overhead membentuk objek Eloquent, memicu
event model, dan menghitung ulang atribut. Untuk seed berskala ratusan
atau ribuan baris, overhead itu bertumpuk cepat.

#listing(file: "database/seeders/DatabaseSeeder.php", ```php
$products = [];
foreach ($categoryIds as $categoryId) {
    for ($i = 0; $i < 30; $i++) {
        $products[] = [
            'category_id' => $categoryId,
            'name' => fake()->words(2, true),
            'price' => fake()->numberBetween(5000, 50000),
            'stock' => fake()->numberBetween(0, 200),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }
}

foreach (array_chunk($products, 50) as $chunk) {
    DB::table('products')->insert($chunk);
}
```)

`DB::table()->insert()` melewati lapisan Eloquent sama sekali:
ia menyusun satu pernyataan `INSERT` yang menulis banyak baris
sekaligus, jauh lebih sedikit round-trip ke basis data dibanding satu
query per baris. `array_chunk()` membagi array besar menjadi
kelompok-kelompok kecil sebelum di-insert, karena sebagian mesin basis
data punya batas jumlah baris atau parameter dalam satu pernyataan
`INSERT`; SQLite sendiri cukup toleran, tapi kebiasaan membagi
per batch tetap berguna saat seeder yang sama suatu hari dijalankan di
atas MySQL atau PostgreSQL.

#warningbox[
Seeding transaksi butuh perhatian ekstra: satu transaksi terdiri dari
baris `transactions` plus beberapa baris
`transaction_details` yang harus konsisten satu sama lain.
Bungkus proses insert transaksi dan detailnya dalam satu
`DB::transaction(function () { ... })`. Kalau prosesnya
gagal di tengah jalan, misalnya karena data acak yang dihasilkan tidak
valid, seluruh perubahan dalam blok itu dibatalkan bersama, sehingga
basis data tidak pernah berakhir dengan transaksi yang tercatat tapi
detailnya hilang separuh.
]

== Praktik: Index Foreign Key dan EXPLAIN QUERY PLAN <sec:desain-basis-data-3>

`foreignId()->constrained()` pada MySQL memang otomatis membuat
index pada kolom itu sebagai efek samping, tapi Simple POS memakai
SQLite untuk pengembangan, dan pada SQLite `constrained()` hanya
menambahkan #emph[constraint] foreign key, bukan index. Constraint
menjaga integritas data (menolak insert yang menunjuk ke baris yang
tidak ada), tapi tidak mempercepat pencarian. Query listing produk per
kategori, seperti yang dipakai halaman `/products`, memfilter
`WHERE category_id = ?`. Tanpa index eksplisit pada kolom itu,
SQLite terpaksa memindai seluruh tabel `products` baris demi
baris untuk menemukan baris yang cocok.

`EXPLAIN QUERY PLAN` adalah perintah SQLite yang menampilkan
strategi yang dipakai mesin basis data untuk menjalankan satu query,
tanpa benar-benar mengeksekusinya. Langkah-langkah berikut membuktikan
perbedaan sebelum dan sesudah index ditambahkan, memakai basis data yang
sudah diisi seeder dari bagian sebelumnya.

+ Pastikan basis data sudah terisi seeder (kalau belum, jalankan
      `php artisan migrate:fresh --seed` terlebih dulu), lalu lihat
      kondisi #emph[sebelum] ada index eksplisit:

  #listing(```bash
  sqlite3 database/database.sqlite \
    "EXPLAIN QUERY PLAN SELECT * FROM products WHERE category_id = 3;"
    
  ```)

  #strong[Yang diharapkan]: baris hasilnya memuat kata
      `SCAN products`, tandanya SQLite memindai seluruh tabel dari
      baris pertama sampai terakhir untuk menemukan baris yang cocok.
+ Buat migrasi baru khusus untuk index (jangan mengedit migrasi
      lama yang sudah pernah dijalankan):

  #listing(```bash
  php artisan make:migration add_index_to_products_and_transactions_table
    
  ```)
+ Buka berkas migrasi yang baru dibuat di
      `database/migrations/`, lalu isi metode `up()`-nya:

  #listing(```php
  public function up(): void
  {
      Schema::table('products', function (Blueprint $table) {
          $table->index('category_id');
      });

      Schema::table('transactions', function (Blueprint $table) {
          $table->index('user_id');
          $table->index('created_at');
      });
  }
    
  ```)
+ Jalankan migrasi itu. Pakai `php artisan migrate`, bukan
      `php artisan migrate:fresh`, supaya index ditambahkan di atas
      data seeder yang sudah ada, bukan menghapus semuanya lagi:

  #listing(```bash
  php artisan migrate
    
  ```)
+ Jalankan ulang perintah `EXPLAIN QUERY PLAN` yang persis sama
      seperti langkah 1. #strong[Yang diharapkan]: baris hasilnya sekarang
      berubah menjadi `SEARCH products USING INDEX
      products_category_id_index`, tandanya SQLite langsung melompat ke
      baris yang relevan lewat struktur index, tanpa menyentuh baris lain
      sama sekali.
+ #strong[Kalau perintah `sqlite3` tidak dikenali] (belum
      terinstal di sistem), pakai jalur alternatif lewat Tinker tanpa perlu
      memasang apa pun:

  #listing(```bash
  php artisan tinker
  >>> DB::select("EXPLAIN QUERY PLAN SELECT * FROM products WHERE category_id = 3");
    
  ```)

  Hasilnya berupa array asosiatif; kolom `detail` di dalamnya
      berisi teks `SCAN`/`SEARCH` yang sama seperti pada CLI
      `sqlite3`.

#warningbox[
Pada tabel berisi puluhan baris, perbedaan `SCAN` dan
`SEARCH` nyaris tidak terasa. Pada tabel berisi ribuan baris,
seperti `transactions` milik Simple POS setelah seeding penuh,
`SCAN` berarti setiap baris ikut diperiksa pada setiap query,
dan waktu itu bertambah linear seiring tabel bertumbuh. Index bukan
optimasi prematur di sini; ia perbaikan atas bug performa yang sudah
nyata begitu data mendekati skala produksi.
]

#branchref("chapter-04")

== Rangkuman <sec:desain-basis-data-rangkuman>

- Simple POS terdiri dari empat tabel inti,
      `categories`--`products`--`transactions`--
      `transaction_details`, dihubungkan lewat foreign key, dengan
      `total` dan `subtotal` disimpan sebagai nilai tetap,
      bukan dihitung ulang setiap kali dibaca.
- Seeding skala nyata (300 produk, 2.500 transaksi) memakai
      `DB::table()->insert()` dalam batch lewat
      `array_chunk()`, jauh lebih efisien daripada memanggil
      `Model::create()` satu per satu, dan insert transaksi
      beserta detailnya dibungkus dalam satu `DB::transaction()`.
- `constrained()` pada SQLite tidak otomatis membuat index;
      index foreign key harus ditambahkan eksplisit lewat
      `$table->index()`, dan perbedaannya bisa dibuktikan langsung
      lewat `EXPLAIN QUERY PLAN`, yang berubah dari `SCAN`
      menjadi `SEARCH ... USING INDEX` setelah index ditambahkan.

== Latihan

+ Tambahkan index pada kolom `transaction_details.product_id`,
      lalu jalankan `EXPLAIN QUERY PLAN` pada query yang mencari
      seluruh detail transaksi untuk satu produk tertentu. Bandingkan
      hasilnya sebelum dan sesudah index ditambahkan.
+ Hitung ulang: jika seeder diubah menjadi 1.000 produk dan
      10.000 transaksi, berapa kira-kira jumlah baris
      `transaction_details` yang dihasilkan, dengan asumsi
      rata-rata 3 item per transaksi?
+ Tulis satu query listing baru pada Simple POS (misalnya
      transaksi dalam rentang tanggal tertentu), lalu jalankan
      `EXPLAIN QUERY PLAN` pada query itu sendiri untuk memeriksa
      apakah ia memakai index yang sudah ada.
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) mengapa `total` transaksi
      disimpan alih-alih dihitung ulang, (b) mengapa bulk insert dipilih
      untuk seeding skala besar, dan (c) apa yang sebenarnya ditambahkan
      `constrained()` pada SQLite. Cocokkan jawabanmu dengan isi bab
      ini.

#challengebox[
Tambahkan kolom baru `sku` (string, unik, nullable) pada tabel
`products` lewat migrasi baru, bukan dengan mengubah migrasi
lama yang sudah pernah dijalankan. Jalankan
`migrate` dan pastikan skema berubah tanpa perlu
`migrate:fresh`.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel #cite(<laraveldocs>) untuk
konvensi migrasi, query builder, dan seeder.
