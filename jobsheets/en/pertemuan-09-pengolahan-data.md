# Group Practicum Jobsheet: Meeting 9
## Data Processing: Import, Export, and Queues (Group Work)

| | |
|---|---|
| **Course** | Advanced Web Programming (SIB245007) |
| **Meeting** | 9 (Week 9) |
| **Duration** | 2 sessions &times; 170 minutes (Session 1: Steps 1-6, Session 2: Steps 7-10) |
| **Sub-CPMK** | Sub-CPMK 4: Students can develop a framework-based web application that fits user needs. |
| **Work Mode** | Group (same as Meeting 3-7), one shared GitHub repository per group |
| **Starting Code** | your group's repository from Meeting 7 (continue its `main`; Meeting 8 is UTS with no new code material). If the group repository is broken, create a copy from the template `github.com/se-polinema/simple-pos-ch07` via **Use this template** |

## A. Practicum Outcomes

After completing this group jobsheet, you are able to:

1. Build a sales report page with a date-range filter, with the aggregation done in the database.
2. Export the report in three formats (CSV, Excel, PDF) and explain when each format fits.
3. Measure and compare the memory usage of `get()` and `lazyById()` on a large dataset.
4. Build a product import from a CSV file that validates each row, skips bad rows, and is safe to repeat (idempotent).
5. Move the import into a queued job with `$tries`, `backoff`, and `$timeout`, inspect the job in the `jobs` table, and trace failed jobs through `failed_jobs`.

## B. Preparation and Prerequisites

- **Tools**: same as Meetings 3-7 (PHP 8.2+, Composer, Node.js, Git).
- **PHP extensions**: Laravel Excel and DomPDF need the `zip` and `gd` extensions. Check with the command below, and enable them in `php.ini` if they don't show up:
  ```bash
  php -m | grep -E "zip|gd"
  ```
  > ✅ **Checkpoint:** both `gd` and `zip` appear in the output.
- **Git identity**: already configured since Meeting 3.
- **Quick verification** before starting:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  php artisan migrate:fresh --seed
  ```
  > ✅ **Checkpoint:** the top line shows the commit `increment 7: ...`, and `migrate:fresh --seed` runs without errors.

## C. Work Steps

The workflow is the same as Meetings 3-7: every step is done on its own branch off `main`, merged through a Pull Request with **Create a merge commit** (not squash), then every member runs `git pull` before creating the next branch.

The big picture of this meeting is a restaurant kitchen. Raw data comes in (extract), gets cooked into dishes (transform), then is served in several forms: CSV, Excel, or PDF (load). When orders pile up, the kitchen doesn't make guests wait at the stove: they get a table number and the food is brought over later. That is the role of the queue in Step 8.

### Step 1: Setting up a branch and dividing the work

Create a new branch off the latest `main`, e.g. `sales-report`:

```bash
git checkout main
git pull
git checkout -b sales-report
php artisan make:controller ReportController
```

Agree on how to divide steps 2 to 8 among the members.

> ✅ **Checkpoint:** the file `app/Http/Controllers/ReportController.php` exists (still empty), and the `sales-report` branch is active.

### Step 2: A sales report with a date filter

A transaction page is like a pile of receipts in the cash drawer: everything is there, but you have to add it up yourself. A report page is like the month-end summary: not "what transactions happened", but "what's the total sales over a given time range", already totaled and ready to read.

Replace the contents of `app/Http/Controllers/ReportController.php` with:

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

`resolveDateRange()` supplies a default (the current month) when the user hasn't filled in a filter at all. `startOfDay()`/`endOfDay()` avoid the last-day pitfall: without `endOfDay()`, a filter of "up to August 31" stops at 00:00 on the 31st, so every transaction made during the 31st vanishes from the report.

`filteredQuery()` only prepares the query without running it. `sum()` and `count()` in `index()` are done by the database itself, so thousands of transaction rows don't need to be loaded into memory just to be added up. The same query gets reused in the following steps for every export format, so the filter logic isn't written three times.

Create the view:

```bash
php artisan make:view reports.index
```

Replace the contents of `resources/views/reports/index.blade.php` with:

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

Replace the contents of `routes/web.php` with (note the `use` for `ReportController` and the new route inside the `role:admin` group):

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

Add the navigation link by replacing the contents of `resources/views/components/nav.blade.php` with:

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

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** log in as admin, open `/reports`. The total sales and transaction count show the current month's data. Change the filter to a date range with definitely no transactions (e.g. year 2020): the total changes to Rp 0 and 0 transactions.

> ⚠️ **If it fails:** a total that never changes no matter the filter means `resolveDateRange()` isn't reading `$request->date('from')`/`$request->date('to')` correctly, check the `name="from"`/`name="to"` attributes on the date inputs in the view. The error `Class "App\Http\Controllers\ReportController" not found` means the line `use App\Http\Controllers\ReportController;` is missing from `routes/web.php`.

### Step 3: Exporting the report to CSV (streaming)

A CSV export is a tap, not a bucket. The bucket way: collect every row in memory first, then send. The tap way: let rows flow one by one. Create a new branch off the latest `main`, e.g. `csv-export`:

```bash
git checkout main
git pull
git checkout -b csv-export
```

Replace the contents of `app/Http/Controllers/ReportController.php` with:

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

`exportCsv()` reuses `resolveDateRange()` and `filteredQuery()`, so the CSV honors the same date filter as the report page. `lazyById()` fetches data from the database in small chunks, and `streamDownload()` writes each row straight to the browser, so server memory stays flat no matter how many transactions there are.

`streamDownload()` must be declared with a `StreamedResponse` return type from Symfony, not `Illuminate\Http\Response`; if the type is wrong, PHP throws a `TypeError` the moment this method is called.

Replace the contents of `routes/web.php` with:

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

Replace the contents of `resources/views/reports/index.blade.php` with (the **Export CSV** button is added after the `Filter` button):

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

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** click the "Export CSV" button on `/reports`. A `laporan-penjualan.csv` file downloads, its first row is `ID,Tanggal,Kasir,Total`, and the following rows contain transaction data matching the currently active date filter.

> ⚠️ **If it fails:** the error `TypeError: ... Return value must be of type Illuminate\Http\Response` means `use Symfony\Component\HttpFoundation\StreamedResponse;` hasn't been added, or the return type of `exportCsv()` is still `Response`.

### Step 4: Measuring memory usage (`get()` vs `lazyById()`)

With the 2,500 transactions from the seeder, `get()` and `lazyById()` feel the same. Memory trouble only shows up when the data grows. Picture a workbench: `get()` puts every document on the bench at once, while `lazyById()` takes a handful at a time from the cabinet. In this step you measure it yourself instead of just trusting the theory.

Create a new branch off the latest `main`, e.g. `memory-benchmark`:

```bash
git checkout main
git pull
git checkout -b memory-benchmark
php artisan tinker
```

Inside tinker, add 50,000 dummy transactions so the total is around 52,500 rows:

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

Then measure the two ways of reading data. `memory_reset_peak_usage()` restarts the peak counter before each measurement, so the two results don't affect each other:

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

Leave tinker (`exit`), then restore the data to its normal state so the numbers on the report aren't distorted:

```bash
php artisan migrate:fresh --seed
```

Record the result. Replace the contents of `docs/pengukuran-memori.md` with (replace `...` with your measured numbers):

```markdown
# Memory Measurement: get() vs lazyById()

Dataset: about 52,500 rows in the `transactions` table.

| How the data is read | Peak memory (MB) |
|---|---|
| `Transaction::lazyById()` | ... |
| `Transaction::get()` | ... |

Group conclusion: ...
```

```bash
git add .
git commit -m "catat hasil pengukuran memori get vs lazyById"
git push -u origin memory-benchmark
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** the peak memory of `get()` is much larger than that of `lazyById()`. On the lecturer's laptop with 52,500 rows, the result is about 96 MB for `get()` and 38 MB for `lazyById()`. Your numbers will differ, but the gap must be clearly visible. Also note: the bigger the data, the wider the gap, and `get()` can hit PHP's `memory_limit`.

> ⚠️ **If it fails:** if both numbers are nearly equal, make sure the row count really is around 52,500 (the result of the first `count()`), and that you measured `lazyById()` with `$ukur(...)` as above (not `get()` twice). The error `Call to undefined function memory_reset_peak_usage()` means your PHP version is below 8.2.

### Step 5: Exporting to Excel with Laravel Excel

CSV is enough for raw data, but the finance team usually wants an `.xlsx` file that is neat right away: clear headers, fitted column widths. A spreadsheet library handles the complicated `.xlsx` format (really a zip file of XML) so you only describe the content: the data source, the headings, and how to map each row.

Create a new branch off the latest `main`, e.g. `excel-export`, then install the library and generate the export class:

```bash
git checkout main
git pull
git checkout -b excel-export
composer require maatwebsite/excel:^3.1
php artisan make:export SalesReportExport
```

Replace the contents of `app/Exports/SalesReportExport.php` with:

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

`FromQuery` hands the reading over to the library: the query is read in chunks behind the scenes, so memory stays under control. `WithHeadings` writes the title row, `WithMapping` decides what each row contains, and `ShouldAutoSize` fits the column widths. This class receives the same query as the report page, so the date filter applies automatically.

Replace the contents of `app/Http/Controllers/ReportController.php` with:

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

Replace the contents of `routes/web.php` with:

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

Replace the contents of `resources/views/reports/index.blade.php` with (the **Export Excel** button is added):

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

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls (also run `composer install` because there's a new dependency).

> ✅ **Checkpoint:** click "Export Excel" on `/reports`. A `laporan-penjualan.xlsx` file downloads and opens in Excel or LibreOffice with the headers `ID`, `Tanggal`, `Kasir`, `Total`, and rows matching the date filter.

> ⚠️ **If it fails:** the error `Class "ZipArchive" not found` or a message about the `gd` extension means the PHP `zip`/`gd` extensions aren't enabled (see Section B). The error `Class "App\Exports\SalesReportExport" not found` means the export file wasn't created with `make:export` or its namespace is wrong. After another member pulls, forgetting `composer install` causes the error `Class "Maatwebsite\Excel\Facades\Excel" not found`.

### Step 6: A PDF report with DomPDF

PDF suits documents that will be read or printed, not processed further: it is like taking a photo of the month-end summary. DomPDF works in a simple way: you write an ordinary Blade view, and the library turns the HTML into a PDF. The consequence is that DomPDF holds the whole document in memory, so PDF is not suitable for tens of thousands of rows. That's why our PDF report only shows a summary total and the 50 latest transactions.

Create a new branch off the latest `main`, e.g. `pdf-report`:

```bash
git checkout main
git pull
git checkout -b pdf-report
composer require barryvdh/laravel-dompdf
php artisan make:view reports.pdf
```

Replace the contents of `resources/views/reports/pdf.blade.php` with (this view is standalone and doesn't use `layouts.app`, because a PDF needs no navigation or Vite):

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

Replace the contents of `app/Http/Controllers/ReportController.php` with:

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

Note the `limit(50)`: this limit is deliberate. The summary totals are still computed from all the data through `sum()` and `count()` in the database, while the detail table is capped to keep the PDF light.

Replace the contents of `routes/web.php` with:

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

Replace the contents of `resources/views/reports/index.blade.php` with (the **Export PDF** button is added):

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

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls (also run `composer install`).

> ✅ **Checkpoint:** click "Export PDF" on `/reports`. A `laporan-penjualan.pdf` file downloads, containing the title, the period, the total sales, and a table of at most 50 transactions.

> ⚠️ **If it fails:** a blank PDF page or the error `View [reports.pdf] not found` means the view file wasn't created at `resources/views/reports/pdf.blade.php`. Garbled characters usually mean `<meta charset="utf-8">` or the `DejaVu Sans` font in the CSS is missing.

> Group discussion (answer briefly in the README): for a report of 100,000 transactions, which format would you choose (CSV, Excel, or PDF), and why?

### Step 7: Importing products from CSV (safe to repeat)

An import is like a cashier scanning groceries. If one barcode is damaged, the cashier sets that item aside and keeps scanning the rest, instead of sending every customer home. There's one more thing: what if the same file is uploaded twice? Without a safeguard, every product would be recorded twice. The answer is `updateOrCreate()`: like an attendance sheet, if the name is already there, just update that line instead of writing a new one. This property is called **idempotent**: run it many times and the end result is the same.

Create a new branch off the latest `main`, e.g. `csv-import`:

```bash
git checkout main
git pull
git checkout -b csv-import
```

Replace the contents of `app/Http/Controllers/ReportController.php` with:

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

`continue` on a row that fails validation keeps the import moving to the next row, instead of stopping entirely just because one row had a typo. `FILE_SKIP_EMPTY_LINES` drops blank lines, and the `count($row) !== count($header)` check skips rows with the wrong number of columns, so `array_combine()` doesn't throw an error. `updateOrCreate()` looks for a product with the same `name` and `category_id`: if it exists, only its `price` is updated; if not, the product is created. `wasRecentlyCreated` tells you which ones were newly created.

Create the view:

```bash
php artisan make:view reports.import
```

Replace the contents of `resources/views/reports/import.blade.php` with:

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

Replace the contents of `routes/web.php` with:

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

Replace the contents of `resources/views/components/nav.blade.php` with (the **Import** link is added):

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

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** create a `produk.csv` file containing:
> ```
> name,category_id,price
> Kopi Hitam,1,15000
> Teh Manis,1,10000
> Produk Tanpa Kategori,999,5000
> ```
> (adjust `category_id` to a category that really exists in your data). Upload it via `/import`. **Expected:** the message "2 produk baru, 0 diperbarui." (the third row is skipped because `category_id` 999 doesn't exist), and the two valid products show up on `/products`. Upload the same file once more: the message changes to "0 produk baru, 2 diperbarui." and the number of products on `/products` does not increase.

> ⚠️ **If it fails:** if every row is always rejected, there are two likely causes. First, the `category_id` values in the CSV don't match real category IDs: check via `php artisan tinker` and `Category::pluck('id', 'name')`. Second, the CSV was saved from Excel with an Indonesian locale, which often uses a semicolon (`;`) as the delimiter and adds an invisible character (BOM) at the start of the file, so the `name` header isn't recognized. Re-save it as "CSV UTF-8 (Comma delimited)" or write the file in a plain text editor.

### Step 8: Moving the import to a queued job

One T-shirt of laundry you can wait for at the counter. A whole sack you drop off: you get a ticket, go home, and the staff handle it later. Importing a few rows is one T-shirt, fine to run directly like the previous step. Importing thousands of rows is a whole sack: it can take a long time, and the user is stuck waiting in the browser with no way to know if it's still running or already failed silently. This step moves the import to a queued job. `dispatch()` is handing the ticket to the rack, and the **worker** (`queue:work`) is the staff member who works through the pile of tickets.

Create a new branch off the latest `main`, e.g. `import-queue`:

```bash
git checkout main
git pull
git checkout -b import-queue
php artisan make:job ProcessProductImport
```

Replace the contents of `app/Jobs/ProcessProductImport.php` with:

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

The validate-and-save loop from `ReportController::import()` moves into the `handle()` method above, with the CSV file path carried through the constructor. The job only carries the path, not the file contents, so the payload in the `jobs` table stays small. `Storage::delete()` at the end cleans up the temporary file once it's been processed.

Three new properties control the job's resilience. `$tries = 3` means the job is attempted at most 3 times. `$backoff = [10, 60]` means the wait before the second attempt is 10 seconds, and before the third attempt 60 seconds: like laundry staff who try again later when the washing machine is broken instead of giving up right away. `$timeout = 60` cancels a job that runs longer than 60 seconds. If all attempts fail, the job is recorded in the `failed_jobs` table. Thanks to `updateOrCreate()` from the previous step, the job is safe to retry without creating duplicate products.

`$timeout` must be smaller than the `database` driver's `retry_after` (default 90 seconds, see `config/queue.php`). If it is the other way round, a job that is still running is considered stuck and picked up by a second worker, so it gets **processed twice**.

Replace the contents of `app/Http/Controllers/ReportController.php` with:

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

`import()` now only saves the file and sends one job to the queue through `dispatch()`, then responds to the user right away without waiting for the import to finish at all. Note the new `use App\Jobs\ProcessProductImport;` at the top of the file, replacing `use App\Models\Product;` and `use Illuminate\Support\Facades\Validator;`, which this controller no longer uses directly because validation and product saving moved into the job.

```bash
git add .
git commit -m "pindahkan import produk ke queued job"
git push -u origin import-queue
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint 1:** upload the same CSV as in step 7 via `/import`. **Expected:** the message "Import sedang diproses di background." appears instantly, but the products don't increase on `/products` yet. Before running the worker, peek at the `jobs` table through `php artisan tinker`:
>
> ```php
> DB::table('jobs')->get(['id', 'queue', 'attempts', 'reserved_at']);
> ```
>
> There is one row with `attempts` 0 and `reserved_at` `null`: the job is waiting and has not been picked up by a worker. The `payload` column holds the name of the `ProcessProductImport` class and the CSV file path. Now run `php artisan queue:work --once` in a separate terminal, then refresh `/products`: the products from the CSV are now saved, and the row in the `jobs` table is gone. Also check `config('queue.connections.database.retry_after')` in tinker: it gives 90, larger than our job's `$timeout`.

> ✅ **Checkpoint 2 (failed job test):** upload the CSV once more, then **delete** its uploaded file in `storage/app/private/imports/` before the worker runs. Run `php artisan queue:work` (without `--once`) and let it run for about 1.5 minutes: you will see the job fail, be retried after 10 seconds, be retried after 60 seconds, and then be declared failed. Stop the worker with `Ctrl+C`, then run `php artisan queue:failed`: the job is recorded there along with its time. Clean up with `php artisan queue:flush`.

> ⚠️ **If the products appear immediately without running `queue:work`:** check `QUEUE_CONNECTION` in `.env`, make sure it says `database`, not `sync`, then run `php artisan config:clear`. With `sync` the job runs in place and never enters a real queue, like a clerk telling you to wait until the laundry is dry even though you're already holding a ticket.

> ⚠️ **If `queue:work` runs but no products are added:** failed jobs are recorded in the `failed_jobs` table. List them with `php artisan queue:failed`, read the error message, fix the problem, then run them again with `php artisan queue:retry all`. Also remember: a worker doesn't pick up new code automatically. After changing the job class, stop the worker with `Ctrl+C` and start it again (on a production server, the command is `php artisan queue:restart`).

### Step 9: Together, integration test and code review

Every member runs `git checkout main && git pull`, then `composer install` and `php artisan migrate:fresh --seed`, then repeats all the checkpoints above on their own laptop: the report with a date filter, the CSV, Excel, and PDF exports, and the CSV import through the queue (remember to run `php artisan queue:work --once` each time you test the import). After that, the group reads the code together: each member explains one part they did **not** write themselves.

> ✅ **Checkpoint:** all the checkpoints above are repeated successfully and show exactly the same results on every member's laptop.

### Step 10: Group independent challenges and the `increment 9` commit

Divide the following tasks among the members, so each member has at least one meaningful commit through their own Pull Request:

- Add a category filter to the report page, in addition to the existing date range.
- Store the rows that failed to import (row number and error message), for example in the log or an `import_errors` table, then show them on the `/import` page, not just the number of successes.
- Build an import version using Laravel Excel (`ToModel`, `WithHeadingRow`, `WithChunkReading`), then compare it with the manual version: which is more concise, which is easier to control?
- Add a best-selling products table to the PDF report.
- Identify one other process in Simple POS that you think deserves a queued job, and explain the reason in the project README.

For each task: create a new branch (e.g. `report-category-filter`), do the work, commit, push, then open and merge its Pull Request (follow the flow above).

After all Pull Requests are merged, one member closes out the group's work:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 9: laporan, import/export csv excel pdf, dan queue"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** the top line of `git log --pretty="%h %an %s"` shows `increment 9: ...`, and the lines below it show the name of every group member.

## D. Tasks and Deliverables

Submit the following in the format requested by the lecturer:

- The group's GitHub repository link.
- A screenshot of the `/reports` page with the total sales and date filter.
- Screenshots of the export results: the `.xlsx` file opened in Excel/LibreOffice and the `.pdf` file opened.
- The `docs/pengukuran-memori.md` file filled in with numbers and a conclusion.
- A screenshot of the message "Import sedang diproses di background." and the `/products` result after `queue:work` processed it, plus the output of `php artisan queue:failed` from the failed job test.
- The output of `git log --pretty="%h %an %s"` showing at least one commit per member.
- A task division table: member name | steps/tasks done | commit hash.

## E. Grading Rubric

| Component | Weight | Full Criteria (100%) | Minimum Criteria |
|---|---:|---|---|
| Steps completed (group) | 40% | Steps 1-10 done: report, CSV/Excel/PDF export, memory measurement, idempotent import, and queue work per the checkpoints | Most steps done, the report, one export format, and the import work |
| Verified checkpoints (group) | 25% | Screenshots of the report, export results, memory table, import via queue, failed job test, task division table, and complete and correct git log | Some checkpoints proven |
| Per-member contribution (individual) | 25% | At least one meaningful commit under each member's name, matching the task division table | Commits exist but are small or their relevance is unclear |
| Repository and commit tidiness | 10% | Exact `increment 9` message, no `vendor/`, `node_modules/`, or `.env` included, PRs merged cleanly (not squashed) | Commits exist, message is untidy or PRs were squashed |
