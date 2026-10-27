# Jobsheet Praktikum Kelompok: Pertemuan 10
## Merancang dan Membangun REST API (Kerja Kelompok)

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | 10 (Minggu 10) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK 3: Mahasiswa mampu menerapkan mekanisme autentikasi, otorisasi, dan pengembangan API pada aplikasi web. |
| **Mode Pengerjaan** | Kelompok (sama seperti Pertemuan 3-9), satu repositori GitHub bersama per kelompok |
| **Kode Awal** | repositori kelompok hasil Pertemuan 9 (lanjutkan `main`-nya). Kalau repositori kelompok bermasalah, buat salinan dari template `github.com/se-polinema/simple-pos-ch08` lewat **Use this template** |

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet kelompok ini, kamu mampu:

1. Memasang Sanctum dan merancang endpoint `POST /api/login` yang menerbitkan token untuk klien yang tidak punya cookie jar.
2. Membangun endpoint `GET /api/products` yang dilindungi token dan mengurasi bentuk responsnya lewat API Resource.
3. Membangun endpoint `POST /api/transactions` yang membedakan penanganan galat 401 dan 422, dan mengonsumsi ketiga endpoint itu lewat klien HTTP sungguhan di luar siklus request web.
4. Mendokumentasikan ketiga endpoint memakai spesifikasi OpenAPI.
5. Memanggil endpoint JSON dari halaman web sendiri lewat `fetch` (AJAX): route di `web.php`, token CSRF, header `Accept: application/json`, dan penanganan status 201 dan 422.

## B. Persiapan dan Prasyarat

- **Alat**: sama seperti Pertemuan 3-9 (PHP 8.2+, Composer, Node.js, Git).
- **Identitas git**: sudah diatur sejak Pertemuan 3.
- **Verifikasi cepat** sebelum mulai:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  php artisan migrate:fresh --seed
  ```
  > ✅ **Checkpoint:** baris teratas menunjukkan commit `increment 9: ...`, dan perintah `migrate:fresh --seed` berjalan tanpa error.

## C. Langkah Kerja

Alur kerja sama seperti Pertemuan 3-9: setiap langkah dikerjakan di branch terpisah dari `main`, digabungkan lewat Pull Request dengan **Create a merge commit** (bukan squash), lalu semua anggota `git pull` sebelum membuat branch berikutnya.

### Langkah 1: Memasang Sanctum

Halaman web Simple POS memakai sesi berbasis cookie (Pertemuan 7), cocok untuk browser yang menyimpan cookie otomatis. Klien API (aplikasi mobile, skrip luar) tidak punya cookie jar seperti itu, sehingga butuh mekanisme autentikasi yang berbeda: token yang disimpan sendiri oleh klien dan dikirim ulang eksplisit pada setiap request.

Buat branch baru dari `main` terbaru, lalu pasang Sanctum:

```bash
git checkout main
git pull
git checkout -b api-auth
composer require laravel/sanctum
php artisan install:api
```

`install:api` membuat `routes/api.php`, mendaftarkan middleware `auth:sanctum`, dan menyiapkan migrasi tabel `personal_access_tokens`. Jalankan migrasinya:

```bash
php artisan migrate
```

Tambahkan trait `HasApiTokens` ke `app/Models/User.php` supaya model `User` bisa menerbitkan token. Isi `app/Models/User.php` menjadi:

```php
<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'is_active',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }
}
```

```bash
git add .
git commit -m "pasang sanctum untuk autentikasi api"
git push -u origin api-auth
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** `php artisan migrate:status` menampilkan `create_personal_access_tokens_table` dengan status `Ran`.

### Langkah 2: Endpoint login dan penerbitan token

Buat branch baru dari `main` terbaru, misalnya `api-login`:

```bash
git checkout main
git pull
git checkout -b api-login
php artisan make:controller Api/AuthController
```

Isi `app/Http/Controllers/Api/AuthController.php` menjadi:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($credentials)) {
            return response()->json(['message' => 'Kredensial tidak valid.'], 401);
        }

        $user = Auth::user();
        $token = $user->createToken('mobile-kasir')->plainTextToken;

        return response()->json(['token' => $token]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout berhasil.']);
    }
}
```

`createToken('mobile-kasir')` menghasilkan token baru yang tersimpan dalam bentuk hash di tabel `personal_access_tokens`, dan `->plainTextToken` adalah satu-satunya kesempatan token mentah itu terlihat. Setelah respons ini, server tidak bisa lagi menunjukkan ulang token yang sama dalam bentuk terbaca.

Isi `routes/api.php` menjadi:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
```

Route login didaftarkan di luar middleware `auth:sanctum`, karena klien memang belum punya token saat login.

```bash
git add .
git commit -m "tambah endpoint login api"
git push -u origin api-login
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** jalankan `php artisan serve`, lalu di terminal lain:
> ```bash
> curl -X POST http://127.0.0.1:8000/api/login \
>   -d "email=kasir@pos.test&password=password"
> ```
> **Yang diharapkan:** respons JSON berisi `{"token":"1|xxxxxxxxxxxxxxxxxxxx"}`. Salin nilai token itu (termasuk angka dan tanda `|` di depannya), akan dipakai pada langkah berikutnya.

> ⚠️ **Jika gagal:** pesan `{"message":"Kredensial tidak valid."}` berarti email atau password salah ketik, bukan masalah kode; pastikan database sudah di-seed ulang lewat `migrate:fresh --seed` di langkah B.

### Langkah 3: Endpoint produk yang dilindungi token

Buat branch baru dari `main` terbaru, misalnya `api-products`:

```bash
git checkout main
git pull
git checkout -b api-products
php artisan make:resource ProductResource
php artisan make:controller Api/ProductController
```

Isi `app/Http/Resources/ProductResource.php` menjadi:

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'price' => $this->price,
            'category' => $this->category->name,
        ];
    }
}
```

`JsonResource` memastikan endpoint mengembalikan bentuk JSON yang sudah dikurasi, bukan hasil `toJson()` mentah dari model Eloquent yang bisa saja ikut membocorkan kolom internal seperti `created_at` atau relasi yang tidak relevan bagi klien.

Isi `app/Http/Controllers/Api/ProductController.php` menjadi:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Models\Product;

class ProductController extends Controller
{
    public function index()
    {
        return ProductResource::collection(Product::with('category')->get());
    }
}
```

Isi `routes/api.php` menjadi:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/products', [ProductController::class, 'index']);
});
```

Route yang perlu dilindungi cukup dibungkus middleware `auth:sanctum`, mirip pola `role:admin` pada Pertemuan 7, hanya saja yang diperiksa kali ini adalah keberadaan dan keabsahan token lewat header `Authorization`, bukan sesi cookie.

```bash
git add .
git commit -m "tambah endpoint produk terproteksi token"
git push -u origin api-products
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** coba dulu tanpa token:
> ```bash
> curl -i -H "Accept: application/json" http://127.0.0.1:8000/api/products
> ```
> **Yang diharapkan:** respons `401 Unauthorized` dengan pesan `{"message":"Unauthenticated."}`. Lalu coba dengan token dari Langkah 2:
> ```bash
> curl -H "Accept: application/json" \
>   -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx" \
>   http://127.0.0.1:8000/api/products
> ```
> **Yang diharapkan:** respons JSON berisi daftar produk, dibungkus `{"data": [...]}`.

> ⚠️ **Jika permintaan tanpa token malah mengembalikan redirect ke `/login`, bukan 401:** periksa apakah header `Accept: application/json` sudah disertakan di perintah `curl`. Tanpa header ini, Laravel tidak tahu klien mengharapkan JSON dan menganggapnya permintaan browser biasa, lalu mengarahkan ke halaman login web alih-alih mengembalikan 401. Setiap permintaan ke endpoint API, termasuk yang dikirim lewat klien HTTP, sebaiknya selalu menyertakan header ini.

### Langkah 4: Endpoint transaksi

Buat branch baru dari `main` terbaru, misalnya `api-transactions`:

```bash
git checkout main
git pull
git checkout -b api-transactions
php artisan make:controller Api/TransactionController
```

Endpoint ini memakai ulang `StoreTransactionRequest` yang sudah ada sejak halaman transaksi web, karena aturan validasinya (daftar `items` dengan `product_id` dan `qty`) sama persis. Isi `app/Http/Controllers/Api/TransactionController.php` menjadi:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Models\Product;
use App\Models\Transaction;
use App\Models\TransactionDetail;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function store(StoreTransactionRequest $request)
    {
        $validated = $request->validated();

        $transaction = DB::transaction(function () use ($validated, $request) {
            $transaction = Transaction::create([
                'user_id' => $request->user()->id,
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

            return $transaction;
        });

        return response()->json([
            'data' => [
                'id' => $transaction->id,
                'total' => $transaction->total,
            ],
        ], 201);
    }
}
```

`$request->user()->id` mengambil identitas dari token yang sedang dipakai, bukan dari input yang dikirim klien, supaya transaksi selalu tercatat atas nama pemilik token yang sebenarnya.

Isi `routes/api.php` menjadi:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
});
```

```bash
git add .
git commit -m "tambah endpoint transaksi api"
git push -u origin api-transactions
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** cari dulu `product_id` yang valid lewat `php artisan tinker` dan `Product::first()->id`, lalu:
> ```bash
> curl -i -H "Accept: application/json" \
>   -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx" \
>   -H "Content-Type: application/json" \
>   -X POST http://127.0.0.1:8000/api/transactions \
>   -d '{"items":[{"product_id":1,"qty":2}]}'
> ```
> **Yang diharapkan:** respons `201 Created` berisi `{"data":{"id":...,"total":...}}`. Coba juga dengan `product_id` yang tidak ada (misalnya `99999`); **yang diharapkan:** respons `422 Unprocessable Content` dengan pesan validasi, bukan 500.

> ⚠️ **Jika gagal dengan 401 padahal token baru saja didapat:** token di atas sudah dipakai sebagai contoh di dokumen ini, nilainya tidak benar-benar valid di databasemu; pakai token asli hasil `curl` ke `/api/login` pada Langkah 2, bukan menyalin contoh ini apa adanya.

### Langkah 5: Klien HTTP sungguhan untuk kasir mobile

Endpoint yang sudah dibangun tidak ada gunanya kalau tidak pernah benar-benar dipanggil dari luar. Langkah ini membangun klien yang memanggilnya lewat facade `Http` milik Laravel, polanya sama saja dipakai dari bahasa atau kerangka kerja lain (Flutter, React Native, dan sejenisnya); yang berubah cuma cara memanggil HTTP-nya.

Buat branch baru dari `main` terbaru, misalnya `api-client-demo`:

```bash
git checkout main
git pull
git checkout -b api-client-demo
php artisan make:command ApiClientDemo
```

Isi `app/Console/Commands/ApiClientDemo.php` menjadi:

```php
<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class ApiClientDemo extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'api:demo';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Demonstrate consuming the Simple POS API as an external client';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $baseUrl = 'http://127.0.0.1:8000';

        $login = Http::acceptJson()->post("{$baseUrl}/api/login", [
            'email' => 'kasir@pos.test',
            'password' => 'password',
        ]);

        if ($login->failed()) {
            $this->error('Login gagal: '.$login->json('message'));

            return self::FAILURE;
        }

        $token = $login->json('token');
        $this->info("Login berhasil, token: {$token}");

        $products = Http::acceptJson()->withToken($token)->get("{$baseUrl}/api/products");

        if ($products->failed()) {
            $this->error('Token kedaluwarsa/dicabut, atau server sedang bermasalah.');

            return self::FAILURE;
        }

        $this->info('Jumlah produk: '.count($products->json('data')));

        $productId = Product::first()->id;

        $transaction = Http::acceptJson()->withToken($token)->post("{$baseUrl}/api/transactions", [
            'items' => [['product_id' => $productId, 'qty' => 1]],
        ]);

        match ($transaction->status()) {
            201 => $this->info('Transaksi tersimpan: '.json_encode($transaction->json('data'))),
            401 => $this->error('Token tidak valid, login ulang.'),
            422 => $this->error('Input ditolak: '.$transaction->json('message')),
            default => $this->error('Galat lain: '.$transaction->status()),
        };

        return self::SUCCESS;
    }
}
```

`$login->failed()` diperiksa sebelum kode lanjut membaca `$login->json('token')`; tanpa pemeriksaan ini, kredensial yang salah (401) akan membuat `$token` bernilai `null` tanpa pernah jelas kenapa, dan galat itu baru muncul beberapa langkah kemudian di tempat yang membingungkan. `Http::acceptJson()` menambahkan header `Accept: application/json` secara otomatis pada setiap request, mencegah masalah redirect-ke-login yang ditemukan di Langkah 3.

```bash
git add .
git commit -m "tambah klien http demo untuk konsumsi api"
git push -u origin api-client-demo
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** pastikan `php artisan serve` sedang berjalan di port 8000, lalu di terminal lain:
> ```bash
> php artisan api:demo
> ```
> **Yang diharapkan:** tiga baris output berurutan, "Login berhasil, token: ...", "Jumlah produk: ...", dan "Transaksi tersimpan: {...}", persis seperti kalau dipanggil lewat `curl` pada langkah-langkah sebelumnya, hanya kali ini dari kode PHP yang bisa diperluas jadi aplikasi klien sungguhan.

> ⚠️ **Jika langkah kedua atau ketiga selalu gagal dengan 401** meski login di langkah pertama sukses, periksa apakah token benar-benar diteruskan ke `withToken()` (bukan variabel kosong karena langkah pertama sebenarnya gagal tapi tidak diperiksa).

### Langkah 6: Mendokumentasikan API dengan OpenAPI

Dokumentasi API yang hanya berupa catatan teks di README cepat basi: begitu satu field respons berubah nama, tidak ada yang memaksa siapa pun memperbarui catatan itu. OpenAPI mendeskripsikan endpoint dalam format terstruktur yang bisa dibaca alat lain.

Buat branch baru dari `main` terbaru, misalnya `api-docs`:

```bash
git checkout main
git pull
git checkout -b api-docs
```

Buat berkas `docs/openapi.yaml` di root proyek (belum ada bawaan Laravel; ini berkas baru yang berdiri sendiri, tidak dibaca otomatis oleh aplikasi) berisi:

```yaml
openapi: 3.0.0
info:
  title: Simple POS API
  version: 1.0.0
paths:
  /api/login:
    post:
      summary: Login dan dapatkan token
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                email: { type: string }
                password: { type: string }
      responses:
        '200':
          description: Token berhasil diterbitkan
          content:
            application/json:
              schema:
                type: object
                properties:
                  token: { type: string }
        '401':
          description: Kredensial tidak valid
          content:
            application/json:
              schema:
                type: object
                properties:
                  message: { type: string }
  /api/products:
    get:
      summary: Ambil daftar produk
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Daftar produk
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      type: object
                      properties:
                        id: { type: integer }
                        name: { type: string }
                        price: { type: integer }
                        category: { type: string }
        '401':
          description: Token tidak ada atau tidak valid
  /api/transactions:
    post:
      summary: Buat transaksi baru
      security:
        - bearerAuth: []
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                items:
                  type: array
                  items:
                    type: object
                    properties:
                      product_id: { type: integer }
                      qty: { type: integer }
      responses:
        '201':
          description: Transaksi berhasil disimpan
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: object
                    properties:
                      id: { type: integer }
                      total: { type: integer }
        '401':
          description: Token tidak ada atau tidak valid
        '422':
          description: Input tidak valid, misalnya product_id tidak ditemukan
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
```

Struktur `paths` memetakan path URL ke method HTTP, dan setiap method mendeskripsikan bentuk `requestBody` yang diterima beserta `responses` yang mungkin dikembalikan, lengkap dengan kode status HTTP-nya.

```bash
git add .
git commit -m "tambah dokumentasi openapi"
git push -u origin api-docs
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** buka `editor.swagger.io`, tempel isi `docs/openapi.yaml` ke sana. **Yang diharapkan:** panel pratinjau di sisi kanan menampilkan ketiga endpoint sebagai daftar interaktif yang bisa diklik, tanpa galat sintaks YAML.

> ⚠️ **Jika panel pratinjau menampilkan pesan galat:** itu hampir selalu indentasi YAML yang salah (YAML memakai spasi, bukan tab, dan tiap level indentasi harus konsisten); bandingkan ulang lekukan tiap baris dengan contoh di atas.

### Langkah 7: AJAX dari halaman web

Token Sanctum dipakai klien di luar browser. Halaman web Simple POS sendiri juga bisa memanggil server di background lewat `fetch`, tanpa reload, memakai sesi cookie yang sama seperti di Pertemuan 7. Bedanya dengan API di Langkah 1-6: route-nya ada di `routes/web.php` (bukan `api.php`), request yang mengubah data perlu token CSRF, dan klien harus meminta JSON lewat header `Accept` supaya galat validasi kembali sebagai JSON 422, bukan redirect.

Fitur yang dibuat: halaman `/quick-categories` untuk admin. Form menambah kategori lewat `fetch`, daftar kategori bertambah tanpa reload, dan galat validasi muncul di bawah kolom isian.

Buat branch baru dari `main` terbaru, misalnya `ajax-quick-category`, lalu buat controller dan view-nya lewat artisan:

```bash
git checkout main
git pull
git checkout -b ajax-quick-category
php artisan make:controller QuickCategoryController
php artisan make:view quick-categories.index
```

`Category::create()` butuh `$fillable` (Pertemuan 6), sedangkan model `Category` belum punya. Isi `app/Models/Category.php` menjadi:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    protected $fillable = ['name'];

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }
}
```

Browser perlu tahu token CSRF sesi yang sedang aktif. Cara umumnya: simpan token di tag `<meta>` pada layout, lalu JavaScript membacanya dari sana. Isi `resources/views/layouts/app.blade.php` menjadi:

```php
<!DOCTYPE html>
<html lang="id">
<head>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Simple POS')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <x-nav />
    <main>@yield('content')</main>
</body>
</html>
```

Isi `routes/web.php` menjadi (dua route `quick-categories` ditambahkan di dalam grup `role:admin`, jadi halaman ini hanya bisa dibuka admin):

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\QuickCategoryController;
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
        Route::get('/quick-categories', [QuickCategoryController::class, 'index'])->name('quick-categories.index');
        Route::post('/quick-categories', [QuickCategoryController::class, 'store'])->name('quick-categories.store');
    });
});
```

Isi `app/Http/Controllers/QuickCategoryController.php` menjadi. Action `store` memvalidasi dengan `validate()` seperti di Pertemuan 6, lalu mengembalikan JSON dengan kode status `201 Created`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class QuickCategoryController extends Controller
{
    public function index(): View
    {
        return view('quick-categories.index', [
            'categories' => Category::orderBy('name')->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:categories,name'],
        ]);

        $category = Category::create($data);

        return response()->json($category, 201);
    }
}
```

Isi `resources/views/quick-categories/index.blade.php` menjadi. Komponen Alpine di dalam `x-data` mengirim `fetch` dengan tiga header (`Accept`, `Content-Type`, `X-CSRF-TOKEN`), lalu membaca `res.status` sebelum membaca isi respons:

```php
@extends('layouts.app')

@section('title', 'Kategori Cepat')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Tambah Kategori Cepat</h1>

    <div x-data="{
        name: '',
        errors: {},
        categories: {{ \Illuminate\Support\Js::from($categories) }},
        loading: false,

        async submit() {
            if (this.loading) return;
            this.loading = true;
            this.errors = {};

            try {
                const meta = document.head.querySelector('meta[name=csrf-token]');
                const res = await fetch('{{ route('quick-categories.store') }}', {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': meta.content,
                    },
                    body: JSON.stringify({ name: this.name }),
                });

                if (res.status === 201) {
                    this.categories.push(await res.json());
                    this.name = '';
                } else if (res.status === 422) {
                    this.errors = (await res.json()).errors;
                } else if (res.status === 401 || res.status === 419) {
                    location.reload();
                } else {
                    this.errors = { name: ['Terjadi kesalahan, coba lagi.'] };
                }
            } catch (e) {
                this.errors = { name: ['Gagal terhubung ke server.'] };
            } finally {
                this.loading = false;
            }
        },
    }" class="max-w-md">
        <form @submit.prevent="submit()" class="flex gap-2 items-start mb-4">
            <div class="flex-1">
                <input type="text" x-model="name" placeholder="Nama kategori baru"
                       class="w-full border rounded-md px-3 py-2 text-sm">
                <p x-text="errors.name?.[0]" class="text-sm text-red-600 mt-1"></p>
            </div>
            <button type="submit" :disabled="loading"
                    class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm disabled:opacity-50">
                <span x-show="!loading">Tambah</span>
                <span x-show="loading">Mengirim...</span>
            </button>
        </form>

        <ul class="list-disc pl-5 text-sm">
            <template x-for="c in categories" :key="c.id">
                <li x-text="c.name"></li>
            </template>
        </ul>
    </div>
@endsection
```

`@submit.prevent` mencegah form dikirim dan halaman reload. `:disabled="loading"` mencegah kategori tersimpan dobel kalau tombol diklik dua kali.

```bash
git add .
git commit -m "tambah halaman kategori cepat dengan ajax"
git push -u origin ajax-quick-category
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** login sebagai admin, buka `/quick-categories`, lalu buka DevTools (F12) tab **Network**, filter **Fetch/XHR**. Ketik `Minuman Dingin` dan klik **Tambah**. **Yang diharapkan:** muncul satu request `quick-categories` dengan method `POST` dan status **201**; tab **Response** berisi JSON kategori baru; nama itu muncul di daftar tanpa halaman reload (tidak ada request tipe `document` baru).

> ✅ **Checkpoint:** kosongkan kolom isian lalu klik **Tambah**. **Yang diharapkan:** request `POST` berstatus **422**, tab **Response** berisi `{"message": ..., "errors": {"name": [...]}}`, dan pesan galat berwarna merah muncul di bawah kolom isian. Coba juga mengirim `Minuman Dingin` sekali lagi: aturan `unique` menolaknya dengan 422.

> ✅ **Checkpoint (eksperimen):** di `resources/views/quick-categories/index.blade.php`, hapus baris `'Accept': 'application/json',` sementara, simpan, muat ulang halaman, lalu kirim form dengan kolom kosong. **Yang diharapkan:** di tab **Network** request `POST` berstatus **302** (redirect ke halaman sebelumnya), dan pesan galat di bawah kolom isian berubah jadi "Gagal terhubung ke server." karena `res.json()` gagal membaca HTML. Kembalikan barisnya setelah selesai.

> ⚠️ **Jika gagal:** (a) status **419 Page Expired**: tag `<meta name="csrf-token">` belum ada di layout, atau baris `'X-CSRF-TOKEN'` salah ketik; (b) status **405 Method Not Allowed**: pastikan route `quick-categories.store` memakai `Route::post`; (c) status **401** padahal sudah login: pastikan kamu login lewat halaman web, bukan memakai token Sanctum, dan route ada di `web.php`; (d) status **403** atau halaman tidak terbuka: akun yang dipakai bukan admin; (e) error `Alpine is not defined` di console: jalankan `npm run dev` (Pertemuan 3).

### Langkah 8: Bersama, uji integrasi dan review kode

Semua anggota `git checkout main && git pull`, jalankan `php artisan migrate:fresh --seed`, lalu ulangi setiap checkpoint di atas secara berurutan: login, produk tanpa token (401), produk dengan token, transaksi valid (201), transaksi tidak valid (422), `php artisan api:demo`, pratinjau `docs/openapi.yaml` di Swagger editor, dan halaman `/quick-categories` (201 dan 422 di tab Network). Setiap checkpoint harus menunjukkan hasil yang sama persis di laptop setiap anggota.

> ✅ **Checkpoint:** seluruh checkpoint di atas berhasil diulang dan menunjukkan hasil yang sama di laptop setiap anggota kelompok.

### Langkah 9: Tantangan mandiri kelompok dan commit `increment 10`

Bagi tugas berikut di antara anggota, supaya setiap anggota tercatat minimal satu commit bermakna lewat Pull Request mandiri.

- Tambahkan endpoint baru `GET /api/categories`, lengkap dengan `CategoryResource`-nya.
- Lengkapi dokumentasi OpenAPI untuk endpoint `GET /api/products`, termasuk skema query parameter untuk paginasi.
- Ubah `php artisan api:demo` agar mencoba login dengan kata sandi yang salah lebih dulu, lalu amati bagaimana kode itu berhenti pada langkah pertama alih-alih melanjutkan dengan token kosong.
- Uji ketiga endpoint lewat Postman atau Insomnia (bukan `curl`), lalu tuliskan satu paragraf perbandingan pengalamannya dengan `curl` di `docs/openapi.yaml` sebagai komentar YAML.

Setelah semua Pull Request masuk dan digabungkan, salah satu anggota menutup pertemuan ini:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 10: sanctum, endpoint rest api, dan dokumentasi openapi"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** baris teratas `git log` menunjukkan commit `increment 10: ...`, dan baris-baris di bawahnya menunjukkan nama setiap anggota kelompok.

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta dosen:

- Link repositori GitHub kelompok.
- Screenshot terminal yang menampilkan output `php artisan api:demo` secara lengkap.
- Screenshot panel pratinjau Swagger editor menampilkan `docs/openapi.yaml`.
- Screenshot DevTools tab Network pada `/quick-categories` yang menampilkan request `POST` berstatus 201 dan satu request berstatus 422.
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel ringkas tantangan mandiri: anggota, tantangan yang dikerjakan, dan link Pull Request.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---|---|---|
| Langkah kerja tuntas (kelompok) | 40% | Langkah 1-8 selesai: login, produk, transaksi, klien HTTP, OpenAPI, dan AJAX kategori cepat berfungsi sesuai checkpoint | Sebagian besar langkah selesai, minimal login dan satu endpoint terproteksi berjalan |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna dari tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Kerapian repositori dan commit | 10% | Pesan `increment 10` persis, tanpa menyertakan `vendor/`, `node_modules/`, `.env`, PR di-merge rapi (bukan squash) | Commit ada, pesan kurang rapi atau PR di-squash |
| Checkpoint terverifikasi (kelompok) | 25% | Screenshot `api:demo`, Swagger editor, dan tab Network (201 dan 422) lengkap dan menunjukkan hasil yang benar | Sebagian checkpoint terbukti |
