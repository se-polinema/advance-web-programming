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

### Langkah 7: Bersama, uji integrasi dan review kode

Semua anggota `git checkout main && git pull`, jalankan `php artisan migrate:fresh --seed`, lalu ulangi setiap checkpoint di atas secara berurutan: login, produk tanpa token (401), produk dengan token, transaksi valid (201), transaksi tidak valid (422), `php artisan api:demo`, dan pratinjau `docs/openapi.yaml` di Swagger editor. Setiap checkpoint harus menunjukkan hasil yang sama persis di laptop setiap anggota.

> ✅ **Checkpoint:** seluruh checkpoint di atas berhasil diulang dan menunjukkan hasil yang sama di laptop setiap anggota kelompok.

### Langkah 8: Tantangan mandiri kelompok dan commit `increment 10`

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
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel ringkas tantangan mandiri: anggota, tantangan yang dikerjakan, dan link Pull Request.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---|---|---|
| Langkah kerja tuntas (kelompok) | 40% | Langkah 1-7 selesai: login, produk, transaksi, klien HTTP, dan OpenAPI berfungsi sesuai checkpoint | Sebagian besar langkah selesai, minimal login dan satu endpoint terproteksi berjalan |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna dari tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Kerapian repositori dan commit | 10% | Pesan `increment 10` persis, tanpa menyertakan `vendor/`, `node_modules/`, `.env`, PR di-merge rapi (bukan squash) | Commit ada, pesan kurang rapi atau PR di-squash |
| Checkpoint terverifikasi (kelompok) | 25% | Screenshot `api:demo` dan Swagger editor lengkap dan menunjukkan hasil yang benar | Sebagian checkpoint terbukti |
