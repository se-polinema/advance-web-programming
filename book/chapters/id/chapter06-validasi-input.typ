#import "/template.typ": *

= Validasi dan Keamanan Input <ch:validasi-input>

#chapterhero("teal", [Tolak input yang salah bentuk sebelum menyentuh basis data, lalu hitung ulang total transaksi di server, jangan pernah percaya angka dari klien begitu saja.], [#icon("shield-alt")#h(1em)FormRequest], [#icon("check-double")#h(1em)total di server], [#icon("exclamation-triangle")#h(1em)pesan error])

Satpam di pintu gerbang gudang tidak sekadar membuka portal untuk siapa
saja yang mengaku kurir. Ia memeriksa surat jalan, mencocokkan nomor
kendaraan, dan menahan siapa pun yang datanya tidak lengkap di luar
gerbang, sebelum barang apa pun sempat masuk ke area penyimpanan. Kasir
di kasir tunai punya kebiasaan serupa yang lebih halus: begitu pembeli
menyodorkan uang, kasir yang baik tidak langsung percaya angka yang
disebut pembeli, ia menghitung ulang totalnya sendiri dari struk yang
tercetak. Simple POS menjalankan dua kebiasaan itu sekaligus. FormRequest
berperan sebagai satpam gerbang, menahan data yang cacat sebelum
menyentuh controller. Perhitungan total di server berperan sebagai kasir
yang menghitung ulang, tidak pernah menerima begitu saja angka total
yang dikirim dari form atau JavaScript di sisi klien.

#strong[Yang Akan Kamu Pelajari]

+ menulis `FormRequest` untuk memvalidasi input produk dan transaksi Simple POS, termasuk aturan validasi kustom;
+ menjelaskan mengapa total transaksi dan subtotal detail transaksi wajib dihitung di sisi server, bukan diterima langsung dari input klien;
+ menangani pesan error validasi dan flash message pada form Blade Simple POS agar pengguna mendapat umpan balik yang jelas saat input ditolak.

== FormRequest dan Aturan Validasi <sec:validasi-input-1>

#istilahpenting[
/ FormRequest: Kelas Laravel yang membungkus logika validasi dan otorisasi satu request, dipisahkan dari controller, sehingga controller hanya menangani data yang sudah dinyatakan valid.
/ Validasi: Proses memeriksa apakah data input memenuhi aturan yang ditentukan (tipe, format, batas nilai) sebelum data itu dipakai lebih jauh.
/ Sanitasi: Proses membersihkan atau menormalkan data input, seperti memangkas spasi berlebih atau mengubah tipe, biasanya dijalankan setelah validasi lolos.
/ Flash Message: Pesan singkat yang disimpan di session hanya untuk satu request berikutnya, dipakai menampilkan notifikasi sukses atau gagal setelah redirect.
]

Menaruh aturan validasi langsung di dalam metode controller bekerja
untuk form yang sangat sederhana, tapi begitu satu form punya lebih dari
beberapa aturan, controller cepat penuh dengan kode pemeriksaan yang
sebenarnya bukan urusan controller. `FormRequest` memindahkan
tanggung jawab itu ke kelasnya sendiri: metode `rules()`
mendeklarasikan aturan tiap field, dan Laravel menjalankan validasi itu
otomatis sebelum metode controller sempat dieksekusi sama sekali.

#listing(file: "app/Http/Requests/StoreProductRequest.php", ```php
class StoreProductRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['required', 'exists:categories,id'],
            'price' => ['required', 'integer', 'min:0'],
            'stock' => ['required', 'integer', 'min:0'],
        ];
    }
}
```)

Aturan `exists:categories,id` adalah contoh aturan bawaan
Laravel yang melakukan query ke basis data sebagai bagian dari
validasi: ia menolak request kalau `category_id` yang dikirim
tidak cocok dengan baris `id` mana pun di tabel
`categories`. Begitu `StoreProductRequest` dipakai
sebagai type-hint parameter controller, menggantikan `Request`
biasa, Laravel otomatis menjalankan `rules()` lebih dulu; kalau
ada yang gagal, request langsung dikembalikan ke form asal beserta pesan
error, dan baris kode di dalam controller sama sekali tidak sempat
dieksekusi.

== Mengapa Total Dihitung di Server <sec:validasi-input-2>

Bab~3 sudah menyinggung ini sekilas: keranjang Alpine.js pada halaman
kasir menghitung subtotal secara langsung di browser, murni untuk
tampilan. Kalau form transaksi dikirim beserta field `total`
hasil hitungan Alpine itu, dan server memercayainya begitu saja tanpa
verifikasi, siapa pun yang mengubah nilai pada request (lewat DevTools
browser, atau lewat klien HTTP seperti curl yang sama sekali tidak
melewati JavaScript apa pun) bisa mengirim total berapa pun yang
diinginkan, termasuk total yang jauh lebih kecil dari harga produk yang
sebenarnya dibeli.

#warningbox[
Nilai apa pun yang berasal dari sisi klien, sekalipun perhitungannya
terlihat benar di layar, bisa diubah sebelum sampai ke server. Field
`total` yang dikirim lewat form HTML bukan pengecualian; ia
hanyalah string di dalam body request seperti field lainnya, dan tidak
ada yang mencegah seseorang mengubahnya jadi nilai lain sebelum request
itu benar-benar terkirim.
]

Simple POS menghindari risiko itu dengan tidak pernah membaca
`total` dari input sama sekali. Controller hanya menerima daftar
`product_id` dan `qty`, lalu mengambil harga produk yang
sebenarnya dari basis data, mengalikannya dengan qty untuk tiap baris
detail, dan menjumlahkan seluruh subtotal itu sendiri.

#listing(```php
$total = 0;
foreach ($validated['items'] as $item) {
    $product = Product::findOrFail($item['product_id']);
    $subtotal = $product->price * $item['qty'];
    $total += $subtotal;
    // simpan TransactionDetail dengan $subtotal di sini
}
$transaction->update(['total' => $total]);
```)

Dengan pola ini, seberapa pun nilai yang seseorang coba selipkan lewat
field `total` pada request, nilai itu tidak pernah dibaca; server
selalu menghitung ulang dari sumber yang bisa dipercaya, yaitu harga
produk yang sedang tersimpan di basis data saat itu.

== Praktik: Validasi Form Produk dan Transaksi <sec:validasi-input-3>

`StoreTransactionRequest` memvalidasi struktur array item
belanja, bukan cuma field tunggal. Langkah-langkah berikut membuatnya
dari nol dan memasangnya ke form transaksi kasir yang sudah ada.

+ Buat kerangka kelas `FormRequest`-nya:

  #listing(```bash
  php artisan make:request StoreTransactionRequest
    
  ```)
+ Buka berkas yang baru dibuat di
      `app/Http/Requests/StoreTransactionRequest.php`. Ubah
      `authorize()` agar mengembalikan `true` (form ini boleh
      dipakai siapa pun yang sudah login sebagai kasir), lalu isi
      `rules()`:

  #listing(file: "app/Http/Requests/StoreTransactionRequest.php", ```php
  public function rules(): array
  {
      return [
          'items' => ['required', 'array', 'min:1'],
          'items.*.product_id' => ['required', 'exists:products,id'],
          'items.*.qty' => ['required', 'integer', 'min:1'],
      ];
  }
    
  ```)

  Notasi `items.*.product_id` memvalidasi setiap elemen array
      `items` satu per satu, memastikan setiap baris punya
      `product_id` yang benar-benar ada di tabel `products`
      dan `qty` bernilai minimal 1, tanpa perlu menulis loop
      validasi manual.
+ Buka `app/Http/Controllers/TransactionController.php`,
      metode `store()`. Ganti type-hint parameternya dari
      `Request` biasa menjadi `StoreTransactionRequest`:

  #listing(file: "app/Http/Controllers/TransactionController.php", ```php
  public function store(StoreTransactionRequest $request)
  {
      $validated = $request->validated();
      // ...perhitungan total di server, lihat bagian sebelumnya
  }
    
  ```)

  Cukup dengan mengganti type-hint ini, Laravel otomatis menjalankan
      `rules()` sebelum baris pertama method `store()` sempat
      dieksekusi.
+ Buka `resources/views/pos/create.blade.php` (form kasir
      dari Bab~3). Tambahkan blok pesan sukses di bagian atas halaman:

  #listing(file: "resources/views/pos/create.blade.php", ```php
  @if (session('success'))
      <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
          {{ session('success') }}
      </div>
  @endif
    
  ```)
+ Di dekat elemen keranjang, tambahkan blok error umum untuk field
      `items`:

  #listing(file: "resources/views/pos/create.blade.php", ```php
  @error('items')
      <p class="text-sm text-red-600">{{ $message }}</p>
  @enderror
    
  ```)

  Direktif `@error('items')` hanya menampilkan blok itu kalau
      field `items` gagal validasi, sehingga pesan error muncul
      tepat di dekat keranjang, bukan sebagai daftar generik di puncak
      halaman.
+ Di controller, tambahkan flash message setelah transaksi
      tersimpan: `->with('success', 'Transaksi berhasil
      disimpan.')` pada redirect-nya.
+ Jalankan `php artisan serve`, buka `/pos`, lalu
      kirim form kasir dengan keranjang kosong (tanpa menambah satu produk
      pun). #strong[Yang diharapkan]: halaman kembali ke `/pos`
      (bukan pindah ke halaman lain), dan pesan error dari langkah 5
      muncul tepat di dekat keranjang.
+ Tambahkan satu produk ke keranjang, lalu kirim ulang form.
      #strong[Yang diharapkan]: transaksi tersimpan, halaman berpindah,
      dan pesan sukses dari langkah 4 tampil sekali; muat ulang halaman
      yang sama sekali lagi dan pesan itu sudah hilang.
+ #strong[Kalau `$errors` selalu kosong] meski keranjang
      dikirim kosong, periksa langkah 3: pastikan parameter method
      `store()` benar-benar bertipe
      `StoreTransactionRequest`, bukan `Request` biasa;
      validasi hanya berjalan otomatis lewat type-hint itu.

#branchref("chapter-06")

== Rangkuman <sec:validasi-input-rangkuman>

- `FormRequest` memisahkan aturan validasi dari
      controller lewat metode `rules()`, dijalankan otomatis
      Laravel sebelum kode controller sempat dieksekusi, termasuk aturan
      bawaan seperti `exists` yang memvalidasi lewat query ke
      basis data.
- Total transaksi dan subtotal detail wajib dihitung ulang di
      server dari harga produk yang tersimpan di basis data, karena nilai
      apa pun yang dikirim dari klien, termasuk hasil hitungan Alpine.js,
      bisa diubah sebelum sampai ke server dan tidak boleh dipercaya
      begitu saja.
- Pesan error validasi ditampilkan lewat `@error()` tepat
      di dekat input yang bermasalah, dan flash message lewat
      `session('success')` memberi umpan balik singkat setelah
      redirect tanpa bertahan ke request berikutnya.

== Latihan

+ Tambahkan aturan validasi baru pada `StoreProductRequest`
      yang menolak nama produk yang sama persis dengan produk lain pada
      kategori yang sama (pakai aturan `unique` dengan klausa
      tambahan).
+ Kirim request transaksi lewat curl dengan `qty` bernilai
      0 dan `product_id` yang tidak ada, lalu amati pesan error
      apa yang dikembalikan Laravel untuk masing-masing kasus.
+ Jelaskan dengan kata-katamu sendiri: kalau field `total`
      tetap divalidasi (misalnya dengan aturan `numeric`), apakah
      itu cukup untuk mencegah manipulasi total? Mengapa atau mengapa
      tidak?
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) apa yang dilakukan
      `FormRequest` sebelum controller dieksekusi, (b) mengapa
      total tidak boleh diterima langsung dari input, dan (c) bagaimana
      flash message berbeda dari data session biasa. Cocokkan jawabanmu
      dengan isi bab ini.

#challengebox[
Tambahkan validasi stok mencukupi pada `StoreTransactionRequest`
atau di controller: tolak transaksi kalau `qty` yang diminta pada
satu baris item melebihi `stock` produk yang tersimpan saat itu,
lengkap dengan pesan error yang menyebutkan nama produk yang stoknya
tidak cukup.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel #cite(<laraveldocs>) untuk
FormRequest dan aturan validasi, serta OWASP Top 10 #cite(<owasptop10>)
untuk prinsip tidak mempercayai input dari sisi klien.
