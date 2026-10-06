# Jobsheet Praktikum Kelompok: Pertemuan 7
## Autentikasi, Otorisasi, dan RBAC (Kerja Kelompok)

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | 7 (Minggu 7) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK 3: Mahasiswa mampu menerapkan mekanisme autentikasi, otorisasi, dan pengembangan API pada aplikasi web. |
| **Mode Pengerjaan** | Kelompok (sama seperti Pertemuan 3-6), satu repositori GitHub bersama per kelompok |
| **Kode Awal** | repositori kelompok hasil Pertemuan 6 (lanjutkan `main`-nya). Kalau repositori kelompok bermasalah, buat salinan dari template `github.com/se-polinema/simple-pos-ch06` lewat **Use this template** |

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet kelompok ini, kamu mampu:

1. Menambahkan kolom `role` dan `is_active` pada tabel `users` lewat migrasi baru.
2. Membuat login dan logout yang memakai `Auth::attempt()`, lalu memperbarui sesi setelah login berhasil.
3. Membuat middleware `role:admin` sendiri, lalu mendaftarkannya sebagai alias di `bootstrap/app.php`.
4. Membatasi halaman produk dan kategori hanya untuk peran admin, dan membuktikannya dengan dua akun berperan berbeda.
5. Menjelaskan mengapa kata sandi disimpan sebagai hash dan mengapa `401` dan `403` berbeda.

## B. Persiapan dan Prasyarat

- **Alat**: sama seperti Pertemuan 3-6 (PHP 8.2+, Composer, Node.js, Git), ditambah akun GitHub aktif untuk setiap anggota kelompok.
- **Identitas git per anggota**: sudah diatur sejak Pertemuan 3. Kalau memakai komputer lab bersama, gunakan `git config --local` di dalam folder proyek, bukan `--global`.
- **Pembagian kelompok**: bekerja dalam kelompok sesuai pembagian dosen. Jobsheet ini tidak menentukan siapa mengerjakan langkah yang mana, itu keputusan kelompok sendiri. Pastikan pembagian membuat tiap anggota mendapat minimal satu commit bermakna lewat Pull Request masing-masing.
- **Verifikasi cepat** sebelum mulai:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  php artisan migrate:fresh --seed
  ```
  > ✅ **Checkpoint:** baris teratas menunjukkan commit `increment 6: ...`, dan perintah `migrate:fresh --seed` berjalan tanpa error.

## C. Langkah Kerja

Alur kerja sama seperti Pertemuan 3-6: setiap langkah dikerjakan di branch terpisah dari `main`, digabungkan lewat Pull Request dengan **Create a merge commit** (bukan squash), lalu semua anggota `git pull` sebelum membuat branch berikutnya.

Di langkah-langkah berikut, setiap berkas yang diubah ditampilkan isi lengkapnya. Kalau isinya sudah sama dengan yang kamu tulis sebelumnya di luar bagian yang diubah, cukup pastikan isi akhirnya sama persis dengan yang ditampilkan.

### Langkah 1: Menyiapkan branch dan membagi tugas

Buat branch baru dari `main` terbaru, misalnya `user-role-migration`:

```bash
git checkout main
git pull
git checkout -b user-role-migration
```

Sepakati pembagian langkah 2 sampai 8 antaranggota. Kerjakan langkah 2 dan 3 dulu, karena langkah berikutnya bergantung pada kolom `role` dan model `User` yang sudah benar.

> ✅ **Checkpoint:** pembagian tugas sudah disepakati dan branch `user-role-migration` sudah aktif.

### Langkah 2: Menambahkan kolom `role` dan `is_active` ke tabel `users`

Peran (`admin` atau `kasir`) dan status aktif akun disimpan di tabel `users`, lewat migrasi baru. Jangan mengubah migrasi tabel `users` yang sudah ada.

```bash
php artisan make:migration add_role_to_users_table
php artisan make:migration add_is_active_to_users_table
```

Isi berkas migrasi `add_role_to_users_table` menjadi:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default('kasir')->after('email');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('role');
        });
    }
};
```

Isi berkas migrasi `add_is_active_to_users_table` menjadi:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_active')->default(true)->after('role');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('is_active');
        });
    }
};
```

Default `kasir` berarti setiap pengguna baru otomatis berperan kasir, kecuali dibuat sebagai admin secara eksplisit. Itu disengaja: peran dengan hak lebih besar harus selalu dipilih dengan sengaja, tidak diberikan diam-diam.

```bash
git add .
git commit -m "tambah kolom role dan is_active pada users"
git push -u origin user-role-migration
```

Buka Pull Request ke `main`, merge dengan **Create a merge commit**, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** `php artisan migrate:fresh` berjalan tanpa error, dan `php artisan tinker` lalu `Schema::hasColumns('users', ['role', 'is_active'])` mengembalikan `true`.

> ⚠️ **Jika gagal:** error `duplicate column name: role` berarti migrasi yang sama sudah pernah dibuat di komputer ini. Hapus berkas duplikatnya di `database/migrations/` (hanya yang baru kamu buat di langkah ini), lalu jalankan `php artisan migrate:fresh` lagi.

### Langkah 3: Memperbarui model `User`

Model `User` perlu mengizinkan kolom baru diisi secara massal, mengubah kata sandi menjadi hash otomatis, dan membaca `is_active` sebagai boolean.

Branch baru dari `main` terbaru, misalnya `user-model`:

```bash
git checkout main
git pull
git checkout -b user-model
```

Isi `app/Models/User.php` menjadi:

```php
<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

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

Kolom baru masuk ke daftar `$fillable`, sama seperti yang sudah kamu lakukan di model `Product` dan `Category`. Cast `password => hashed` berarti setiap kali kamu menulis `password` ke model, Laravel menghitung hash-nya dulu. Kata sandi asli tidak pernah masuk ke basis data.

```bash
git add .
git commit -m "perbarui model User dengan role, is_active, dan hash kata sandi"
git push -u origin user-model
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** `php artisan tinker` lalu `App\Models\User::make(['password' => 'rahasia'])->password` menampilkan string hash panjang, bukan `rahasia`.

> ⚠️ **Jika gagal:** error `MassAssignmentException: Add [password] to fillable property...` berarti `$fillable` di `User.php` belum tersimpan atau belum mencantumkan kolom yang dipakai.

### Langkah 4: Akun demo admin dan kasir

Simple POS perlu dua akun demo untuk diuji: satu admin, satu kasir. Akun ini dibuat lewat seeder terpisah supaya seeder Pertemuan 4 tetap utuh.

Branch baru dari `main` terbaru, misalnya `demo-users`:

```bash
git checkout main
git pull
git checkout -b demo-users
php artisan make:seeder DemoUserSeeder
```

Isi `database/seeders/DemoUserSeeder.php` menjadi:

```php
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DemoUserSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@pos.test'],
            ['name' => 'Admin Kafe', 'role' => 'admin', 'password' => 'password'],
        );

        User::firstOrCreate(
            ['email' => 'kasir@pos.test'],
            ['name' => 'Kasir Kafe', 'role' => 'kasir', 'password' => 'password'],
        );
    }
}
```

Kata sandi `password` di atas hanya untuk demo di komputer lokal. Model `User` dari langkah 3 akan menghitung hash-nya otomatis.

Panggil seeder ini dari `DatabaseSeeder`. Isi `database/seeders/DatabaseSeeder.php` menjadi (satu baris `$this->call(DemoUserSeeder::class);` ditambahkan di awal metode `run()`, sisanya sama dengan Pertemuan 4):

```php
<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(DemoUserSeeder::class);

        $user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        $categoryIds = collect(['Makanan', 'Minuman', 'Snack', 'Lainnya'])
            ->map(fn (string $name) => Category::create(['name' => $name])->id)
            ->all();

        $products = [];
        foreach ($categoryIds as $categoryId) {
            for ($i = 0; $i < 75; $i++) {
                $products[] = [
                    'category_id' => $categoryId,
                    'name' => fake()->words(2, true),
                    'price' => fake()->numberBetween(3000, 50000),
                    'stock' => fake()->numberBetween(0, 200),
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
        }

        foreach (array_chunk($products, 50) as $chunk) {
            DB::table('products')->insert($chunk);
        }

        $productPrices = DB::table('products')->pluck('price', 'id');
        $productIds = $productPrices->keys()->all();

        for ($t = 0; $t < 2500; $t++) {
            DB::transaction(function () use ($user, $productIds, $productPrices) {
                $itemCount = fake()->numberBetween(1, 4);
                $total = 0;
                $details = [];

                for ($i = 0; $i < $itemCount; $i++) {
                    $productId = fake()->randomElement($productIds);
                    $qty = fake()->numberBetween(1, 3);
                    $subtotal = $productPrices[$productId] * $qty;
                    $total += $subtotal;

                    $details[] = [
                        'product_id' => $productId,
                        'qty' => $qty,
                        'subtotal' => $subtotal,
                    ];
                }

                $transactionId = DB::table('transactions')->insertGetId([
                    'user_id' => $user->id,
                    'total' => $total,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                foreach ($details as &$detail) {
                    $detail['transaction_id'] = $transactionId;
                    $detail['created_at'] = now();
                    $detail['updated_at'] = now();
                }

                DB::table('transaction_details')->insert($details);
            });
        }
    }
}
```

```bash
git add .
git commit -m "tambah akun demo admin dan kasir lewat seeder"
git push -u origin demo-users
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main`, pull, dan jalankan `php artisan migrate:fresh --seed` di laptop masing-masing.

> ✅ **Checkpoint:** `php artisan tinker` lalu `App\Models\User::where('role', 'admin')->pluck('email')` menampilkan `admin@pos.test`, dan `...where('role', 'kasir')` menampilkan `kasir@pos.test`.

> ⚠️ **Jika gagal:** error `Class "Database\Seeders\DemoUserSeeder" not found` berarti `php artisan make:seeder DemoUserSeeder` belum dijalankan, atau berkasnya belum tersimpan di `database/seeders/`.

### Langkah 5: Login dan logout

Login memakai `Auth::attempt()`. Setelah kredensial cocok, server membuat ID sesi baru (`session()->regenerate()`) supaya ID sesi lama, yang mungkin sudah diketahui orang lain, tidak bisa dipakai lagi. Akun yang dinonaktifkan (`is_active = false`) ditolak walaupun kata sandinya benar.

Branch baru dari `main` terbaru, misalnya `login-logout`:

```bash
git checkout main
git pull
git checkout -b login-logout
php artisan make:controller Auth/LoginController
php artisan make:view auth.login
```

Isi `app/Http/Controllers/Auth/LoginController.php` menjadi:

```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class LoginController extends Controller
{
    public function create(): View
    {
        return view('auth.login');
    }

    public function store(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($credentials)) {
            return back()->withErrors([
                'email' => 'Email atau kata sandi salah.',
            ])->onlyInput('email');
        }

        if (! Auth::user()->is_active) {
            Auth::logout();

            return back()->withErrors([
                'email' => 'Akun dinonaktifkan. Hubungi admin.',
            ])->onlyInput('email');
        }

        $request->session()->regenerate();

        return redirect()->intended(route('pos.create'));
    }

    public function destroy(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}
```

Isi `resources/views/auth/login.blade.php` menjadi:

```php
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login Simple POS</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen flex items-center justify-center bg-slate-100 px-4">
    <div class="w-full max-w-sm bg-white rounded-md shadow p-6">
        <h1 class="text-lg font-semibold mb-4">Masuk ke Simple POS</h1>

        <form method="POST" action="{{ route('login') }}" class="space-y-4">
            @csrf
            <div>
                <label class="block text-sm font-medium mb-1">Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required autofocus
                       class="w-full border rounded-md px-3 py-2 text-sm">
                @error('email')
                    <p class="text-sm text-red-600 mt-1">{{ $message }}</p>
                @enderror
            </div>
            <div>
                <label class="block text-sm font-medium mb-1">Kata Sandi</label>
                <input type="password" name="password" required
                       class="w-full border rounded-md px-3 py-2 text-sm">
            </div>
            <button type="submit" class="w-full bg-slate-900 text-white rounded-md py-2 text-sm">Masuk</button>
        </form>

        <p class="mt-6 text-xs text-slate-500">
            Akun demo: admin@pos.test atau kasir@pos.test, kata sandi <code>password</code>.
        </p>
    </div>
</body>
</html>
```

Tampilan login sengaja dibuat sederhana dan mandiri (tanpa komponen tambahan), supaya langkah ini bisa diulang tanpa bergantung pada berkas lain yang belum dibuat.

```bash
git add .
git commit -m "tambah login dan logout dengan Auth::attempt"
git push -u origin login-logout
```

Jangan buka Pull Request dulu: langkah 6 masih dikerjakan di branch `login-logout` yang sama.

> ✅ **Checkpoint:** jalankan `php artisan route:list`, pastikan tidak ada error, dan pastikan berkas `resources/views/auth/login.blade.php` serta `app/Http/Controllers/Auth/LoginController.php` sudah tersimpan. Login di browser baru bisa diuji setelah langkah 8, karena route `/login` dipasang di sana.

> ⚠️ **Jika gagal:** kalau `/login` menampilkan 404 sekarang, itu wajar karena route belum dipasang. Kalau setelah langkah 8 kata sandi benar tapi login tetap ditolak, cek akun demo (langkah 4) dan kolom `is_active` bernilai `true`.

### Langkah 6: Navigasi dengan tombol keluar

Navigasi harus menampilkan tombol keluar dan hanya menampilkan menu admin untuk pengguna admin. Isi `resources/views/components/nav.blade.php` menjadi:

```php
<nav class="bg-slate-900 text-white px-4 py-3 flex gap-4 items-center">
    <span class="font-semibold">Simple POS</span>
    <a href="{{ route('pos.create') }}" class="hover:underline">Kasir</a>
    <a href="{{ route('transactions.index') }}" class="hover:underline">Transaksi</a>
    @if (auth()->user()?->isAdmin())
        <a href="{{ route('products.index') }}" class="hover:underline">Produk</a>
        <a href="{{ route('categories.index') }}" class="hover:underline">Kategori</a>
    @endif
    <span class="ml-auto text-sm">{{ auth()->user()?->name }} ({{ auth()->user()?->role }})</span>
    <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button class="hover:underline">Keluar</button>
    </form>
</nav>
```

Menu admin disembunyikan di navigasi, tetapi itu hanya soal tampilan. Pembatasan yang sebenarnya dikerjakan di langkah berikutnya, di sisi server.

```bash
git add .
git commit -m "tambah tombol keluar dan menu admin di navigasi"
git push -u origin login-logout
```

> ✅ **Checkpoint:** berkas `resources/views/components/nav.blade.php` sudah tersimpan dengan tombol `Keluar` dan blok `@if (auth()->user()?->isAdmin())`. Sama seperti langkah 5, tampilannya baru bisa dicek di browser setelah langkah 8. Saat itu: login sebagai admin menampilkan menu `Produk` dan `Kategori`; login sebagai kasir menyembunyikan dua menu itu, dan tombol `Keluar` tetap ada.

Setelah langkah 6 selesai, buka Pull Request `login-logout` ke `main` (langkah 5 dan 6 digabung dalam satu PR), merge dengan **Create a merge commit**, lalu semua anggota kembali ke `main` dan pull.

### Langkah 7: Middleware `role:admin`

Middleware memeriksa setiap request sebelum sampai ke controller. Middleware `auth` sudah memastikan pengguna login; middleware `role:admin` memeriksa perannya. Kalau perannya bukan admin, respons yang dikirim adalah 403 Forbidden.

Branch baru dari `main` terbaru, misalnya `role-middleware`:

```bash
git checkout main
git pull
git checkout -b role-middleware
php artisan make:middleware EnsureUserHasRole
```

Isi `app/Http/Middleware/EnsureUserHasRole.php` menjadi:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string $role): Response
    {
        if (! $request->user() || $request->user()->role !== $role) {
            abort(403, 'Anda tidak memiliki akses untuk halaman ini.');
        }

        return $next($request);
    }
}
```

Parameter `$role` diisi dari route, misalnya `role:admin`. Middleware ini perlu didaftarkan dengan nama pendek `role` di `bootstrap/app.php`. Isi `bootstrap/app.php` menjadi:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\EnsureUserHasRole::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
```

```bash
git add .
git commit -m "tambah middleware role untuk pembatasan halaman admin"
git push -u origin role-middleware
```

> ✅ **Checkpoint:** `php artisan tinker` lalu `app(Illuminate\Contracts\Http\Kernel::class)->getMiddlewareAliases()['role']` menampilkan nama kelas `EnsureUserHasRole`, bukan error.

> ⚠️ **Jika gagal:** error `Target class [role] does not exist` berarti alias di `bootstrap/app.php` belum tersimpan atau salah ketik. Periksa bagian `$middleware->alias([...])`.

### Langkah 8: Memasang middleware pada route

Route produk dan kategori dibungkus grup `role:admin`, sedangkan halaman kasir cukup dilindungi `auth`. Isi `routes/web.php` menjadi:

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
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
    });
});
```

Perhatikan bahwa route `/products` dan `/categories` ada di dalam grup `role:admin`, dan bukan di luarnya. Ini penting, karena route yang berada di luar grup tidak akan dilindungi siapa pun.

```bash
git add .
git commit -m "lindungi route produk dan kategori dengan role admin"
git push -u origin role-middleware
```

Buka Pull Request ke `main`, merge, lalu semua anggota kembali ke `main` dan pull.

> ✅ **Checkpoint:** `php artisan route:list` menampilkan middleware `auth` pada `/pos` dan `role:admin` pada `products` dan `categories`.

### Langkah 9: Membuktikan pembatasan dengan dua akun

Uji langkah ini dengan kedua akun, bukan hanya admin. Kesalahan paling umum justru tidak terlihat kalau yang diuji selalu admin.

1. Jalankan `php artisan migrate:fresh --seed`, lalu `php artisan serve` (dan `npm run dev` di terminal kedua kalau belum berjalan, karena halaman login memuat aset lewat `@vite`).
2. Login sebagai `admin@pos.test`, buka `/products`. **Yang diharapkan:** halaman daftar produk tampil normal.
3. Logout, login sebagai `kasir@pos.test`, buka `/products` lagi. **Yang diharapkan:** halaman error 403 dengan pesan "Anda tidak memiliki akses untuk halaman ini.", bukan daftar produk.
4. Masih login sebagai kasir, buka `/pos`. **Yang diharapkan:** halaman kasir tampil normal, karena kasir memang boleh.
5. Klik `Keluar`, lalu coba login dengan kata sandi yang salah. **Yang diharapkan:** pesan "Email atau kata sandi salah." (login harus dicoba setelah keluar, karena mencoba login sementara masih login akan langsung dialihkan ke `/pos`, bukan menampilkan form).
6. Masih tanpa login, buka `/products` langsung dari address bar. **Yang diharapkan:** kamu diarahkan ke halaman `/login`, bukan halaman error. Untuk halaman biasa di browser, Laravel menjawab kondisi "belum login" dengan mengarahkan ke halaman login, karena itu jawaban yang paling berguna untuk manusia.
7. Masih tanpa login, dengan server tetap berjalan, jalankan perintah ini di terminal lain (di Windows, jalankan lewat Git Bash):
   ```bash
   curl -i http://127.0.0.1:8000/pos -H "Accept: application/json"
   ```
   **Yang diharapkan:** baris pertama menunjukkan status `401 Unauthorized`, dengan isi `{"message":"Unauthenticated."}`. Request ini meminta jawaban JSON, bukan halaman HTML, jadi Laravel menjawab dengan kode status 401 apa adanya. Bandingkan dengan langkah 3 tadi: `401` berarti belum login, `403` berarti sudah login tetapi tidak punya izin.

> ✅ **Checkpoint:** ketujuh hasil di atas sesuai, dan setiap anggota sudah mencoba minimal satu dari langkah 3, 4, atau 7 di laptopnya sendiri.

> ⚠️ **Jika kasir tetap bisa membuka `/products`:** periksa dua kemungkinan. (a) Route `/products` ternyata berada di luar grup `role:admin` pada langkah 8. (b) Route sempat di-cache sebelum middleware ditambahkan. Jalankan `php artisan route:clear`, lalu coba lagi.

### Langkah 10: Menonaktifkan akun

Akun yang dinonaktifkan tidak boleh login, walaupun kata sandinya benar. Ini berbeda dengan peran: akun tetap ada, hanya aksesnya dicabut.

Lewat `php artisan tinker`, jalankan:

```php
App\Models\User::where('email', 'kasir@pos.test')->update(['is_active' => false]);
```

Coba login sebagai `kasir@pos.test`. **Yang diharapkan:** pesan "Akun dinonaktifkan. Hubungi admin.". Lalu aktifkan kembali dengan `update(['is_active' => true])`.

> ✅ **Checkpoint:** login kasir ditolak saat `is_active` bernilai `false`, dan berhasil lagi setelah dikembalikan ke `true`.

### Langkah 11: Tantangan mandiri kelompok dan commit `increment 7`

Bagi tugas berikut di antara anggota, supaya setiap anggota tercatat minimal satu commit bermakna lewat Pull Request masing-masing:

- Ubah pesan 403 di `EnsureUserHasRole` agar menyebutkan peran yang dibutuhkan, misalnya "Halaman ini hanya untuk peran admin.", bukan pesan umum seperti sebelumnya.
- Tambahkan peran ketiga, `manager`, yang boleh membuka `/transactions` tetapi tidak boleh membuka `/products`. Tentukan sendiri bagaimana route perlu dikelompokkan supaya aturan ini benar.
- Tambahkan halaman yang hanya bisa dibuka tamu (belum login), misalnya halaman informasi, dan pastikan pengguna yang sudah login diarahkan ke `/pos`.
- Tulis satu skenario uji manual di README proyek untuk setiap peran: langkah dan hasil yang diharapkan.

Setiap tugas: buat branch baru (misalnya `custom-forbidden-message`), kerjakan, commit, push, lalu buka dan merge Pull Request-nya (ikuti alur di atas).

Setelah semua Pull Request masuk dan digabungkan, salah satu anggota menutup pekerjaan kelompok:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 7: autentikasi dan otorisasi rbac"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** baris teratas `git log --pretty="%h %an %s"` menunjukkan `increment 7: ...`, dan baris-baris di bawahnya menunjukkan nama setiap anggota kelompok.

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta dosen:

- Link repositori GitHub kelompok.
- Screenshot halaman 403 saat kasir membuka `/products`.
- Screenshot halaman `/products` yang tampil normal saat admin membuka.
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel pembagian tugas: nama anggota | langkah/tugas yang dikerjakan | hash commit.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---:|---|---|
| Langkah kerja tuntas (kelompok) | 40% | Langkah 1-11 selesai, login, logout, dan pembatasan peran berfungsi sesuai hasil uji dua akun | Sebagian besar langkah selesai, login dan pembatasan admin berjalan |
| Checkpoint terverifikasi (kelompok) | 25% | Screenshot 403 dan halaman admin, tabel pembagian tugas, dan git log lengkap dan benar | Sebagian checkpoint terbukti |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna atas nama tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Kerapian repositori dan commit | 10% | Pesan `increment 7` persis, migrasi baru (bukan edit migrasi lama), tanpa menyertakan `vendor/`, `node_modules/`, `.env`, PR di-merge rapi (bukan squash) | Commit ada, pesan kurang rapi atau PR di-squash |
