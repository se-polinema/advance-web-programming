# Jobsheet Praktikum Kelompok: Pertemuan 9
## Pengolahan Data: Import, Export, dan Queue (Kerja Kelompok)

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | 9 (Minggu 9) |
| **Durasi** | 2 sesi &times; 170 menit (Sesi 1: Langkah 1-6, Sesi 2: Langkah 7-10) |
| **Sub-CPMK** | Sub-CPMK 4: Mahasiswa mampu mengembangkan aplikasi web berbasis framework sesuai dengan kebutuhan pengguna. |
| **Mode Pengerjaan** | Kelompok (sama seperti Pertemuan 3-7), satu repositori GitHub bersama per kelompok |
| **Kode Awal** | repositori kelompok hasil Pertemuan 7 (lanjutkan `main`-nya; Pertemuan 8 adalah UTS tanpa materi kode baru). Kalau repositori kelompok bermasalah, buat salinan dari template `github.com/se-polinema/simple-pos-ch07` lewat **Use this template** |

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet kelompok ini, kamu mampu:

1. Menyusun halaman laporan penjualan dengan filter rentang tanggal, dengan aggregation yang dikerjakan di database.
2. Meng-export laporan ke tiga format (CSV, Excel, PDF) dan menjelaskan kapan masing-masing format tepat dipakai.
3. Mengukur dan membandingkan pemakaian memori `get()` dengan `lazyById()` pada dataset besar.
4. Membangun import produk dari file CSV yang memvalidasi tiap row, melewati row yang cacat, dan aman diulang (idempotent).
5. Memindahkan import ke queued job dengan `$tries`, `backoff`, dan `$timeout`, memeriksa job di tabel `jobs`, dan menelusuri job yang gagal lewat `failed_jobs`.

## B. Persiapan dan Prasyarat

- **Alat**: sama seperti Pertemuan 3-7 (PHP 8.2+, Composer, Node.js, Git).
- **Ekstensi PHP**: Laravel Excel dan DomPDF membutuhkan ekstensi `zip` dan `gd`. Cek dengan perintah berikut, dan aktifkan lewat `php.ini` kalau belum muncul:
  ```bash
  php -m | grep -E "zip|gd"
  ```
  > ✅ **Checkpoint:** kedua nama `gd` dan `zip` muncul di output.
- **Identitas git**: sudah diatur sejak Pertemuan 3.
- **Verifikasi cepat** sebelum mulai:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  php artisan migrate:fresh --seed
  ```
  > ✅ **Checkpoint:** baris teratas menunjukkan commit `increment 7: ...`, dan perintah `migrate:fresh --seed` berjalan tanpa error.

## C. Langkah Kerja

Alur kerja sama seperti Pertemuan 3-7: setiap langkah dikerjakan di branch terpisah dari `main`, digabungkan lewat Pull Request dengan **Create a merge commit** (bukan squash), lalu semua anggota `git pull` sebelum membuat branch berikutnya.

Gambaran besar pertemuan ini seperti dapur restoran. Data mentah masuk (extract), dimasak jadi hidangan (transform), lalu disajikan dalam beberapa bentuk: CSV, Excel, atau PDF (load). Kalau pesanan membludak, dapur tidak menyuruh tamu menunggu di depan kompor: tamu diberi nomor meja, hidangan diantar belakangan. Itulah peran queue di Langkah 8.

### Langkah 1: Menyiapkan branch dan membagi tugas

Buat branch baru dari `main` terbaru, misalnya `sales-report`:

```bash
git checkout main
git pull
git checkout -b sales-report
php artisan make:controller ReportController
```

Sepakati pembagian langkah 2 sampai 8 antaranggota.

> ✅ **Checkpoint:** file `app/Http/Controllers/ReportController.php` sudah dibuat (masih kosong), dan branch `sales-report` sudah aktif.

### Langkah 2: Laporan penjualan dengan filter tanggal

Halaman transaksi itu seperti tumpukan struk di laci kasir: semua ada, tapi kamu harus menjumlahkannya sendiri. Halaman laporan seperti rekap akhir bulan: bukan "transaksi apa saja yang terjadi", tapi "berapa total penjualan pada rentang waktu tertentu", sudah dijumlahkan dan siap dibaca.

Isi `app/Http/Controllers/ReportController.php` menjadi:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $query->sum('total'),
            'jumlahTransaksi' => $query->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredQuery($from, $to): Builder
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to]);
    }
}
```

`resolveDateRange()` memberi nilai default (bulan berjalan) kalau pengguna belum mengisi filter sama sekali. `startOfDay()`/`endOfDay()` mencegah jebakan hari terakhir: tanpa `endOfDay()`, filter "sampai 31 Agustus" berhenti di jam 00:00 tanggal 31, sehingga semua transaksi yang terjadi sepanjang tanggal 31 ikut hilang dari laporan.

`filteredQuery()` hanya menyiapkan query dan belum menjalankannya. `sum()` dan `count()` di `index()` dikerjakan langsung oleh database, jadi ribuan row transaksi tidak perlu dimuat ke memori hanya untuk dijumlahkan. Query yang sama dipakai ulang di langkah-langkah berikutnya untuk semua format export, supaya logika filter tidak ditulis tiga kali.

Buat view-nya:

```bash
php artisan make:view reports.index
```

Isi `resources/views/reports/index.blade.php` menjadi:

```php
@extends('layouts.app')

@section('title', 'Laporan Penjualan')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Laporan Penjualan</h1>

    <form method="GET" action="{{ route('reports.index') }}" class="flex gap-3 items-end mb-6">
        <label class="block">
            <span class="text-sm font-medium">Dari</span>
            <input type="date" name="from" value="{{ $from }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <label class="block">
            <span class="text-sm font-medium">Sampai</span>
            <input type="date" name="to" value="{{ $to }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <button type="submit" class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm">Filter</button>
    </form>

    <div class="bg-white border rounded-md p-4 max-w-sm">
        <p class="text-sm text-slate-500">Total Penjualan</p>
        <p class="text-2xl font-semibold">Rp {{ number_format($totalPenjualan) }}</p>
        <p class="text-sm text-slate-500 mt-2">{{ $jumlahTransaksi }} transaksi</p>
    </div>
@endsection
```

Isi `routes/web.php` menjadi (perhatikan `use` untuk `ReportController` dan route baru di dalam grup `role:admin`):

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('pos.create');
});

Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'create'])->name('login');
    Route::post('/login', [LoginController::class, 'store']);
});

Route::post('/logout', [LoginController::class, 'destroy'])
    ->middleware('auth')
    ->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions.index');

    Route::middleware('role:admin')->group(function () {
        Route::resource('categories', CategoryController::class)->except('show');
        Route::resource('products', ProductController::class)->except(['show', 'destroy']);
        Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
    });
});
```

Tambahkan link navigasi dengan mengisi `resources/views/components/nav.blade.php` menjadi:

```php
<nav class="bg-slate-900 text-white px-4 py-3 flex gap-4 items-center">
    <span class="font-semibold">Simple POS</span>
    <a href="{{ route('pos.create') }}" class="hover:underline">Kasir</a>
    <a href="{{ route('transactions.index') }}" class="hover:underline">Transaksi</a>
    @if (auth()->user()?->isAdmin())
        <a href="{{ route('products.index') }}" class="hover:underline">Produk</a>
        <a href="{{ route('categories.index') }}" class="hover:underline">Kategori</a>
        <a href="{{ route('reports.index') }}" class="hover:underline">Laporan</a>
    @endif
    <span class="ml-auto text-sm">{{ auth()->user()?->name }} ({{ auth()->user()?->role }})</span>
    <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button class="hover:underline">Keluar</button>
    </form>
</nav>
```

```bash
git add .
git commit -m "tambah laporan penjualan dengan filter tanggal"
git push -u origin sales-report
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** login sebagai admin, buka `/reports`. Total penjualan dan jumlah transaksi tampil sesuai data bulan berjalan. Ubah filter ke rentang tanggal yang pasti tidak ada transaksinya (misalnya tahun 2020): total berubah jadi Rp 0 dan 0 transaksi.

> ⚠️ **Jika gagal:** total yang tidak berubah sama sekali walau filter diganti berarti `resolveDateRange()` tidak membaca `$request->date('from')`/`$request->date('to')` dengan benar, periksa atribut `name="from"`/`name="to"` pada input tanggal di view. Error `Class "App\Http\Controllers\ReportController" not found` berarti baris `use App\Http\Controllers\ReportController;` di `routes/web.php` belum ada.

### Langkah 3: Export laporan ke CSV (streaming)

Export CSV itu seperti keran, bukan ember. Cara ember: tampung semua row dulu di memori, baru kirim. Cara keran: alirkan row demi row. Branch baru dari `main` terbaru, misalnya `csv-export`:

```bash
git checkout main
git pull
git checkout -b csv-export
```

Isi `app/Http/Controllers/ReportController.php` menjadi:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $query->sum('total'),
            'jumlahTransaksi' => $query->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function exportCsv(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($query->lazyById() as $t) {
                fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
            }
            fclose($out);
        }, 'laporan-penjualan.csv');
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredQuery($from, $to): Builder
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to]);
    }
}
```

`exportCsv()` memakai ulang `resolveDateRange()` dan `filteredQuery()`, jadi CSV menghormati filter tanggal yang sama dengan halaman laporan. `lazyById()` mengambil data dari database per chunk kecil, dan `streamDownload()` langsung menulis tiap row ke browser, jadi memori server tetap datar berapa pun jumlah transaksinya.

`streamDownload()` perlu dideklarasikan dengan tipe pengembalian `StreamedResponse` dari Symfony, bukan `Illuminate\Http\Response`; kalau tipenya salah, PHP akan melempar `TypeError` begitu method ini dipanggil.

Isi `routes/web.php` menjadi:

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('pos.create');
});

Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'create'])->name('login');
    Route::post('/login', [LoginController::class, 'store']);
});

Route::post('/logout', [LoginController::class, 'destroy'])
    ->middleware('auth')
    ->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions.index');

    Route::middleware('role:admin')->group(function () {
        Route::resource('categories', CategoryController::class)->except('show');
        Route::resource('products', ProductController::class)->except(['show', 'destroy']);
        Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
        Route::get('/reports/export/csv', [ReportController::class, 'exportCsv'])->name('reports.export.csv');
    });
});
```

Isi `resources/views/reports/index.blade.php` menjadi (tombol **Export CSV** ditambahkan setelah tombol `Filter`):

```php
@extends('layouts.app')

@section('title', 'Laporan Penjualan')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Laporan Penjualan</h1>

    <form method="GET" action="{{ route('reports.index') }}" class="flex gap-3 items-end mb-6">
        <label class="block">
            <span class="text-sm font-medium">Dari</span>
            <input type="date" name="from" value="{{ $from }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <label class="block">
            <span class="text-sm font-medium">Sampai</span>
            <input type="date" name="to" value="{{ $to }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <button type="submit" class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm">Filter</button>
        <a href="{{ route('reports.export.csv', ['from' => $from, 'to' => $to]) }}" class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm">Export CSV</a>
    </form>

    <div class="bg-white border rounded-md p-4 max-w-sm">
        <p class="text-sm text-slate-500">Total Penjualan</p>
        <p class="text-2xl font-semibold">Rp {{ number_format($totalPenjualan) }}</p>
        <p class="text-sm text-slate-500 mt-2">{{ $jumlahTransaksi }} transaksi</p>
    </div>
@endsection
```

```bash
git add .
git commit -m "tambah export laporan penjualan ke CSV"
git push -u origin csv-export
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** klik tombol "Export CSV" di halaman `/reports`. File `laporan-penjualan.csv` ter-download, row pertamanya `ID,Tanggal,Kasir,Total`, dan row-row berikutnya berisi data transaksi sesuai filter tanggal yang sedang aktif.

> ⚠️ **Jika gagal:** error `TypeError: ... Return value must be of type Illuminate\Http\Response` berarti `use Symfony\Component\HttpFoundation\StreamedResponse;` belum ditambahkan, atau tipe kembalian method `exportCsv()` masih `Response`.

### Langkah 4: Mengukur pemakaian memori (`get()` vs `lazyById()`)

Dengan 2.500 transaksi hasil seeder, `get()` dan `lazyById()` terasa sama saja. Masalah memori baru muncul saat data membengkak. Bayangkan meja kerja: `get()` menaruh semua dokumen di atas meja sekaligus, sedangkan `lazyById()` mengambilnya segenggam demi segenggam dari lemari. Di langkah ini kamu mengukurnya sendiri, bukan hanya percaya teori.

Branch baru dari `main` terbaru, misalnya `memory-benchmark`:

```bash
git checkout main
git pull
git checkout -b memory-benchmark
php artisan tinker
```

Di dalam tinker, tambahkan 50.000 transaksi dummy supaya totalnya sekitar 52.500 row:

```php
use Illuminate\Support\Facades\DB;

for ($i = 0; $i < 20; $i++) {
    DB::table('transactions')->insert(array_map(fn () => [
        'user_id' => 1,
        'total' => 10000,
        'created_at' => now(),
        'updated_at' => now(),
    ], range(1, 2500)));
}

DB::table('transactions')->count();
```

Lalu ukur dua cara membaca data. `memory_reset_peak_usage()` membuat angka peak dihitung ulang sebelum tiap pengukuran, jadi hasil keduanya tidak saling mempengaruhi:

```php
use App\Models\Transaction;

$ukur = function (string $label, callable $fn) {
    gc_collect_cycles();
    memory_reset_peak_usage();
    $jumlah = $fn();
    printf("%-12s %6d row, peak %.1f MB\n", $label, $jumlah, memory_get_peak_usage() / 1048576);
};

$ukur('lazyById()', function () {
    $n = 0;
    foreach (Transaction::lazyById() as $t) {
        $n++;
    }
    return $n;
});

$ukur('get()', fn () => Transaction::get()->count());
```

Keluar dari tinker (`exit`), lalu kembalikan data ke kondisi normal supaya angka di laporan tidak terdistorsi:

```bash
php artisan migrate:fresh --seed
```

Catat hasilnya. Isi `docs/pengukuran-memori.md` menjadi (ganti `...` dengan angka hasil ukurmu):

```markdown
# Pengukuran Memori: get() vs lazyById()

Dataset: sekitar 52.500 row pada tabel `transactions`.

| Cara baca data | Peak memory (MB) |
|---|---|
| `Transaction::lazyById()` | ... |
| `Transaction::get()` | ... |

Kesimpulan kelompok: ...
```

```bash
git add .
git commit -m "catat hasil pengukuran memori get vs lazyById"
git push -u origin memory-benchmark
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** peak memory `get()` jauh lebih besar daripada `lazyById()`. Di laptop pengajar dengan 52.500 row, hasilnya sekitar 96 MB untuk `get()` dan 38 MB untuk `lazyById()`. Angka di laptopmu akan berbeda, tapi selisihnya harus jelas terlihat. Perhatikan juga: makin besar datanya, makin lebar jaraknya, dan `get()` bisa menabrak `memory_limit` PHP.

> ⚠️ **Jika gagal:** kalau kedua angka hampir sama, pastikan jumlah row benar-benar sekitar 52.500 (hasil `count()` di langkah pertama), dan pastikan kamu mengukur `lazyById()` dengan `$ukur(...)` seperti di atas (bukan `get()` dua kali). Error `Call to undefined function memory_reset_peak_usage()` berarti versi PHP kamu di bawah 8.2.

### Langkah 5: Export ke Excel dengan Laravel Excel

CSV cukup untuk data mentah, tapi bagian keuangan biasanya ingin file `.xlsx` yang langsung rapi: header jelas, lebar column pas. Library spreadsheet mengurus format `.xlsx` yang rumit itu (sebenarnya file zip berisi XML) supaya kamu cukup mendeskripsikan isinya: sumber data, header, dan cara memetakan tiap row.

Branch baru dari `main` terbaru, misalnya `excel-export`, lalu install library-nya dan buat class export dengan generator-nya:

```bash
git checkout main
git pull
git checkout -b excel-export
composer require maatwebsite/excel:^3.1
php artisan make:export SalesReportExport
```

Isi `app/Exports/SalesReportExport.php` menjadi:

```php
<?php

namespace App\Exports;

use Illuminate\Database\Eloquent\Builder;
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class SalesReportExport implements FromQuery, WithHeadings, WithMapping, ShouldAutoSize
{
    public function __construct(private Builder $query) {}

    public function query(): Builder
    {
        return $this->query;
    }

    public function headings(): array
    {
        return ['ID', 'Tanggal', 'Kasir', 'Total'];
    }

    public function map($transaction): array
    {
        return [
            $transaction->id,
            $transaction->created_at->format('Y-m-d H:i:s'),
            $transaction->user->name,
            $transaction->total,
        ];
    }
}
```

`FromQuery` menyerahkan pembacaan data ke library: query dibaca per chunk di balik layar, jadi memori tetap terjaga. `WithHeadings` menulis baris judul, `WithMapping` menentukan isi tiap row, dan `ShouldAutoSize` menyesuaikan lebar column. Class ini menerima query yang sama dengan halaman laporan, jadi filter tanggal otomatis ikut.

Isi `app/Http/Controllers/ReportController.php` menjadi:

```php
<?php

namespace App\Http\Controllers;

use App\Exports\SalesReportExport;
use App\Models\Transaction;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $query->sum('total'),
            'jumlahTransaksi' => $query->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function exportCsv(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($query->lazyById() as $t) {
                fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
            }
            fclose($out);
        }, 'laporan-penjualan.csv');
    }

    public function exportExcel(Request $request): BinaryFileResponse
    {
        [$from, $to] = $this->resolveDateRange($request);

        return Excel::download(
            new SalesReportExport($this->filteredQuery($from, $to)),
            'laporan-penjualan.xlsx',
        );
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredQuery($from, $to): Builder
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to]);
    }
}
```

Isi `routes/web.php` menjadi:

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('pos.create');
});

Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'create'])->name('login');
    Route::post('/login', [LoginController::class, 'store']);
});

Route::post('/logout', [LoginController::class, 'destroy'])
    ->middleware('auth')
    ->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions.index');

    Route::middleware('role:admin')->group(function () {
        Route::resource('categories', CategoryController::class)->except('show');
        Route::resource('products', ProductController::class)->except(['show', 'destroy']);
        Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
        Route::get('/reports/export/csv', [ReportController::class, 'exportCsv'])->name('reports.export.csv');
        Route::get('/reports/export/xlsx', [ReportController::class, 'exportExcel'])->name('reports.export.xlsx');
    });
});
```

Isi `resources/views/reports/index.blade.php` menjadi (tombol **Export Excel** ditambahkan):

```php
@extends('layouts.app')

@section('title', 'Laporan Penjualan')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Laporan Penjualan</h1>

    <form method="GET" action="{{ route('reports.index') }}" class="flex gap-3 items-end mb-6">
        <label class="block">
            <span class="text-sm font-medium">Dari</span>
            <input type="date" name="from" value="{{ $from }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <label class="block">
            <span class="text-sm font-medium">Sampai</span>
            <input type="date" name="to" value="{{ $to }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <button type="submit" class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm">Filter</button>
        <a href="{{ route('reports.export.csv', ['from' => $from, 'to' => $to]) }}" class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm">Export CSV</a>
        <a href="{{ route('reports.export.xlsx', ['from' => $from, 'to' => $to]) }}" class="bg-green-600 text-white px-4 py-2 rounded-md text-sm">Export Excel</a>
    </form>

    <div class="bg-white border rounded-md p-4 max-w-sm">
        <p class="text-sm text-slate-500">Total Penjualan</p>
        <p class="text-2xl font-semibold">Rp {{ number_format($totalPenjualan) }}</p>
        <p class="text-sm text-slate-500 mt-2">{{ $jumlahTransaksi }} transaksi</p>
    </div>
@endsection
```

```bash
git add .
git commit -m "tambah export laporan penjualan ke Excel"
git push -u origin excel-export
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull (jalankan juga `composer install` karena ada dependency baru).

> ✅ **Checkpoint:** klik "Export Excel" di `/reports`. File `laporan-penjualan.xlsx` ter-download dan terbuka di Excel atau LibreOffice dengan header `ID`, `Tanggal`, `Kasir`, `Total`, dan row-row yang sesuai filter tanggal.

> ⚠️ **Jika gagal:** error `Class "ZipArchive" not found` atau pesan soal ekstensi `gd` berarti ekstensi PHP `zip`/`gd` belum aktif (lihat Bagian B). Error `Class "App\Exports\SalesReportExport" not found` berarti file export belum dibuat lewat `make:export` atau namespace-nya salah. Setelah anggota lain pull, lupa `composer install` akan membuat error `Class "Maatwebsite\Excel\Facades\Excel" not found`.

### Langkah 6: Laporan PDF dengan DomPDF

PDF cocok untuk dokumen yang akan dibaca atau dicetak, bukan untuk diolah lagi: ia seperti memotret rekap akhir bulan. DomPDF bekerja dengan cara sederhana: kamu menulis view Blade biasa, lalu library mengubah HTML-nya menjadi PDF. Konsekuensinya, DomPDF memuat seluruh dokumen di memori, jadi PDF tidak cocok untuk puluhan ribu row. Karena itu laporan PDF kita hanya menampilkan ringkasan total dan 50 transaksi terbaru.

Branch baru dari `main` terbaru, misalnya `pdf-report`:

```bash
git checkout main
git pull
git checkout -b pdf-report
composer require barryvdh/laravel-dompdf
php artisan make:view reports.pdf
```

Isi `resources/views/reports/pdf.blade.php` menjadi (view ini berdiri sendiri, tidak memakai `layouts.app`, karena PDF tidak butuh navigasi dan Vite):

```php
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Laporan Penjualan</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size: 12px; }
        h1 { font-size: 18px; margin-bottom: 4px; }
        table { width: 100%; border-collapse: collapse; margin-top: 12px; }
        th, td { border: 1px solid #999; padding: 4px 8px; text-align: left; }
        th { background: #eee; }
        .right { text-align: right; }
    </style>
</head>
<body>
    <h1>Laporan Penjualan</h1>
    <p>Periode {{ $from }} s.d. {{ $to }}</p>
    <p>Total penjualan: <strong>Rp {{ number_format($totalPenjualan) }}</strong> dari {{ $jumlahTransaksi }} transaksi</p>

    <p>50 transaksi terbaru pada periode ini:</p>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Tanggal</th>
                <th>Kasir</th>
                <th class="right">Total</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($transactions as $t)
                <tr>
                    <td>{{ $t->id }}</td>
                    <td>{{ $t->created_at->format('Y-m-d H:i') }}</td>
                    <td>{{ $t->user->name }}</td>
                    <td class="right">Rp {{ number_format($t->total) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
```

Isi `app/Http/Controllers/ReportController.php` menjadi:

```php
<?php

namespace App\Http\Controllers;

use App\Exports\SalesReportExport;
use App\Models\Transaction;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\View\View;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $query->sum('total'),
            'jumlahTransaksi' => $query->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function exportCsv(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($query->lazyById() as $t) {
                fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
            }
            fclose($out);
        }, 'laporan-penjualan.csv');
    }

    public function exportExcel(Request $request): BinaryFileResponse
    {
        [$from, $to] = $this->resolveDateRange($request);

        return Excel::download(
            new SalesReportExport($this->filteredQuery($from, $to)),
            'laporan-penjualan.xlsx',
        );
    }

    public function exportPdf(Request $request): Response
    {
        [$from, $to] = $this->resolveDateRange($request);

        $pdf = Pdf::loadView('reports.pdf', [
            'totalPenjualan' => $this->filteredQuery($from, $to)->sum('total'),
            'jumlahTransaksi' => $this->filteredQuery($from, $to)->count(),
            'transactions' => $this->filteredQuery($from, $to)->latest()->limit(50)->get(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);

        return $pdf->download('laporan-penjualan.pdf');
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredQuery($from, $to): Builder
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to]);
    }
}
```

Perhatikan `limit(50)`: batas ini disengaja. Ringkasan total tetap dihitung dari seluruh data lewat `sum()` dan `count()` di database, sedangkan tabel rinci dibatasi supaya PDF tetap ringan.

Isi `routes/web.php` menjadi:

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('pos.create');
});

Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'create'])->name('login');
    Route::post('/login', [LoginController::class, 'store']);
});

Route::post('/logout', [LoginController::class, 'destroy'])
    ->middleware('auth')
    ->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions.index');

    Route::middleware('role:admin')->group(function () {
        Route::resource('categories', CategoryController::class)->except('show');
        Route::resource('products', ProductController::class)->except(['show', 'destroy']);
        Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
        Route::get('/reports/export/csv', [ReportController::class, 'exportCsv'])->name('reports.export.csv');
        Route::get('/reports/export/xlsx', [ReportController::class, 'exportExcel'])->name('reports.export.xlsx');
        Route::get('/reports/export/pdf', [ReportController::class, 'exportPdf'])->name('reports.export.pdf');
    });
});
```

Isi `resources/views/reports/index.blade.php` menjadi (tombol **Export PDF** ditambahkan):

```php
@extends('layouts.app')

@section('title', 'Laporan Penjualan')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Laporan Penjualan</h1>

    <form method="GET" action="{{ route('reports.index') }}" class="flex gap-3 items-end mb-6">
        <label class="block">
            <span class="text-sm font-medium">Dari</span>
            <input type="date" name="from" value="{{ $from }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <label class="block">
            <span class="text-sm font-medium">Sampai</span>
            <input type="date" name="to" value="{{ $to }}" class="mt-1 block border rounded-md px-3 py-2 text-sm">
        </label>
        <button type="submit" class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm">Filter</button>
        <a href="{{ route('reports.export.csv', ['from' => $from, 'to' => $to]) }}" class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm">Export CSV</a>
        <a href="{{ route('reports.export.xlsx', ['from' => $from, 'to' => $to]) }}" class="bg-green-600 text-white px-4 py-2 rounded-md text-sm">Export Excel</a>
        <a href="{{ route('reports.export.pdf', ['from' => $from, 'to' => $to]) }}" class="bg-red-600 text-white px-4 py-2 rounded-md text-sm">Export PDF</a>
    </form>

    <div class="bg-white border rounded-md p-4 max-w-sm">
        <p class="text-sm text-slate-500">Total Penjualan</p>
        <p class="text-2xl font-semibold">Rp {{ number_format($totalPenjualan) }}</p>
        <p class="text-sm text-slate-500 mt-2">{{ $jumlahTransaksi }} transaksi</p>
    </div>
@endsection
```

```bash
git add .
git commit -m "tambah laporan penjualan dalam format PDF"
git push -u origin pdf-report
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull (jalankan juga `composer install`).

> ✅ **Checkpoint:** klik "Export PDF" di `/reports`. File `laporan-penjualan.pdf` ter-download, berisi judul, periode, total penjualan, dan tabel maksimal 50 transaksi.

> ⚠️ **Jika gagal:** halaman PDF kosong atau error `View [reports.pdf] not found` berarti file view belum dibuat di `resources/views/reports/pdf.blade.php`. Tulisan miring atau karakter aneh biasanya berarti `<meta charset="utf-8">` atau font `DejaVu Sans` pada CSS belum ada.

> Diskusi kelompok (jawab singkat di README): untuk laporan 100.000 transaksi, format mana yang kalian pilih (CSV, Excel, atau PDF), dan kenapa?

### Langkah 7: Import produk dari CSV (aman diulang)

Import itu seperti kasir yang memindai belanjaan. Kalau satu barcode rusak, kasir menyisihkan barang itu dan terus memindai sisanya, bukan menyuruh semua pelanggan pulang. Ada satu hal lagi: bagaimana kalau file yang sama di-upload dua kali? Tanpa penjagaan, setiap produk akan tercatat dobel. Solusinya `updateOrCreate()`: seperti daftar hadir, kalau namanya sudah ada, cukup perbarui barisnya, jangan tulis lagi di baris baru. Sifat ini disebut **idempotent**: dijalankan berkali-kali, hasil akhirnya sama.

Branch baru dari `main` terbaru, misalnya `csv-import`:

```bash
git checkout main
git pull
git checkout -b csv-import
```

Isi `app/Http/Controllers/ReportController.php` menjadi:

```php
<?php

namespace App\Http\Controllers;

use App\Exports\SalesReportExport;
use App\Models\Product;
use App\Models\Transaction;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Validator;
use Illuminate\View\View;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $query->sum('total'),
            'jumlahTransaksi' => $query->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function exportCsv(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($query->lazyById() as $t) {
                fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
            }
            fclose($out);
        }, 'laporan-penjualan.csv');
    }

    public function exportExcel(Request $request): BinaryFileResponse
    {
        [$from, $to] = $this->resolveDateRange($request);

        return Excel::download(
            new SalesReportExport($this->filteredQuery($from, $to)),
            'laporan-penjualan.xlsx',
        );
    }

    public function exportPdf(Request $request): Response
    {
        [$from, $to] = $this->resolveDateRange($request);

        $pdf = Pdf::loadView('reports.pdf', [
            'totalPenjualan' => $this->filteredQuery($from, $to)->sum('total'),
            'jumlahTransaksi' => $this->filteredQuery($from, $to)->count(),
            'transactions' => $this->filteredQuery($from, $to)->latest()->limit(50)->get(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);

        return $pdf->download('laporan-penjualan.pdf');
    }

    public function importForm(): View
    {
        return view('reports.import');
    }

    public function import(Request $request): RedirectResponse
    {
        $request->validate([
            'csv' => ['required', 'file', 'mimes:csv,txt'],
        ]);

        $lines = file($request->file('csv')->getRealPath(), FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        $rows = array_map('str_getcsv', $lines);
        $header = array_shift($rows);

        $created = 0;
        $updated = 0;
        foreach ($rows as $row) {
            if (count($row) !== count($header)) {
                continue;
            }

            $validator = Validator::make(array_combine($header, $row), [
                'name' => ['required', 'string'],
                'category_id' => ['required', 'exists:categories,id'],
                'price' => ['required', 'integer', 'min:0'],
            ]);

            if ($validator->fails()) {
                continue;
            }

            $data = $validator->validated();
            $product = Product::updateOrCreate(
                ['name' => $data['name'], 'category_id' => $data['category_id']],
                ['price' => $data['price']],
            );

            $product->wasRecentlyCreated ? $created++ : $updated++;
        }

        return back()->with('success', "{$created} produk baru, {$updated} diperbarui.");
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredQuery($from, $to): Builder
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to]);
    }
}
```

`continue` pada row yang gagal validasi membuat proses import tetap lanjut ke row berikutnya, bukan berhenti total hanya karena satu row salah ketik. `FILE_SKIP_EMPTY_LINES` membuang baris kosong, dan pengecekan `count($row) !== count($header)` melewati row yang jumlah column-nya tidak sesuai, supaya `array_combine()` tidak melempar error. `updateOrCreate()` mencari produk dengan `name` dan `category_id` yang sama: kalau ada, hanya `price`-nya yang diperbarui, kalau belum ada, produknya dibuat. `wasRecentlyCreated` memberi tahu mana yang baru dibuat.

Buat view-nya:

```bash
php artisan make:view reports.import
```

Isi `resources/views/reports/import.blade.php` menjadi:

```php
@extends('layouts.app')

@section('title', 'Import Produk')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Import Produk dari CSV</h1>

    @if (session('success'))
        <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
            {{ session('success') }}
        </div>
    @endif

    <form method="POST" action="{{ route('import.store') }}" enctype="multipart/form-data" class="max-w-md">
        @csrf
        <label class="block mb-3">
            <span class="text-sm font-medium">File CSV</span>
            <input type="file" name="csv" accept=".csv" class="mt-1 block w-full text-sm">
            @error('csv')
                <p class="text-sm text-red-600 mt-1">{{ $message }}</p>
            @enderror
        </label>
        <p class="text-xs text-slate-500 mb-3">Column yang dibutuhkan: <code>name</code>, <code>category_id</code>, <code>price</code>.</p>
        <button type="submit" class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm">Import</button>
    </form>
@endsection
```

Isi `routes/web.php` menjadi:

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('pos.create');
});

Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'create'])->name('login');
    Route::post('/login', [LoginController::class, 'store']);
});

Route::post('/logout', [LoginController::class, 'destroy'])
    ->middleware('auth')
    ->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions.index');

    Route::middleware('role:admin')->group(function () {
        Route::resource('categories', CategoryController::class)->except('show');
        Route::resource('products', ProductController::class)->except(['show', 'destroy']);
        Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
        Route::get('/reports/export/csv', [ReportController::class, 'exportCsv'])->name('reports.export.csv');
        Route::get('/reports/export/xlsx', [ReportController::class, 'exportExcel'])->name('reports.export.xlsx');
        Route::get('/reports/export/pdf', [ReportController::class, 'exportPdf'])->name('reports.export.pdf');
        Route::get('/import', [ReportController::class, 'importForm'])->name('import.create');
        Route::post('/import', [ReportController::class, 'import'])->name('import.store');
    });
});
```

Isi `resources/views/components/nav.blade.php` menjadi (link **Import** ditambahkan):

```php
<nav class="bg-slate-900 text-white px-4 py-3 flex gap-4 items-center">
    <span class="font-semibold">Simple POS</span>
    <a href="{{ route('pos.create') }}" class="hover:underline">Kasir</a>
    <a href="{{ route('transactions.index') }}" class="hover:underline">Transaksi</a>
    @if (auth()->user()?->isAdmin())
        <a href="{{ route('products.index') }}" class="hover:underline">Produk</a>
        <a href="{{ route('categories.index') }}" class="hover:underline">Kategori</a>
        <a href="{{ route('reports.index') }}" class="hover:underline">Laporan</a>
        <a href="{{ route('import.create') }}" class="hover:underline">Import</a>
    @endif
    <span class="ml-auto text-sm">{{ auth()->user()?->name }} ({{ auth()->user()?->role }})</span>
    <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button class="hover:underline">Keluar</button>
    </form>
</nav>
```

```bash
git add .
git commit -m "tambah import produk dari CSV"
git push -u origin csv-import
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** buat file `produk.csv` berisi:
> ```
> name,category_id,price
> Kopi Hitam,1,15000
> Teh Manis,1,10000
> Produk Tanpa Kategori,999,5000
> ```
> (sesuaikan `category_id` dengan kategori yang benar-benar ada di datamu). Upload lewat `/import`. **Yang diharapkan:** pesan "2 produk baru, 0 diperbarui." (row ketiga dilewati karena `category_id` 999 tidak ada), dan dua produk yang valid muncul di `/products`. Upload file yang sama sekali lagi: pesan berubah jadi "0 produk baru, 2 diperbarui." dan jumlah produk di `/products` tidak bertambah.

> ⚠️ **Jika gagal:** kalau semua row selalu ditolak, ada dua kemungkinan. Pertama, `category_id` di CSV tidak cocok dengan ID kategori yang benar-benar ada: cek lewat `php artisan tinker` dan `Category::pluck('id', 'name')`. Kedua, CSV disimpan dari Excel berlokalisasi Indonesia, yang sering memakai titik koma (`;`) sebagai delimiter dan menyisipkan karakter tak terlihat (BOM) di awal file, sehingga header `name` tidak terbaca. Simpan ulang sebagai "CSV UTF-8 (Comma delimited)" atau tulis file lewat editor teks biasa.

### Langkah 8: Memindahkan import ke queued job

Cucian satu kaus bisa ditunggu di tempat. Cucian satu karung dititip: kamu dapat nota, lalu pulang, dan petugas mengerjakannya belakangan. Import beberapa row itu satu kaus, cukup dijalankan langsung seperti langkah sebelumnya. Import ribuan row itu satu karung: prosesnya bisa memakan waktu lama, dan pengguna terpaksa menunggu di depan browser tanpa tahu prosesnya masih berjalan atau tidak. Langkah ini memindahkan import ke queued job. `dispatch()` adalah memberikan nota ke rak, dan **worker** (`queue:work`) adalah petugas yang mengerjakan tumpukan nota itu.

Branch baru dari `main` terbaru, misalnya `import-queue`:

```bash
git checkout main
git pull
git checkout -b import-queue
php artisan make:job ProcessProductImport
```

Isi `app/Jobs/ProcessProductImport.php` menjadi:

```php
<?php

namespace App\Jobs;

use App\Models\Product;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProcessProductImport implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public array $backoff = [10, 60];

    public int $timeout = 60;

    public function __construct(private string $csvPath) {}

    public function handle(): void
    {
        $lines = file(Storage::path($this->csvPath), FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        $rows = array_map('str_getcsv', $lines);
        $header = array_shift($rows);

        foreach ($rows as $row) {
            if (count($row) !== count($header)) {
                continue;
            }

            $validator = Validator::make(array_combine($header, $row), [
                'name' => ['required', 'string'],
                'category_id' => ['required', 'exists:categories,id'],
                'price' => ['required', 'integer', 'min:0'],
            ]);

            if ($validator->fails()) {
                continue;
            }

            $data = $validator->validated();
            Product::updateOrCreate(
                ['name' => $data['name'], 'category_id' => $data['category_id']],
                ['price' => $data['price']],
            );
        }

        Storage::delete($this->csvPath);
    }
}
```

Loop validasi-dan-simpan dari `ReportController::import()` pindah ke metode `handle()` di atas, dengan path file CSV dibawa lewat constructor. Job hanya membawa path-nya, bukan isi file, supaya payload di tabel `jobs` tetap kecil. `Storage::delete()` di akhir membersihkan file sementara setelah selesai diproses.

Tiga property baru mengatur ketahanan job. `$tries = 3` berarti job dicoba maksimal 3 attempt. `$backoff = [10, 60]` berarti jeda sebelum attempt kedua 10 detik, sebelum attempt ketiga 60 detik: seperti petugas laundry yang mencoba lagi nanti kalau mesin cuci sedang rusak, bukan langsung menyerah. `$timeout = 60` membatalkan job yang berjalan lebih dari 60 detik. Kalau semua attempt gagal, job dicatat di tabel `failed_jobs`. Berkat `updateOrCreate()` dari langkah sebelumnya, job aman dicoba ulang tanpa membuat produk dobel.

`$timeout` harus lebih kecil daripada `retry_after` milik driver `database` (default 90 detik, lihat `config/queue.php`). Kalau terbalik, job yang masih berjalan dianggap macet dan diambil worker kedua, sehingga **diproses dobel**.

Isi `app/Http/Controllers/ReportController.php` menjadi:

```php
<?php

namespace App\Http\Controllers;

use App\Exports\SalesReportExport;
use App\Jobs\ProcessProductImport;
use App\Models\Transaction;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\View\View;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $query->sum('total'),
            'jumlahTransaksi' => $query->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function exportCsv(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $query = $this->filteredQuery($from, $to);

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($query->lazyById() as $t) {
                fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
            }
            fclose($out);
        }, 'laporan-penjualan.csv');
    }

    public function exportExcel(Request $request): BinaryFileResponse
    {
        [$from, $to] = $this->resolveDateRange($request);

        return Excel::download(
            new SalesReportExport($this->filteredQuery($from, $to)),
            'laporan-penjualan.xlsx',
        );
    }

    public function exportPdf(Request $request): Response
    {
        [$from, $to] = $this->resolveDateRange($request);

        $pdf = Pdf::loadView('reports.pdf', [
            'totalPenjualan' => $this->filteredQuery($from, $to)->sum('total'),
            'jumlahTransaksi' => $this->filteredQuery($from, $to)->count(),
            'transactions' => $this->filteredQuery($from, $to)->latest()->limit(50)->get(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);

        return $pdf->download('laporan-penjualan.pdf');
    }

    public function importForm(): View
    {
        return view('reports.import');
    }

    public function import(Request $request): RedirectResponse
    {
        $request->validate([
            'csv' => ['required', 'file', 'mimes:csv,txt'],
        ]);

        $path = $request->file('csv')->store('imports');

        ProcessProductImport::dispatch($path);

        return back()->with('success', 'Import sedang diproses di background.');
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredQuery($from, $to): Builder
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to]);
    }
}
```

`import()` sekarang hanya menyimpan file dan mengirim satu job ke queue lewat `dispatch()`, lalu segera memberi response ke pengguna tanpa menunggu proses import-nya selesai sama sekali. Perhatikan `use App\Jobs\ProcessProductImport;` yang baru di bagian atas file, menggantikan `use App\Models\Product;` dan `use Illuminate\Support\Facades\Validator;` yang sekarang tidak lagi dipakai langsung di controller ini, karena validasi dan penyimpanan produk sudah pindah ke job.

```bash
git add .
git commit -m "pindahkan import produk ke queued job"
git push -u origin import-queue
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint 1:** upload CSV yang sama seperti langkah 7 lewat `/import`. **Yang diharapkan:** pesan "Import sedang diproses di background." muncul seketika, tapi produk belum langsung bertambah di `/products`. Sebelum menjalankan worker, intip tabel `jobs` lewat `php artisan tinker`:
>
> ```php
> DB::table('jobs')->get(['id', 'queue', 'attempts', 'reserved_at']);
> ```
>
> Ada satu row dengan `attempts` 0 dan `reserved_at` `null`: job menunggu dan belum diambil worker. Isi column `payload` memuat nama class `ProcessProductImport` dan path file CSV-nya. Sekarang jalankan `php artisan queue:work --once` di terminal terpisah, lalu refresh `/products`: produk-produk dari CSV sekarang sudah tersimpan, dan row di tabel `jobs` sudah hilang. Cek juga `config('queue.connections.database.retry_after')` di tinker: hasilnya 90, lebih besar daripada `$timeout` job kita.

> ✅ **Checkpoint 2 (uji job gagal):** upload CSV sekali lagi, lalu **hapus** file hasil upload-nya di `storage/app/private/imports/` sebelum worker jalan. Jalankan `php artisan queue:work` (tanpa `--once`) dan biarkan sekitar 1,5 menit: kamu akan melihat job gagal, dicoba lagi setelah 10 detik, dicoba lagi setelah 60 detik, lalu dinyatakan gagal. Hentikan worker dengan `Ctrl+C`, lalu jalankan `php artisan queue:failed`: job tadi tercatat di sana beserta waktunya. Bersihkan dengan `php artisan queue:flush`.

> ⚠️ **Jika produk langsung muncul tanpa menjalankan `queue:work`:** periksa `QUEUE_CONNECTION` di `.env`, pastikan bertuliskan `database`, bukan `sync`, lalu jalankan `php artisan config:clear`. Dengan `sync`, job dikerjakan di tempat dan tidak pernah masuk queue sungguhan, seperti kasir yang menyuruhmu menunggu cucian kering padahal kamu sudah memegang nota.

> ⚠️ **Jika `queue:work` jalan tapi produk tidak bertambah:** job yang gagal dicatat di tabel `failed_jobs`. Lihat daftarnya dengan `php artisan queue:failed`, baca pesan errornya, perbaiki masalahnya, lalu jalankan ulang dengan `php artisan queue:retry all`. Ingat juga: worker tidak otomatis memuat kode baru. Setelah mengubah class job, hentikan worker dengan `Ctrl+C` lalu jalankan lagi (di server production, perintahnya `php artisan queue:restart`).

### Langkah 9: Bersama, uji integrasi dan review kode

Semua anggota `git checkout main && git pull`, jalankan `composer install` dan `php artisan migrate:fresh --seed`, lalu ulangi seluruh checkpoint di laptop masing-masing: laporan dengan filter tanggal, export CSV, Excel, dan PDF, import CSV lewat queue (ingat menjalankan `php artisan queue:work --once` setiap kali menguji import). Setelah itu, kelompok membaca kode bersama: setiap anggota menjelaskan satu bagian yang **bukan** ia tulis sendiri.

> ✅ **Checkpoint:** seluruh checkpoint di atas berhasil diulang dan menunjukkan hasil yang sama persis di setiap laptop anggota.

### Langkah 10: Tantangan mandiri kelompok dan commit `increment 9`

Bagi tugas berikut di antara anggota, supaya setiap anggota tercatat minimal satu commit bermakna lewat Pull Request masing-masing:

- Tambahkan filter kategori pada halaman laporan, selain rentang tanggal yang sudah ada.
- Simpan row yang gagal di-import (nomor row dan pesan errornya), misalnya ke log atau tabel `import_errors`, lalu tampilkan di halaman `/import`, bukan hanya jumlah yang berhasil.
- Buat versi import memakai Laravel Excel (`ToModel`, `WithHeadingRow`, `WithChunkReading`), lalu bandingkan dengan versi manual: mana yang lebih ringkas, mana yang lebih mudah dikontrol?
- Tambahkan tabel produk terlaris pada laporan PDF.
- Identifikasi satu proses lain di Simple POS yang menurutmu layak dipindah ke queued job, dan jelaskan alasannya di README proyek.

Setiap tugas: buat branch baru (misalnya `report-category-filter`), kerjakan, commit, push, lalu buka dan merge Pull Request-nya (ikuti alur di atas).

Setelah semua Pull Request masuk dan digabungkan, salah satu anggota menutup pekerjaan kelompok:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 9: laporan, import/export csv excel pdf, dan queue"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** baris teratas `git log --pretty="%h %an %s"` menunjukkan `increment 9: ...`, dan baris-baris di bawahnya menunjukkan nama setiap anggota kelompok.

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta dosen:

- Link repositori GitHub kelompok.
- Screenshot halaman `/reports` dengan total penjualan dan filter tanggal.
- Screenshot hasil export: file `.xlsx` yang terbuka di Excel/LibreOffice dan file `.pdf` yang terbuka.
- File `docs/pengukuran-memori.md` yang sudah terisi angka dan kesimpulan.
- Screenshot pesan "Import sedang diproses di background." dan hasil `/products` setelah `queue:work` memprosesnya, serta output `php artisan queue:failed` dari uji job gagal.
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel pembagian tugas: nama anggota | langkah/tugas yang dikerjakan | hash commit.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---:|---|---|
| Langkah kerja tuntas (kelompok) | 40% | Langkah 1-10 selesai: laporan, export CSV/Excel/PDF, pengukuran memori, import idempotent, dan queue berfungsi sesuai checkpoint | Sebagian besar langkah selesai, laporan, satu format export, dan import berjalan |
| Checkpoint terverifikasi (kelompok) | 25% | Screenshot laporan, hasil export, tabel pengukuran memori, hasil import via queue, uji job gagal, tabel pembagian tugas, dan git log lengkap dan benar | Sebagian checkpoint terbukti |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna atas nama tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Kerapian repositori dan commit | 10% | Pesan `increment 9` persis, tanpa menyertakan `vendor/`, `node_modules/`, `.env`, PR di-merge rapi (bukan squash) | Commit ada, pesan kurang rapi atau PR di-squash |
