# Jobsheet Praktikum Kelompok: Pertemuan 5
## Eloquent ORM, Relationship, dan Pagination (Kerja Kelompok)

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | 5 (Minggu 5) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK 2: Mahasiswa mampu menerapkan model, templating, dan operasi CRUD dalam pengembangan aplikasi web berbasis framework. |
| **Mode Pengerjaan** | Kelompok (sama seperti Pertemuan 3 dan 4), satu repositori GitHub bersama per kelompok |
| **Kode Awal** | repositori kelompok hasil Pertemuan 4 (lanjutkan `main`-nya) |

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet kelompok ini, kamu mampu:

1. Mendefinisikan relationship `hasMany`/`belongsTo` pada model `Category`, `Product`, `Transaction`, dan `TransactionDetail`.
2. Menampilkan listing produk dan riwayat transaksi dengan eager loading dan `paginate()`.
3. Membuktikan masalah N+1 lewat query log, lalu memperbaikinya dengan eager loading.
4. Membuktikan `paginate()` bekerja benar lewat perbandingan ID antar halaman di tinker.

## B. Persiapan dan Prasyarat

- **Alat**: sama seperti Pertemuan 4 (PHP 8.2+, Composer, Node.js, Git).
- **Identitas git**: sudah diatur sejak Pertemuan 3. Kalau ganti laptop atau komputer lab, ulangi pengecekan `git config --global user.name`/`user.email` seperti pada jobsheet itu.
- **Kelanjutan kode**: kelompok melanjutkan repositori GitHub bersama dari Pertemuan 4, dari `main` yang sudah berisi `increment 4`. Kalau repositori kelompok bermasalah, mulai dari template `simple-pos-ch04` (`https://github.com/se-polinema/simple-pos-ch04`, dibuat lewat **Use this template** seperti Langkah 1 Pertemuan 3). Template ini sudah persis sama dengan kondisi akhir Pertemuan 4, jadi tidak perlu mengulang langkah apa pun sebelum melanjutkan jobsheet ini, cukup ingat bahwa repositori hasil template hanya punya satu commit di riwayatnya, bukan riwayat `increment 1` sampai `increment 4` yang lengkap seperti repositori kelompok asli.
- **Verifikasi cepat** sebelum mulai:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  ```
  > ✅ **Checkpoint:** baris teratas menunjukkan commit `increment 4: ...` (atau satu commit awal kalau memakai template).

## C. Langkah Kerja

Alur kerja sama seperti Pertemuan 3 dan 4: setiap langkah pembangunan (Langkah 2 sampai 5) dikerjakan di branch terpisah dari `main`, digabungkan lewat Pull Request dengan **Create a merge commit** (bukan squash), lalu semua anggota `git pull` sebelum membuat branch berikutnya.

### Langkah 1: Memetakan relationship di atas kertas

Sebelum menulis kode, gambar tabel relationship berikut di atas kertas atau papan tulis, dan sepakati siapa mengerjakan model yang mana:

| Model | Relationship | Model Terkait |
|---|---|---|
| `Category` | `hasMany` | `Product` |
| `Product` | `belongsTo` | `Category` |
| `Transaction` | `hasMany` | `TransactionDetail` |
| `Transaction` | `belongsTo` | `User` (kasir yang memproses) |
| `TransactionDetail` | `belongsTo` | `Transaction` dan `Product` |

> ✅ **Checkpoint:** kelompok sudah punya gambar tabel di atas kertas/papan, dan pembagian tugas Langkah 2-5 sudah disepakati.

### Langkah 2: Relationship `Category` dan `Product`

Buat branch baru dari `main` terbaru, misalnya `category-product-relationships`:

```bash
git checkout main
git pull
git checkout -b category-product-relationships
```

Kedua model ini sudah ada sejak Pertemuan 4, tapi masih kosong (tanpa relationship). Ganti seluruh isi `app/Models/Category.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }
}
```

Ganti seluruh isi `app/Models/Product.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Product extends Model
{
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
```

```bash
git add .
git commit -m "tambah relationship category dan product"
git push -u origin category-product-relationships
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** buka `php artisan tinker`, lalu:
> ```
> >>> Category::first()->products()->count();
> => 75
> >>> Product::find(1)->category->name;
> => "Makanan"
> ```

> ⚠️ **Jika gagal:** error `Call to undefined method` berarti nama method relationship salah ketik, atau lupa menambahkan `use` untuk class relation (`HasMany`/`BelongsTo`) di bagian atas berkas.

### Langkah 3: Model `Transaction` dan `TransactionDetail`

Buat branch baru, misalnya `transaction-models`:

```bash
git checkout main
git pull
git checkout -b transaction-models
php artisan make:model Transaction
php artisan make:model TransactionDetail
```

Kedua model ini belum pernah dibuat sebelumnya, migrasinya sudah ada sejak Pertemuan 4 tapi modelnya belum. Isi `app/Models/Transaction.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Transaction extends Model
{
    public function details(): HasMany
    {
        return $this->hasMany(TransactionDetail::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

Isi `app/Models/TransactionDetail.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

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
```

Nama tabel `transaction_details` sudah otomatis ditebak Eloquent dari nama class `TransactionDetail`: diubah ke snake_case (`transaction_detail`), lalu dijadikan jamak (`transaction_details`), persis konvensi yang sudah dibahas di slide.

```bash
git add .
git commit -m "tambah model transaction dan transaction detail beserta relationship-nya"
git push -u origin transaction-models
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** buka `php artisan tinker`, lalu:
> ```
> >>> Transaction::first()->user->name;
> => "Test User"
> ```

### Langkah 4: Listing produk dengan pagination

`ProductController` sudah ada sejak template `simple-pos-ch02` (Pertemuan 2), berisi versi produksi yang memanggil beberapa hal yang belum kamu buat (form request, upload gambar, penyesuaian stok). Sama seperti `TransactionController` di Pertemuan 3, sederhanakan dulu supaya sesuai dengan yang benar-benar sudah kamu bangun.

Buat branch baru, misalnya `product-listing`:

```bash
git checkout main
git pull
git checkout -b product-listing
```

Ganti seluruh isi `app/Http/Controllers/ProductController.php`:

```php
<?php

namespace App\Http\Controllers;

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
        return 'Form tambah produk (belum dibuat)';
    }

    public function store()
    {
        return 'Produk disimpan (belum ada logika penyimpanan)';
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
php artisan make:view products.index
```

Isi `resources/views/products/index.blade.php`:

```php
@extends('layouts.app')

@section('title', 'Produk')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Daftar Produk</h1>
    <table class="w-full text-left border-collapse">
        <thead>
            <tr class="border-b">
                <th class="py-2 pr-4">Nama</th>
                <th class="py-2 pr-4">Kategori</th>
                <th class="py-2 pr-4">Harga</th>
                <th class="py-2 pr-4">Stok</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($products as $product)
                <tr class="border-b">
                    <td class="py-2 pr-4">{{ $product->name }}</td>
                    <td class="py-2 pr-4">{{ $product->category->name }}</td>
                    <td class="py-2 pr-4">Rp {{ number_format($product->price) }}</td>
                    <td class="py-2 pr-4">{{ $product->stock }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <div class="mt-4">
        {{ $products->links() }}
    </div>
@endsection
```

Tambahkan link navigasi ke `resources/views/components/nav.blade.php`, sisipkan satu baris baru sebelum penutup `</nav>`:

```php
<a href="{{ route('products.index') }}" class="hover:underline">Produk</a>
```

```bash
git add .
git commit -m "tambah listing produk dengan eager loading dan pagination"
git push -u origin product-listing
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** membuka `/products` menampilkan tabel 10 produk dengan nama kategori terisi (bukan error), beserta navigasi halaman di bawahnya. Buka `php artisan tinker`:
> ```
> >>> $p1 = Product::orderBy('name')->paginate(10)->pluck('id');
> >>> $p2 = Product::orderBy('name')->paginate(10, ['*'], 'page', 2)->pluck('id');
> >>> $p1->intersect($p2)->count();
> => 0
> ```

> ⚠️ **Jika gagal:** `View [products.index] not found` berarti `make:view` belum dijalankan atau salah nama folder. Error `Undefined property: $product->category` berarti Langkah 2 (relationship `Product::category()`) belum di-merge atau belum di-pull.

### Langkah 5: Riwayat transaksi dan masalah N+1

Method `index()` di `TransactionController` masih berupa placeholder `return 'Daftar transaksi';` sejak Pertemuan 3. Sekarang saatnya diisi dengan query sungguhan, sambil sekalian membuktikan masalah N+1 yang sudah dibahas di slide.

Buat branch baru, misalnya `transaction-history`:

```bash
git checkout main
git pull
git checkout -b transaction-history
```

Ganti method `index()` di `app/Http/Controllers/TransactionController.php` (method `create`, `store`, dan `show` tetap seperti sebelumnya), dan tambahkan `use App\Models\Transaction;` di bagian atas berkas:

```php
public function index()
{
    $transactions = Transaction::latest()->paginate(15);

    return view('transactions.index', compact('transactions'));
}
```

Buat view lewat artisan:

```bash
php artisan make:view transactions.index
```

Isi `resources/views/transactions/index.blade.php`:

```php
@extends('layouts.app')

@section('title', 'Riwayat Transaksi')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Riwayat Transaksi</h1>

    @foreach ($transactions as $transaction)
        <div class="border rounded-md p-3 mb-3">
            <p class="font-medium">
                Transaksi #{{ $transaction->id }}
                &middot; {{ $transaction->created_at->format('d M Y H:i') }}
                &middot; Rp {{ number_format($transaction->total) }}
            </p>
            <ul class="text-sm text-slate-500 mt-1">
                @foreach ($transaction->details as $detail)
                    <li>{{ $detail->product->name }} &times; {{ $detail->qty }} = Rp {{ number_format($detail->subtotal) }}</li>
                @endforeach
            </ul>
        </div>
    @endforeach

    <div class="mt-4">
        {{ $transactions->links() }}
    </div>
@endsection
```

```bash
git add .
git commit -m "tambah riwayat transaksi dengan pagination"
```

Jangan push dulu. Buka `/transactions` di browser (halamannya tetap tampil, karena relationship `details`/`product` sudah didefinisikan, hanya belum dimuat lebih awal), lalu buktikan masalah N+1 lewat query log:

```bash
php artisan tinker
>>> use Illuminate\Support\Facades\DB;
>>> DB::enableQueryLog();
>>> $transactions = Transaction::latest()->paginate(15);
>>> foreach ($transactions as $t) { foreach ($t->details as $d) { $d->product->name; } }
>>> count(DB::getQueryLog());
```

> ✅ **Checkpoint:** hasilnya puluhan query (jumlah persisnya bervariasi tergantung urutan data, di percobaan kami sekitar 57), jauh lebih banyak dari 15 transaksi yang ditampilkan. Ini masalah N+1: satu query relationship terpisah untuk setiap baris, ditambah untuk tiap detail di dalamnya.

Sekarang perbaiki dengan eager loading. Ubah baris `Transaction::latest()->paginate(15)` di `TransactionController::index()` menjadi:

```php
$transactions = Transaction::with('details.product')
    ->latest()
    ->paginate(15);
```

```bash
git add .
git commit -m "perbaiki n+1 dengan eager loading"
git push -u origin transaction-history
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** ulangi pengukuran query log yang sama (dengan `with('details.product')` kali ini). Hasilnya turun menjadi 4 query total: satu untuk menghitung total transaksi (dipakai `paginate()` menghitung jumlah halaman), satu untuk daftar transaksi, satu untuk seluruh detailnya, dan satu untuk seluruh produknya sekaligus, bukan puluhan query terpisah. Angka ini sedikit lebih banyak dari 2 query pada contoh sederhana di slide, karena `paginate()` menambahkan satu query hitung di atas eager loading dasar.

> ⚠️ **Jika gagal:** kalau jumlah query masih puluhan setelah menambahkan `with()`, periksa apakah `$d->product->name` di dalam foreach benar-benar mengakses `$detail->product` (relationship yang sudah dimuat), bukan diam-diam memicu query baru karena salah ketik nama properti.

### Langkah 6: Bersama, uji integrasi dan review kode

Semua anggota `git checkout main && git pull`, jalankan `php artisan migrate:fresh --seed`, lalu ulangi seluruh checkpoint di laptop masing-masing: relationship di tinker, `/products` dengan pagination, dan query log `/transactions` sebelum/sesudah eager loading. Setelah itu, kelompok membaca kode bersama: setiap anggota menjelaskan satu model atau controller yang **bukan** ia tulis sendiri.

> ✅ **Checkpoint:** seluruh checkpoint di atas berhasil diulang dan menunjukkan hasil yang sama persis di setiap laptop anggota.

### Langkah 7: Tantangan mandiri kelompok dan commit `increment 5`

Bagi tugas berikut di antara anggota, supaya setiap anggota tercatat minimal satu commit bermakna lewat Pull Request masing-masing:

- Tampilkan nama kasir pada `/transactions` dengan menambahkan `'user'` ke `with(['details.product', 'user'])`, lalu tampilkan `$transaction->user->name` di view.
- Tambahkan relationship `belongsToMany` dari `Product` ke `Transaction` lewat pivot `transaction_details`, lalu buktikan di tinker lewat `Product::find(1)->transactions()->count()`.
- Tambahkan method `Product::details(): HasMany` (ke `TransactionDetail`), lalu hitung total unit terjual satu produk lewat `Product::find(1)->details()->sum('qty')` di tinker.
- Ubah grid produk di `/pos` dari `Product::take(12)->get()` menjadi `Product::paginate(12)` beserta `{{ $products->links() }}` di view, lalu buktikan halaman 2 menampilkan produk berbeda.
- Tampilkan jumlah item per transaksi di `/transactions` lewat `$transaction->details->sum('qty')` (tanpa query tambahan, karena `details` sudah dimuat lewat eager loading).

Setiap tugas: buat branch baru (misalnya `cashier-name`), kerjakan, commit, push, lalu buka dan merge Pull Request-nya (ikuti alur Langkah 3 Pertemuan 3).

Setelah semua Pull Request masuk dan digabungkan, salah satu anggota menutup pekerjaan kelompok:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 5: relationship eloquent, eager loading, dan pagination simple pos"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** baris teratas `git log --pretty="%h %an %s"` menunjukkan `increment 5: ...`, dan baris-baris di bawahnya menunjukkan nama setiap anggota kelompok.

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta dosen:

- Link repositori GitHub kelompok.
- Screenshot halaman `/products` (dengan nomor halaman terlihat) dan `/transactions`.
- Screenshot hasil tinker: relationship (`Category::first()->products()->count()`), pluck dua halaman, dan jumlah query log sebelum/sesudah eager loading.
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel pembagian tugas: nama anggota | langkah/tugas yang dikerjakan | hash commit.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---:|---|---|
| Langkah kerja tuntas (kelompok) | 40% | Langkah 1-7 selesai, `/products` dan `/transactions` berfungsi dengan eager loading | Sebagian besar langkah selesai, kedua halaman tampil |
| Checkpoint terverifikasi (kelompok) | 25% | Screenshot tinker, query log, dan git log lengkap dan benar | Sebagian checkpoint terbukti |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna atas nama tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Kerapian repositori dan commit | 10% | Pesan `increment 5` persis, tanpa menyertakan `vendor/`, `node_modules/`, `.env`, PR di-merge rapi (bukan squash) | Commit ada, pesan kurang rapi atau PR di-squash |
