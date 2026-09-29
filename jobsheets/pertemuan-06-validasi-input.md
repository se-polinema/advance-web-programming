# Jobsheet Praktikum Kelompok: Pertemuan 6
## Validasi dan Keamanan Input (Kerja Kelompok)

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | 6 (Minggu 6) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK 2: Mahasiswa mampu menerapkan model, templating, dan operasi CRUD dalam pengembangan aplikasi web berbasis framework. |
| **Mode Pengerjaan** | Kelompok (sama seperti Pertemuan 3-5), satu repositori GitHub bersama per kelompok |
| **Kode Awal** | repositori kelompok hasil Pertemuan 5 (lanjutkan `main`-nya) |

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet kelompok ini, kamu mampu:

1. Melindungi model dari mass assignment yang tidak diinginkan lewat `$fillable`.
2. Menulis `StoreProductRequest` dan `StoreTransactionRequest` untuk memvalidasi input sebelum controller menerimanya.
3. Menghitung ulang total transaksi di server dari harga yang tersimpan di database, bukan dari input klien.
4. Menampilkan pesan error per field dan flash message sukses di Blade.

## B. Persiapan dan Prasyarat

- **Alat**: sama seperti Pertemuan 5 (PHP 8.2+, Composer, Node.js, Git).
- **Identitas git**: sudah diatur sejak Pertemuan 3. Kalau ganti laptop atau komputer lab, ulangi pengecekan `git config --global user.name`/`user.email` seperti pada jobsheet itu.
- **Kelanjutan kode**: kelompok melanjutkan repositori GitHub bersama dari Pertemuan 5, dari `main` yang sudah berisi `increment 5`. Kalau repositori kelompok bermasalah, mulai dari template `simple-pos-ch05` (`https://github.com/se-polinema/simple-pos-ch05`, dibuat lewat **Use this template** seperti Langkah 1 Pertemuan 3). Template ini sudah persis sama dengan kondisi akhir Pertemuan 5, jadi tidak perlu mengulang langkah apa pun sebelum melanjutkan jobsheet ini.
- **Verifikasi cepat** sebelum mulai:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  ```
  > ✅ **Checkpoint:** baris teratas menunjukkan commit `increment 5: ...` (atau satu commit awal kalau memakai template).

## C. Langkah Kerja

Alur kerja sama seperti Pertemuan 3-5: setiap langkah pembangunan (Langkah 2 sampai 5) dikerjakan di branch terpisah dari `main`, digabungkan lewat Pull Request dengan **Create a merge commit** (bukan squash), lalu semua anggota `git pull` sebelum membuat branch berikutnya.

### Langkah 1: Memetakan aturan validasi di atas kertas

Sebelum menulis kode, sepakati aturan validasi untuk dua form yang akan kamu bangun:

| Form | Field | Aturan |
|---|---|---|
| Tambah produk | `name` | wajib, teks, maksimal 255 karakter |
| Tambah produk | `category_id` | wajib, harus ada di tabel `categories` |
| Tambah produk | `price`, `stock` | wajib, angka, minimal 0 |
| Transaksi kasir | `items` | wajib, array, minimal 1 baris |
| Transaksi kasir | `items.*.product_id` | wajib, harus ada di tabel `products` |
| Transaksi kasir | `items.*.qty` | wajib, angka, minimal 1 |

> ✅ **Checkpoint:** kelompok sudah punya tabel aturan di atas kertas/papan, dan pembagian tugas Langkah 2-5 sudah disepakati.

### Langkah 2: `$fillable` pada model

Coba buka `php artisan tinker` sekarang dan jalankan `Product::create(['name' => 'Tes'])`. Kamu akan mendapat `MassAssignmentException`, karena ketiga model ini belum punya `$fillable`. Perbaiki dulu sebelum lanjut ke langkah berikutnya.

Buat branch baru dari `main` terbaru, misalnya `fillable-models`:

```bash
git checkout main
git pull
git checkout -b fillable-models
```

Tambahkan satu baris di awal class masing-masing model. Isi `app/Models/Product.php`, tambahkan tepat di bawah baris `class Product extends Model`:

```php
protected $fillable = ['category_id', 'name', 'price', 'stock'];
```

Isi `app/Models/Transaction.php`, tambahkan tepat di bawah baris `class Transaction extends Model`:

```php
protected $fillable = ['user_id', 'total'];
```

Isi `app/Models/TransactionDetail.php`, tambahkan tepat di bawah baris `class TransactionDetail extends Model`:

```php
protected $fillable = ['transaction_id', 'product_id', 'qty', 'subtotal'];
```

```bash
git add .
git commit -m "tambah fillable pada product, transaction, dan transaction detail"
git push -u origin fillable-models
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** ulangi `Product::create(['category_id' => 1, 'name' => 'Tes', 'price' => 1000, 'stock' => 5])` di tinker, kali ini berhasil tanpa exception.

> ⚠️ **Jika gagal:** kalau masih `MassAssignmentException`, pastikan nama kolom di `$fillable` persis sama dengan nama kolom di migrasi, dan tidak ada salah ketik pada nama model yang diedit.

### Langkah 3: `StoreProductRequest` dan form tambah produk

Buat branch baru, misalnya `product-form-validation`:

```bash
git checkout main
git pull
git checkout -b product-form-validation
php artisan make:request StoreProductRequest
```

Ganti seluruh isi `app/Http/Requests/StoreProductRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

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
```

`authorize()` bawaan generator selalu `false` (menolak semua orang), jadi jangan lupa ubah jadi `true` seperti di atas, kalau tidak, form akan selalu ditolak dengan error 403 meskipun datanya valid.

Ganti seluruh isi `app/Http/Controllers/ProductController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreProductRequest;
use App\Models\Category;
use App\Models\Product;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::with('category')
            ->orderBy('name')
            ->paginate(10);

        return view('products.index', compact('products'));
    }

    public function create()
    {
        $categories = Category::orderBy('name')->get();

        return view('products.create', compact('categories'));
    }

    public function store(StoreProductRequest $request)
    {
        Product::create($request->validated());

        return redirect()
            ->route('products.index')
            ->with('success', 'Produk berhasil ditambahkan.');
    }

    public function edit(string $id)
    {
        return "Form edit produk #{$id} (belum dibuat)";
    }

    public function update(string $id)
    {
        return "Produk #{$id} diperbarui (belum ada logika penyimpanan)";
    }
}
```

Buat view lewat artisan:

```bash
php artisan make:view products.create
```

Isi `resources/views/products/create.blade.php`:

```php
@extends('layouts.app')

@section('title', 'Tambah Produk')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Tambah Produk</h1>

    <form method="POST" action="{{ route('products.store') }}" class="max-w-md">
        @csrf

        <label class="block mb-3">
            <span class="text-sm font-medium">Nama</span>
            <input type="text" name="name" value="{{ old('name') }}" class="mt-1 block w-full rounded-md border-gray-300">
            @error('name')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <label class="block mb-3">
            <span class="text-sm font-medium">Kategori</span>
            <select name="category_id" class="mt-1 block w-full rounded-md border-gray-300">
                @foreach ($categories as $category)
                    <option value="{{ $category->id }}" @selected(old('category_id') == $category->id)>{{ $category->name }}</option>
                @endforeach
            </select>
            @error('category_id')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <label class="block mb-3">
            <span class="text-sm font-medium">Harga</span>
            <input type="number" name="price" value="{{ old('price') }}" class="mt-1 block w-full rounded-md border-gray-300">
            @error('price')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <label class="block mb-3">
            <span class="text-sm font-medium">Stok</span>
            <input type="number" name="stock" value="{{ old('stock') }}" class="mt-1 block w-full rounded-md border-gray-300">
            @error('stock')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-md">Simpan</button>
    </form>
@endsection
```

Tambahkan flash message dan link ke form baru di `resources/views/products/index.blade.php`, sisipkan tepat sebelum `<table class="w-full text-left border-collapse">`:

```php
@if (session('success'))
    <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
        {{ session('success') }}
    </div>
@endif

<a href="{{ route('products.create') }}" class="inline-block mb-4 bg-blue-600 text-white px-4 py-2 rounded-md">Tambah Produk</a>
```

```bash
git add .
git commit -m "tambah validasi dan form tambah produk"
git push -u origin product-form-validation
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** buka `/products/create`, klik Simpan tanpa mengisi apa pun. Halaman kembali ke form yang sama dengan pesan error merah di bawah tiap field kosong. Isi semua field dengan benar, klik Simpan lagi: halaman pindah ke `/products` dengan pesan hijau "Produk berhasil ditambahkan." dan produk barumu muncul di tabel.

> ⚠️ **Jika gagal:** `Class "App\Http\Requests\StoreProductRequest" not found` berarti `use App\Http\Requests\StoreProductRequest;` belum ditambahkan atau salah nama. Halaman putih kosong tanpa pesan error berarti `authorize()` masih `false`.

### Langkah 4: Keranjang kasir jadi form sungguhan

Sejak Pertemuan 3, halaman `/pos` cuma mengumpulkan item lewat Alpine tanpa pernah benar-benar mengirimnya ke server. Sekarang saatnya keranjang itu jadi form HTML sungguhan.

Buat branch baru, misalnya `transaction-form-validation`:

```bash
git checkout main
git pull
git checkout -b transaction-form-validation
php artisan make:request StoreTransactionRequest
```

Ganti seluruh isi `app/Http/Requests/StoreTransactionRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty' => ['required', 'integer', 'min:1'],
        ];
    }
}
```

Ganti seluruh isi `resources/views/pos/create.blade.php`. Perhatikan tiga tambahan dari versi Pertemuan 3: dibungkus `<form>` beserta `@csrf`, tiap item keranjang menghasilkan dua input tersembunyi (`items[index][product_id]` dan `items[index][qty]`), dan ada tombol Bayar:

```php
@extends('layouts.app')

@section('title', 'Kasir')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Transaksi Kasir</h1>

    @if (session('success'))
        <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
            {{ session('success') }}
        </div>
    @endif

    @error('items')
        <div class="bg-red-50 text-red-700 p-3 rounded-md mb-4">{{ $message }}</div>
    @enderror

    <form method="POST" action="{{ route('transactions.store') }}" x-data="{
        cart: [],
        addToCart(id, name, price) {
            this.cart.push({ id, name, price });
        },
        subtotal() {
            return this.cart.reduce((sum, item) => sum + item.price, 0);
        }
    }">
        @csrf
        <div class="grid grid-cols-3 gap-4">
            @foreach ($products as $product)
                <div class="border rounded-md p-3 cursor-pointer"
                     @click="addToCart({{ $product->id }}, '{{ $product->name }}', {{ $product->price }})">
                    <p class="font-medium">{{ $product->name }}</p>
                    <p class="text-sm text-slate-500">Rp {{ number_format($product->price) }}</p>
                </div>
            @endforeach
        </div>

        <div class="mt-4 border-t pt-3">
            <template x-for="(item, index) in cart" :key="index">
                <div>
                    <p x-text="item.name + ' - Rp ' + item.price"></p>
                    <input type="hidden" :name="'items[' + index + '][product_id]'" :value="item.id">
                    <input type="hidden" :name="'items[' + index + '][qty]'" value="1">
                </div>
            </template>
            <p class="font-semibold mt-2">Subtotal: Rp <span x-text="subtotal()"></span></p>
            <button type="submit" class="mt-3 bg-blue-600 text-white px-4 py-2 rounded-md">Bayar</button>
        </div>
    </form>
@endsection
```

Setiap klik kartu produk menambah satu baris di `cart` dengan qty tetap 1, jadi mengklik produk yang sama dua kali menghasilkan dua baris `items` terpisah, bukan satu baris dengan qty 2. Itu cukup untuk pertemuan ini; menggabungkan qty jadi satu baris per produk bisa jadi tantangan mandiri.

Ganti method `store()` di `app/Http/Controllers/TransactionController.php`, dan tambahkan `use` untuk `StoreTransactionRequest`, `TransactionDetail`, dan `DB` di bagian atas berkas:

```php
use App\Http\Requests\StoreTransactionRequest;
use App\Models\TransactionDetail;
use Illuminate\Support\Facades\DB;

// ...

public function store(StoreTransactionRequest $request)
{
    $validated = $request->validated();

    DB::transaction(function () use ($validated) {
        $transaction = Transaction::create([
            'user_id' => 1, // sementara di-hardcode, belum ada login sungguhan sampai Pertemuan 7
            'total' => 0,
        ]);

        $total = 0;

        foreach ($validated['items'] as $item) {
            $product = Product::findOrFail($item['product_id']);
            $subtotal = $product->price * $item['qty'];
            $total += $subtotal;

            TransactionDetail::create([
                'transaction_id' => $transaction->id,
                'product_id' => $product->id,
                'qty' => $item['qty'],
                'subtotal' => $subtotal,
            ]);
        }

        $transaction->update(['total' => $total]);
    });

    return redirect()
        ->route('pos.create')
        ->with('success', 'Transaksi berhasil disimpan.');
}
```

`user_id` sengaja di-hardcode ke `1` (Test User dari seeder): Simple POS belum punya sistem login sungguhan, itu topik Pertemuan 7. `DB::transaction()` membungkus semuanya supaya kalau salah satu baris gagal disimpan, seluruh transaksi ikut dibatalkan, bukan tersimpan setengah-setengah.

```bash
git add .
git commit -m "tambah validasi dan total di server untuk transaksi"
git push -u origin transaction-form-validation
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** buka `/pos`, klik tombol Bayar tanpa mengklik produk apa pun dulu. Halaman kembali ke `/pos` dengan pesan error merah "wajib diisi" untuk `items`. Klik dua produk lalu klik Bayar: halaman kembali ke `/pos` dengan pesan hijau "Transaksi berhasil disimpan." Buka `php artisan tinker`:
> ```
> >>> Transaction::latest()->first()->total;
> ```
> Bandingkan angkanya dengan harga kedua produk yang tadi kamu klik dijumlahkan, harus persis sama.

> ⚠️ **Jika gagal:** transaksi tersimpan tapi `total`-nya 0 berarti `$transaction->update(['total' => $total])` terpanggil sebelum loop `foreach` selesai, atau ada di luar closure `DB::transaction()`. Error `Call to undefined method items` di form berarti atribut `:name` pada input tersembunyi salah ketik.

### Langkah 5: Bersama, uji integrasi dan review kode

Semua anggota `git checkout main && git pull`, jalankan `php artisan migrate:fresh --seed`, lalu ulangi seluruh checkpoint di laptop masing-masing: `$fillable` di tinker, form tambah produk, dan form kasir. Setelah itu, kelompok membaca kode bersama: setiap anggota menjelaskan satu FormRequest atau bagian controller yang **bukan** ia tulis sendiri.

> ✅ **Checkpoint:** seluruh checkpoint di atas berhasil diulang dan menunjukkan hasil yang sama persis di setiap laptop anggota.

### Langkah 6: Tantangan mandiri kelompok dan commit `increment 6`

Bagi tugas berikut di antara anggota, supaya setiap anggota tercatat minimal satu commit bermakna lewat Pull Request masing-masing:

- Gabungkan qty per produk di keranjang kasir: kalau produk yang sama diklik dua kali, tambahkan `qty`-nya di baris `cart` yang sudah ada alih-alih membuat baris baru.
- Tambahkan aturan validasi stok mencukupi pada `StoreTransactionRequest` atau di controller: tolak transaksi kalau `qty` yang diminta melebihi `stock` produk saat itu, lengkap dengan pesan error yang menyebutkan nama produknya.
- Selesaikan `ProductController::edit()`/`update()` mengikuti pola `create()`/`store()`: buat `resources/views/products/edit.blade.php` dan validasi lewat `StoreProductRequest` yang sama.
- Kirim request `POST /pos` lewat curl dengan `qty` bernilai `0` dan `product_id` yang tidak ada, lalu amati pesan error apa yang dikembalikan Laravel untuk masing-masing kasus.
- Jelaskan dengan kata-katamu sendiri (ditulis di README atau dokumen terpisah): kalau field `total` tetap dikirim dari form dan divalidasi dengan aturan `numeric`, apakah itu cukup mencegah manipulasi total? Kenapa atau kenapa tidak?

Setiap tugas: buat branch baru (misalnya `merge-cart-qty`), kerjakan, commit, push, lalu buka dan merge Pull Request-nya (ikuti alur Langkah 3 Pertemuan 3).

Setelah semua Pull Request masuk dan digabungkan, salah satu anggota menutup pekerjaan kelompok:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 6: validasi form request dan total di server simple pos"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** baris teratas `git log --pretty="%h %an %s"` menunjukkan `increment 6: ...`, dan baris-baris di bawahnya menunjukkan nama setiap anggota kelompok.

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta dosen:

- Link repositori GitHub kelompok.
- Screenshot form tambah produk dengan pesan error (percobaan gagal) dan dengan pesan sukses (percobaan berhasil).
- Screenshot halaman `/pos` dengan pesan error `items` (keranjang kosong) dan dengan pesan sukses setelah transaksi tersimpan.
- Screenshot hasil tinker: total transaksi terakhir dibandingkan dengan perhitungan manual.
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel pembagian tugas: nama anggota | langkah/tugas yang dikerjakan | hash commit.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---:|---|---|
| Langkah kerja tuntas (kelompok) | 40% | Langkah 1-6 selesai, form produk dan kasir tervalidasi dengan total dihitung ulang di server | Sebagian besar langkah selesai, kedua form berfungsi |
| Checkpoint terverifikasi (kelompok) | 25% | Screenshot error/sukses kedua form, hasil tinker, dan git log lengkap dan benar | Sebagian checkpoint terbukti |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna atas nama tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Kerapian repositori dan commit | 10% | Pesan `increment 6` persis, tanpa menyertakan `vendor/`, `node_modules/`, `.env`, PR di-merge rapi (bukan squash) | Commit ada, pesan kurang rapi atau PR di-squash |
