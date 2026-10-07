# Jobsheet Praktikum Kelompok: Pertemuan 9
## Pengolahan Data: Impor, Ekspor, dan Antrean (Kerja Kelompok)

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | 9 (Minggu 9) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK 4: Mahasiswa mampu mengembangkan aplikasi web berbasis framework sesuai dengan kebutuhan pengguna. |
| **Mode Pengerjaan** | Kelompok (sama seperti Pertemuan 3-7), satu repositori GitHub bersama per kelompok |
| **Kode Awal** | repositori kelompok hasil Pertemuan 7 (lanjutkan `main`-nya; Pertemuan 8 adalah UTS tanpa materi kode baru). Kalau repositori kelompok bermasalah, buat salinan dari template `github.com/se-polinema/simple-pos-ch07` lewat **Use this template** |

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet kelompok ini, kamu mampu:

1. Menyusun halaman laporan penjualan dengan filter rentang tanggal, lengkap dengan total yang diagregasi dari data transaksi.
2. Mengekspor laporan ke CSV tanpa membebani memori server, memakai `streamDownload()`.
3. Membangun impor produk dari berkas CSV yang menangani baris tidak valid tanpa menghentikan seluruh proses.
4. Memindahkan proses impor ke job antrean, dan menjelaskan kapan sebuah proses layak dipindah ke antrean.

## B. Persiapan dan Prasyarat

- **Alat**: sama seperti Pertemuan 3-7 (PHP 8.2+, Composer, Node.js, Git).
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

### Langkah 1: Menyiapkan branch dan membagi tugas

Buat branch baru dari `main` terbaru, misalnya `sales-report`:

```bash
git checkout main
git pull
git checkout -b sales-report
php artisan make:controller ReportController
```

Sepakati pembagian langkah 2 sampai 6 antaranggota.

> ✅ **Checkpoint:** berkas `app/Http/Controllers/ReportController.php` sudah dibuat (masih kosong), dan branch `sales-report` sudah aktif.

### Langkah 2: Laporan penjualan dengan filter tanggal

Halaman laporan menjawab pertanyaan yang berbeda dari halaman transaksi biasa: bukan "transaksi apa saja yang terjadi", tapi "berapa total penjualan pada rentang waktu tertentu".

Isi `app/Http/Controllers/ReportController.php` menjadi:

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

`resolveDateRange()` memberi nilai default (bulan berjalan) kalau pengguna belum mengisi filter sama sekali, dan `startOfDay()`/`endOfDay()` memastikan hari terakhir tidak terpotong di tengah malam. `filteredTransactions()` dipakai ulang di langkah berikutnya untuk ekspor CSV, supaya logika filter tidak ditulis dua kali.

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

Daftarkan route-nya di dalam grup `role:admin` yang sudah ada di `routes/web.php` (tambahkan baris berikut di dalam grup itu, setelah baris `Route::resource('products', ...)`):

```php
Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
```

Tambahkan juga tautan navigasinya di `resources/views/components/nav.blade.php`, tepat setelah tautan `Kategori`:

```php
<a href="{{ route('reports.index') }}" class="hover:underline">Laporan</a>
```

```bash
git add .
git commit -m "tambah laporan penjualan dengan filter tanggal"
git push -u origin sales-report
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** login sebagai admin, buka `/reports`. Total penjualan dan jumlah transaksi tampil sesuai data bulan berjalan. Ubah filter ke rentang tanggal yang pasti tidak ada transaksinya (misalnya tahun 2020): total berubah jadi Rp 0 dan 0 transaksi.

> ⚠️ **Jika gagal:** total yang tidak berubah sama sekali walau filter diganti berarti `resolveDateRange()` tidak membaca `$request->date('from')`/`$request->date('to')` dengan benar, periksa nama atribut `name="from"`/`name="to"` pada input tanggal di view.

### Langkah 3: Ekspor laporan ke CSV

Branch baru dari `main` terbaru, misalnya `csv-export`:

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

Method `export()` baru memakai ulang `resolveDateRange()` dan `filteredTransactions()` dari langkah sebelumnya, jadi ekspor CSV menghormati filter tanggal yang sama dengan halaman laporan. `streamDownload()` perlu dideklarasikan dengan tipe pengembalian `StreamedResponse` dari Symfony, bukan `Illuminate\Http\Response`; kalau tipenya salah, PHP akan melempar `TypeError` begitu method ini dipanggil.

Daftarkan route-nya di `routes/web.php`, tepat di bawah route `reports.index`:

```php
Route::get('/reports/export', [ReportController::class, 'export'])->name('reports.export');
```

Tambahkan tautan ekspor di `resources/views/reports/index.blade.php`, tepat setelah tombol `Filter`:

```php
<a href="{{ route('reports.export', ['from' => $from, 'to' => $to]) }}" class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm">Ekspor CSV</a>
```

```bash
git add .
git commit -m "tambah ekspor laporan penjualan ke CSV"
git push -u origin csv-export
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** klik tombol "Ekspor CSV" di halaman `/reports`. Berkas `laporan-penjualan.csv` terunduh, baris pertamanya `ID,Tanggal,Kasir,Total`, dan baris-baris berikutnya berisi data transaksi sesuai filter tanggal yang sedang aktif.

> ⚠️ **Jika gagal:** error `TypeError: ... Return value must be of type Illuminate\Http\Response` berarti `use Symfony\Component\HttpFoundation\StreamedResponse;` belum ditambahkan, atau tipe kembalian method `export()` masih `Response`.

### Langkah 4: Impor produk dari CSV

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

`continue` pada baris yang gagal validasi membuat proses impor tetap lanjut ke baris berikutnya, bukan berhenti total hanya karena satu baris salah ketik. Baris yang valid tetap tersimpan, baris yang tidak valid dilewati begitu saja.

Buat view-nya:

```bash
php artisan make:view reports.import
```

Isi `resources/views/reports/import.blade.php` menjadi:

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

Daftarkan route-nya di `routes/web.php`, di dalam grup `role:admin`:

```php
Route::get('/import', [ReportController::class, 'importForm'])->name('import.create');
Route::post('/import', [ReportController::class, 'import'])->name('import.store');
```

Tambahkan tautan navigasinya di `resources/views/components/nav.blade.php`, tepat setelah tautan `Laporan`:

```php
<a href="{{ route('import.create') }}" class="hover:underline">Impor</a>
```

```bash
git add .
git commit -m "tambah impor produk dari CSV"
git push -u origin csv-import
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** buat berkas `produk.csv` berisi:
> ```
> name,category_id,price
> Kopi Hitam,1,15000
> Teh Manis,1,10000
> Produk Tanpa Kategori,999,5000
> ```
> (sesuaikan `category_id` dengan kategori yang benar-benar ada di datamu). Unggah lewat `/import`. **Yang diharapkan:** pesan "2 produk berhasil diimpor." (baris ketiga dilewati karena `category_id` 999 tidak ada), dan dua produk yang valid muncul di `/products`.

> ⚠️ **Jika gagal:** error `exists:categories,id` yang selalu gagal untuk semua baris berarti `category_id` di CSV tidak cocok dengan ID kategori yang sebenarnya ada, cek lewat `php artisan tinker` dan `Category::pluck('id', 'name')`.

### Langkah 5: Memindahkan impor ke job antrean

Impor beberapa baris selesai dalam hitungan detik, cukup dijalankan langsung seperti langkah sebelumnya. Begitu volumenya naik ke ribuan baris, proses yang sama bisa memakan waktu lama, dan pengguna terpaksa menunggu di depan browser tanpa tahu prosesnya masih berjalan atau tidak. Langkah ini memindahkan proses impor ke job antrean, supaya pengguna langsung mendapat respons sementara prosesnya berjalan di latar belakang.

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

Loop validasi-dan-simpan dari `ReportController::import()` pindah ke metode `handle()` di atas, dengan path berkas CSV disimpan lewat constructor. `Storage::delete()` di akhir membersihkan berkas sementara setelah selesai diproses.

Isi `app/Http/Controllers/ReportController.php` menjadi:

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

`import()` sekarang hanya menyimpan berkas dan mengirim satu job ke antrean lewat `dispatch()`, lalu segera merespons pengguna tanpa menunggu proses impornya selesai sama sekali. Perhatikan `use App\Jobs\ProcessProductImport;` yang baru di bagian atas berkas, menggantikan `use Illuminate\Support\Facades\Validator;` dan `use App\Models\Product;` yang sekarang tidak lagi dipakai langsung di controller ini, karena validasi dan penyimpanan produk sudah pindah ke job.

```bash
git add .
git commit -m "pindahkan impor produk ke job antrean"
git push -u origin import-queue
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** unggah CSV yang sama seperti langkah 4 lewat `/import`. **Yang diharapkan:** pesan "Impor sedang diproses di latar belakang." muncul seketika, tapi produk belum langsung bertambah di `/products`. Jalankan `php artisan queue:work --once` di terminal terpisah, lalu refresh `/products`: produk-produk dari CSV sekarang sudah tersimpan.

> ⚠️ **Jika produk langsung muncul tanpa menjalankan `queue:work`:** periksa `QUEUE_CONNECTION` di `.env`, pastikan bertuliskan `database`, bukan `sync`. Kalau job tidak pernah diproses sama sekali walau `queue:work` sudah dijalankan, periksa apakah ada pesan error di terminal `queue:work` itu sendiri.

### Langkah 6: Bersama, uji integrasi dan review kode

Semua anggota `git checkout main && git pull`, jalankan `php artisan migrate:fresh --seed`, lalu ulangi seluruh checkpoint di laptop masing-masing: laporan dengan filter tanggal, ekspor CSV, dan impor CSV lewat antrean (ingat menjalankan `php artisan queue:work --once` setiap kali menguji impor). Setelah itu, kelompok membaca kode bersama: setiap anggota menjelaskan satu bagian yang **bukan** ia tulis sendiri.

> ✅ **Checkpoint:** seluruh checkpoint di atas berhasil diulang dan menunjukkan hasil yang sama persis di setiap laptop anggota.

### Langkah 7: Tantangan mandiri kelompok dan commit `increment 9`

Bagi tugas berikut di antara anggota, supaya setiap anggota tercatat minimal satu commit bermakna lewat Pull Request masing-masing:

- Tambahkan filter kategori pada halaman laporan, selain rentang tanggal yang sudah ada.
- Tampilkan daftar baris yang gagal diimpor (nomor baris dan pesan errornya) di halaman `/import`, bukan hanya jumlah yang berhasil.
- Identifikasi satu proses lain di Simple POS yang menurutmu layak dipindah ke job antrean, dan jelaskan alasannya di README proyek.
- Tulis satu skenario uji manual untuk impor CSV dengan baris yang campur valid dan tidak valid: langkah dan hasil yang diharapkan.

Setiap tugas: buat branch baru (misalnya `report-category-filter`), kerjakan, commit, push, lalu buka dan merge Pull Request-nya (ikuti alur di atas).

Setelah semua Pull Request masuk dan digabungkan, salah satu anggota menutup pekerjaan kelompok:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 9: laporan, impor/ekspor csv, dan antrean"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** baris teratas `git log --pretty="%h %an %s"` menunjukkan `increment 9: ...`, dan baris-baris di bawahnya menunjukkan nama setiap anggota kelompok.

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta dosen:

- Link repositori GitHub kelompok.
- Screenshot halaman `/reports` dengan total penjualan dan filter tanggal.
- Screenshot pesan "Impor sedang diproses di latar belakang." dan hasil `/products` setelah `queue:work` memprosesnya.
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel pembagian tugas: nama anggota | langkah/tugas yang dikerjakan | hash commit.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---:|---|---|
| Langkah kerja tuntas (kelompok) | 40% | Langkah 1-7 selesai, laporan, ekspor, impor, dan antrean berfungsi sesuai checkpoint | Sebagian besar langkah selesai, laporan dan impor berjalan |
| Checkpoint terverifikasi (kelompok) | 25% | Screenshot laporan dan hasil impor via antrean, tabel pembagian tugas, dan git log lengkap dan benar | Sebagian checkpoint terbukti |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna atas nama tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Kerapian repositori dan commit | 10% | Pesan `increment 9` persis, tanpa menyertakan `vendor/`, `node_modules/`, `.env`, PR di-merge rapi (bukan squash) | Commit ada, pesan kurang rapi atau PR di-squash |
