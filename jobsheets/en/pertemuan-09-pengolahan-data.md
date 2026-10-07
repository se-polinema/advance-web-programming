# Group Practicum Jobsheet: Meeting 9
## Data Processing: Import, Export, and Queues (Group Work)

| | |
|---|---|
| **Course** | Advanced Web Programming (SIB245007) |
| **Meeting** | 9 (Week 9) |
| **Duration** | 2 sessions &times; 170 minutes |
| **Sub-CPMK** | Sub-CPMK 4: Students can develop a framework-based web application that fits user needs. |
| **Work Mode** | Group (same as Meeting 3-7), one shared GitHub repository per group |
| **Starting Code** | your group's repository from Meeting 7 (continue its `main`; Meeting 8 is UTS with no new code material). If the group's repository has problems, create a copy of the template `github.com/se-polinema/simple-pos-ch07` via **Use this template** |

## A. Practicum Outcomes

After completing this group jobsheet, you'll be able to:

1. Build a sales report page with a date-range filter, complete with a total aggregated from transaction data.
2. Export the report to CSV without overloading server memory, using `streamDownload()`.
3. Build a product import from a CSV file that handles invalid rows without stopping the entire process.
4. Move the import process to a queued job, and explain when a process deserves to move to a queue.

## B. Preparation and Prerequisites

- **Tools**: same as Meeting 3-7 (PHP 8.2+, Composer, Node.js, Git).
- **Git identity**: already set up since Meeting 3.
- **Quick check** before starting:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  php artisan migrate:fresh --seed
  ```
  > ✅ **Checkpoint:** the top line shows the `increment 7: ...` commit, and `migrate:fresh --seed` runs with no error.

## C. Work Steps

Same workflow as Meeting 3-7: each step happens on its own branch off `main`, gets merged through a Pull Request with **Create a merge commit** (not squash), then everyone runs `git pull` before starting the next branch.

### Step 1: Setting up a branch and dividing the work

Create a new branch off the latest `main`, e.g. `sales-report`:

```bash
git checkout main
git pull
git checkout -b sales-report
php artisan make:controller ReportController
```

Agree on how steps 2 to 6 are divided among the members.

> ✅ **Checkpoint:** the file `app/Http/Controllers/ReportController.php` exists (still empty), and the `sales-report` branch is active.

### Step 2: A sales report with a date filter

A report page answers a different question than an ordinary transaction page: not "what transactions happened", but "what's the total sales over a given time range".

Replace the contents of `app/Http/Controllers/ReportController.php` with:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $transactions = $this->filteredTransactions($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $transactions->sum('total'),
            'jumlahTransaksi' => $transactions->count(),
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

    private function filteredTransactions($from, $to)
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to])
            ->get();
    }
}
```

`resolveDateRange()` supplies a default (the current month) when the user hasn't filled in a filter at all, and `startOfDay()`/`endOfDay()` make sure the last day isn't cut off at midnight. `filteredTransactions()` gets reused in the next step for CSV export, so the filter logic isn't written twice.

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

Register the route inside the existing `role:admin` group in `routes/web.php` (add the line below inside that group, after the `Route::resource('products', ...)` line):

```php
Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
```

Also add the navigation link in `resources/views/components/nav.blade.php`, right after the `Kategori` link:

```php
<a href="{{ route('reports.index') }}" class="hover:underline">Laporan</a>
```

```bash
git add .
git commit -m "tambah laporan penjualan dengan filter tanggal"
git push -u origin sales-report
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** log in as admin, open `/reports`. The total sales and transaction count show the current month's data. Change the filter to a date range with definitely no transactions (e.g. year 2020): the total changes to Rp 0 and 0 transactions.

> ⚠️ **If it fails:** a total that never changes no matter what filter you enter means `resolveDateRange()` isn't correctly reading `$request->date('from')`/`$request->date('to')`, check the `name="from"`/`name="to"` attributes on the date inputs in the view.

### Step 3: Exporting the report to CSV

Create a new branch off the latest `main`, e.g. `csv-export`:

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
use Illuminate\Http\Request;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $transactions = $this->filteredTransactions($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $transactions->sum('total'),
            'jumlahTransaksi' => $transactions->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function export(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $transactions = $this->filteredTransactions($from, $to);

        return response()->streamDownload(function () use ($transactions) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($transactions as $t) {
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

    private function filteredTransactions($from, $to)
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to])
            ->get();
    }
}
```

The new `export()` method reuses `resolveDateRange()` and `filteredTransactions()` from the previous step, so the CSV export honors the same date filter as the report page. `streamDownload()` must be declared with a `StreamedResponse` return type from Symfony, not `Illuminate\Http\Response`; if the type is wrong, PHP throws a `TypeError` the moment this method is called.

Register the route in `routes/web.php`, right below the `reports.index` route:

```php
Route::get('/reports/export', [ReportController::class, 'export'])->name('reports.export');
```

Add the export link in `resources/views/reports/index.blade.php`, right after the `Filter` button:

```php
<a href="{{ route('reports.export', ['from' => $from, 'to' => $to]) }}" class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm">Ekspor CSV</a>
```

```bash
git add .
git commit -m "tambah ekspor laporan penjualan ke CSV"
git push -u origin csv-export
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** click the "Ekspor CSV" button on `/reports`. A `laporan-penjualan.csv` file downloads, its first line is `ID,Tanggal,Kasir,Total`, and the following lines contain transaction data matching the currently active date filter.

> ⚠️ **If it fails:** a `TypeError: ... Return value must be of type Illuminate\Http\Response` error means `use Symfony\Component\HttpFoundation\StreamedResponse;` wasn't added, or `export()`'s return type is still `Response`.

### Step 4: Importing products from CSV

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

use App\Models\Product;
use App\Models\Transaction;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $transactions = $this->filteredTransactions($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $transactions->sum('total'),
            'jumlahTransaksi' => $transactions->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function export(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $transactions = $this->filteredTransactions($from, $to);

        return response()->streamDownload(function () use ($transactions) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($transactions as $t) {
                fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
            }
            fclose($out);
        }, 'laporan-penjualan.csv');
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

        $rows = array_map('str_getcsv', file($request->file('csv')->getRealPath()));
        $header = array_shift($rows);

        $imported = 0;
        foreach ($rows as $row) {
            $row = array_combine($header, $row);

            $validator = Validator::make($row, [
                'name' => ['required', 'string'],
                'category_id' => ['required', 'exists:categories,id'],
                'price' => ['required', 'integer', 'min:0'],
            ]);

            if ($validator->fails()) {
                continue;
            }

            Product::create($validator->validated());
            $imported++;
        }

        return back()->with('success', "{$imported} produk berhasil diimpor.");
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredTransactions($from, $to)
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to])
            ->get();
    }
}
```

`continue` on a row that fails validation keeps the import moving to the next row, instead of stopping entirely just because one row had a typo. Valid rows still get saved, invalid rows just get skipped.

Create the view:

```bash
php artisan make:view reports.import
```

Replace the contents of `resources/views/reports/import.blade.php` with:

```php
@extends('layouts.app')

@section('title', 'Impor Produk')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Impor Produk dari CSV</h1>

    @if (session('success'))
        <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
            {{ session('success') }}
        </div>
    @endif

    <form method="POST" action="{{ route('import.store') }}" enctype="multipart/form-data" class="max-w-md">
        @csrf
        <label class="block mb-3">
            <span class="text-sm font-medium">Berkas CSV</span>
            <input type="file" name="csv" accept=".csv" class="mt-1 block w-full text-sm">
            @error('csv')
                <p class="text-sm text-red-600 mt-1">{{ $message }}</p>
            @enderror
        </label>
        <p class="text-xs text-slate-500 mb-3">Kolom yang dibutuhkan: <code>name</code>, <code>category_id</code>, <code>price</code>.</p>
        <button type="submit" class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm">Impor</button>
    </form>
@endsection
```

Register the route in `routes/web.php`, inside the `role:admin` group:

```php
Route::get('/import', [ReportController::class, 'importForm'])->name('import.create');
Route::post('/import', [ReportController::class, 'import'])->name('import.store');
```

Add the navigation link in `resources/views/components/nav.blade.php`, right after the `Laporan` link:

```php
<a href="{{ route('import.create') }}" class="hover:underline">Impor</a>
```

```bash
git add .
git commit -m "tambah impor produk dari CSV"
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
> (match `category_id` to a category that actually exists in your data). Upload it via `/import`. **Expected:** the message "2 produk berhasil diimpor." (the third row is skipped since `category_id` 999 doesn't exist), and the two valid products show up on `/products`.

> ⚠️ **If it fails:** an `exists:categories,id` error that always fails for every row means the `category_id` values in the CSV don't match real category IDs, check via `php artisan tinker` and `Category::pluck('id', 'name')`.

### Step 5: Moving the import to a queued job

Importing a few rows finishes in seconds, fine to run directly like the previous step. Once the volume climbs into the thousands, the same process can take a long time, and the user is stuck waiting in the browser with no way to know if it's still running or already failed silently. This step moves the import to a queued job, so the user gets an instant response while the process runs in the background.

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

    public function __construct(private string $csvPath) {}

    public function handle(): void
    {
        $rows = array_map('str_getcsv', file(Storage::path($this->csvPath)));
        $header = array_shift($rows);

        foreach ($rows as $row) {
            $row = array_combine($header, $row);

            $validator = Validator::make($row, [
                'name' => ['required', 'string'],
                'category_id' => ['required', 'exists:categories,id'],
                'price' => ['required', 'integer', 'min:0'],
            ]);

            if ($validator->fails()) {
                continue;
            }

            Product::create($validator->validated());
        }

        Storage::delete($this->csvPath);
    }
}
```

The validate-and-save loop from `ReportController::import()` moves into the `handle()` method above, with the CSV file path stored through the constructor. `Storage::delete()` at the end cleans up the temporary file once it's been processed.

Replace the contents of `app/Http/Controllers/ReportController.php` with:

```php
<?php

namespace App\Http\Controllers;

use App\Jobs\ProcessProductImport;
use App\Models\Transaction;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        [$from, $to] = $this->resolveDateRange($request);
        $transactions = $this->filteredTransactions($from, $to);

        return view('reports.index', [
            'totalPenjualan' => $transactions->sum('total'),
            'jumlahTransaksi' => $transactions->count(),
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ]);
    }

    public function export(Request $request): StreamedResponse
    {
        [$from, $to] = $this->resolveDateRange($request);
        $transactions = $this->filteredTransactions($from, $to);

        return response()->streamDownload(function () use ($transactions) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
            foreach ($transactions as $t) {
                fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
            }
            fclose($out);
        }, 'laporan-penjualan.csv');
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

        return back()->with('success', 'Impor sedang diproses di latar belakang.');
    }

    private function resolveDateRange(Request $request): array
    {
        $from = $request->date('from')?->startOfDay() ?? now()->startOfMonth();
        $to = $request->date('to')?->endOfDay() ?? now()->endOfDay();

        return [$from, $to];
    }

    private function filteredTransactions($from, $to)
    {
        return Transaction::with('user')
            ->whereBetween('created_at', [$from, $to])
            ->get();
    }
}
```

`import()` now just saves the file and sends one job to the queue via `dispatch()`, then immediately responds to the user without ever waiting for the import to finish. Notice the new `use App\Jobs\ProcessProductImport;` at the top, replacing the `use Illuminate\Support\Facades\Validator;` and `use App\Models\Product;` imports from the previous step, since validation and saving now live inside the job instead of the controller.

```bash
git add .
git commit -m "pindahkan impor produk ke job antrean"
git push -u origin import-queue
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** upload the same CSV as step 4 via `/import`. **Expected:** the message "Impor sedang diproses di latar belakang." appears instantly, but the products don't show up on `/products` right away. Run `php artisan queue:work --once` in a separate terminal, then refresh `/products`: the products from the CSV are now saved.

> ⚠️ **If the products appear immediately without running `queue:work`:** check `QUEUE_CONNECTION` in `.env`, make sure it says `database`, not `sync`. If the job never gets processed at all even after running `queue:work`, check for an error message in that `queue:work` terminal itself.

### Step 6: Together, integration test and code review

Everyone runs `git checkout main && git pull`, `php artisan migrate:fresh --seed`, then repeats every checkpoint on their own laptop: the date-filtered report, the CSV export, and the CSV import through the queue (remember to run `php artisan queue:work --once` every time you test an import). After that, the group reads through the code together: each member explains one part they **didn't** write themselves.

> ✅ **Checkpoint:** every checkpoint above can be repeated and shows exactly the same result on every member's laptop.

### Step 7: Group independent challenges and the `increment 9` commit

Split the following tasks among the group's members, so each member gets at least one meaningful commit recorded through their own Pull Request:

- Add a category filter to the report page, in addition to the existing date range.
- Show the list of rows that failed to import (row number and error message) on the `/import` page, not just the count that succeeded.
- Identify one other process in Simple POS that you think deserves to move to a queued job, and explain why in the project's README.
- Write one manual test scenario for a CSV import with a mix of valid and invalid rows: the steps and the expected result.

For each task: create a new branch (e.g. `report-category-filter`), do the work, commit, push, then open and merge its Pull Request (follow the workflow above).

Once every Pull Request is in and merged, one member closes out the group's work:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 9: laporan, impor/ekspor csv, dan antrean"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** the top line of `git log --pretty="%h %an %s"` shows `increment 9: ...`, and the lines below it show every group member's name.

## D. Tasks and Deliverables

Submit the following in the format your instructor requests:

- Link to the group's GitHub repository.
- Screenshot of the `/reports` page with the total sales and date filter.
- Screenshot of the "Impor sedang diproses di latar belakang." message and the result on `/products` after `queue:work` processes it.
- Output of `git log --pretty="%h %an %s"` showing at least one commit per member.
- A task-division table: member name | step/task done | commit hash.

## E. Grading Rubric

| Component | Weight | Full Marks (100%) | Minimum Marks |
|---|---:|---|---|
| Work steps completed (group) | 40% | Steps 1-7 done, the report, export, import, and queue work as the checkpoints show | Most steps done, the report and import work |
| Checkpoints verified (group) | 25% | Screenshots of the report and the queued import result, task-division table, and a complete, correct git log | Some checkpoints proven |
| Per-member contribution (individual) | 25% | At least one meaningful commit under each member's name, matching the task-division table | Commits exist but are small or their relevance is unclear |
| Repository and commit hygiene | 10% | The `increment 9` message is exact, no `vendor/`, `node_modules/`, `.env` included, PRs merged cleanly (not squashed) | Commits exist, but the message is messy or a PR was squashed |
