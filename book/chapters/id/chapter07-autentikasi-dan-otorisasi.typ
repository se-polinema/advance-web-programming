#import "/template.typ": *

= Autentikasi, Otorisasi, dan RBAC <ch:autentikasi-dan-otorisasi>

#chapterhero("purple", [Bedakan siapa yang boleh masuk dari apa yang boleh dilakukan, lalu bangun middleware peran kustom yang menutup halaman admin dari kasir biasa.], [#icon("lock")#h(1em)login & sesi], [#icon("user-shield")#h(1em)middleware peran], [#icon("users-cog")#h(1em)RBAC])

Gedung perkantoran berlapis biasanya punya dua pintu yang berbeda
sifatnya. Kartu akses di pintu lobi hanya memeriksa satu hal: apakah
kartu ini terdaftar sebagai karyawan gedung, ya atau tidak. Begitu lolos
lobi, orang yang sama masih akan berhenti di pintu ruang server, dan di
situ pertanyaannya berbeda: bukan lagi "apakah kamu karyawan", tapi
"apakah perananmu memang berwenang masuk ruang ini". Resepsionis yang
kartunya sah tetap tertahan di depan ruang server kalau perananya bukan
staf IT. Simple POS memisahkan dua pertanyaan itu dengan cara yang
sama. Autentikasi menjawab pertanyaan lobi: siapa kamu, dibuktikan lewat
email dan kata sandi. Otorisasi menjawab pertanyaan ruang server: dengan
identitas itu, halaman mana saja yang benar-benar boleh diakses.

#strong[Yang Akan Kamu Pelajari]

+ mengimplementasikan login dan logout Simple POS memakai sistem autentikasi bawaan Laravel, termasuk akun demo admin dan kasir;
+ menulis middleware `role:admin` kustom untuk membatasi akses halaman produk, kategori, dan laporan hanya untuk peran admin;
+ membandingkan pendekatan RBAC manual (middleware kustom) pada Simple POS dengan paket seperti Laravel Breeze dan Spatie Permission, serta kapan masing-masing lebih sesuai dipakai.

== Autentikasi: Login dan Sesi Pengguna <sec:autentikasi-dan-otorisasi-1>

#istilahpenting[
/ Autentikasi: Proses membuktikan identitas pengguna, biasanya lewat kombinasi email dan kata sandi, menjawab pertanyaan "kamu siapa".
/ Otorisasi: Proses menentukan apa yang boleh dilakukan pengguna yang identitasnya sudah terbukti, menjawab pertanyaan "kamu boleh apa".
/ Middleware: Lapisan kode yang memeriksa atau memodifikasi request sebelum sampai ke controller, dipasang pada route atau grup route tertentu.
/ RBAC: #emph[Role-Based Access Control], pendekatan otorisasi yang mengaitkan izin akses ke peran pengguna (admin, kasir), bukan ke pengguna satu per satu.
/ Sesi: Data pengguna yang login disimpan server antar-request, biasanya diidentifikasi lewat cookie di browser, sehingga pengguna tidak perlu login ulang di setiap halaman.
]

Laravel menyediakan sistem autentikasi bawaan lewat facade
`Auth`, dan Simple POS memakainya langsung tanpa paket
tambahan. `LoginController` menerima email dan kata sandi dari
form, lalu menyerahkan pemeriksaannya ke
`Auth::attempt(['email' => ..., 'password' => ...])`.

#listing(file: "app/Http/Controllers/Auth/LoginController.php", ```php
public function store(Request $request)
{
    $credentials = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    if (Auth::attempt($credentials)) {
        $request->session()->regenerate();
        return redirect()->intended('/dashboard');
    }

    return back()->withErrors(['email' => 'Kredensial tidak cocok.']);
}
```)

`Auth::attempt()` mencocokkan email dengan baris pada tabel
`users`, lalu memverifikasi kata sandi lewat hash yang tersimpan;
kata sandi asli tidak pernah disimpan dalam bentuk yang bisa dibaca
langsung. Kalau cocok, Laravel menyimpan identitas pengguna itu di sesi,
dan `$request->session()->regenerate()` membuat ID sesi baru
setelah login berhasil, mencegah serangan
#emph[session fixation] di mana penyerang menyisipkan ID sesi lamanya
sendiri sebelum korban login. Simple POS menyediakan dua akun demo,
`admin@pos.test` berperan admin dan `kasir@pos.test`
berperan kasir, keduanya masuk lewat form login yang sama; yang berbeda
hanya nilai kolom `role` pada baris `users` masing-masing.

== RBAC dengan Middleware Kustom <sec:autentikasi-dan-otorisasi-2>

Login yang berhasil hanya membuktikan identitas; ia belum menentukan
halaman mana yang boleh diakses identitas itu. Middleware
`auth` bawaan Laravel sudah cukup untuk memblokir pengguna
yang belum login sama sekali, tapi Simple POS butuh satu lapis lagi:
membedakan kasir dari admin setelah keduanya sama-sama berhasil login.

#listing(file: "app/Http/Middleware/EnsureUserHasRole.php", ```php
class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string $role)
    {
        if ($request->user()?->role !== $role) {
            abort(403, 'Akses ditolak untuk peran Anda.');
        }

        return $next($request);
    }
}
```)

Parameter ketiga, `$role`, bukan bagian tetap dari signature
middleware Laravel; ia parameter kustom yang dipasok saat middleware
didaftarkan pada route, dituliskan sebagai `role:admin` pada
grup route. Middleware ini didaftarkan sebagai alias di
`bootstrap/app.php` agar bisa dipanggil lewat nama pendek
`role` alih-alih nama kelas penuh.

#listing(file: "routes/web.php", ```php
Route::middleware(['auth', 'role:admin'])->group(function () {
    Route::resource('products', ProductController::class);
    Route::resource('categories', CategoryController::class);
    Route::get('/reports', [ReportController::class, 'index']);
});
```)

Dua middleware itu berjalan berurutan: `auth` lebih dulu
memastikan pengguna sudah login sama sekali, baru `role:admin`
memeriksa peran spesifiknya. Kasir yang mencoba membuka
`/products` akan lolos middleware `auth` (ia memang
sudah login) tapi tertahan di `role:admin`, menerima respons
403 Forbidden.

== Praktik: Membatasi Akses Halaman Admin <sec:autentikasi-dan-otorisasi-3>

Langkah-langkah berikut membuat middleware `EnsureUserHasRole`
dari nol, mendaftarkannya, lalu membuktikan pembatasannya benar-benar
berjalan lewat dua akun demo yang berbeda peran.

+ Buat kerangka kelas middleware-nya:

  #listing(```bash
  php artisan make:middleware EnsureUserHasRole
    
  ```)
+ Buka berkas yang baru dibuat di
      `app/Http/Middleware/EnsureUserHasRole.php`, lalu ganti isi
      metode `handle()`-nya dengan kode yang sudah ditunjukkan di
      bagian sebelumnya (parameter `$role`, pemeriksaan
      `$request->user()?->role`, dan `abort(403, ...)`).
+ Buka `bootstrap/app.php`, daftarkan middleware itu sebagai
      alias `role` di dalam pemanggilan `->withMiddleware()`:

  #listing(file: "bootstrap/app.php", ```php
  ->withMiddleware(function (Middleware $middleware) {
      $middleware->alias([
          'role' => \App\Http\Middleware\EnsureUserHasRole::class,
      ]);
  })
    
  ```)

  Tanpa pendaftaran alias ini, menulis `role:admin` pada route
      akan gagal dengan pesan `Target class [role] does not exist`.
+ Buka `routes/web.php`, bungkus route produk, kategori, dan
      laporan dengan grup `['auth', 'role:admin']` seperti pada
      contoh di bagian sebelumnya.
+ Pastikan dua akun demo sudah ada di seeder. Buka
      `database/seeders/DatabaseSeeder.php`, tambahkan (kalau belum
      ada):

  #listing(file: "database/seeders/DatabaseSeeder.php", ```php
  User::factory()->create([
      'email' => 'admin@pos.test',
      'role' => 'admin',
  ]);
  User::factory()->create([
      'email' => 'kasir@pos.test',
      'role' => 'kasir',
  ]);
    
  ```)

  lalu jalankan `php artisan migrate:fresh --seed` agar kedua
      akun tersedia di basis data.
+ Jalankan `php artisan serve`, login sebagai
      `admin@pos.test`, buka `/products`. #strong[Yang
      diharapkan]: halaman daftar produk tampil normal.
+ Logout, login sebagai `kasir@pos.test`, buka
      `/products` lagi. #strong[Yang diharapkan]: yang muncul adalah
      halaman error 403, bukan daftar produk.
+ #strong[Kalau kasir tetap bisa membuka `/products`],
      periksa dua kemungkinan paling umum: (a) route `/products`
      ternyata terdaftar di luar grup `role:admin` pada langkah 4;
      (b) route sempat di-cache sebelum middleware ditambahkan
      (`php artisan route:cache` pernah dijalankan), sehingga
      Laravel masih memakai daftar route lama; jalankan
      `php artisan route:clear` lalu coba lagi.

#figure(
  table(
    columns: (1.1fr, 0.9fr, 1.6fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Pendekatan], [Kompleksitas setup], [Cocok untuk],
    table.hline(stroke: 0.5pt),
    [Middleware kustom (Simple POS)], [Rendah], [Peran sederhana, 2--3 peran tetap],
    [Laravel Breeze], [Sedang], [Autentikasi siap pakai plus scaffolding UI],
    [Spatie Permission], [Sedang--tinggi], [Peran dan izin granular, banyak kombinasi],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Middleware kustom vs paket otorisasi siap pakai],
) <tab:rbac-perbandingan>

Middleware kustom seperti `EnsureUserHasRole` cukup untuk
Simple POS karena jumlah perannya tetap kecil dan tidak berubah-ubah.
Begitu kebutuhan tumbuh menjadi izin granular per aksi, misalnya "admin
cabang A boleh mengelola produk cabang A saja, tidak cabang B", paket
seperti Spatie Permission menyediakan model izin dan peran yang jauh
lebih fleksibel daripada satu kolom `role` string, dengan
konsekuensi setup dan tabel tambahan yang lebih rumit.

#warningbox[
Middleware hanya melindungi route yang benar-benar dipasangi middleware
itu. Menambahkan route baru ke dalam grup `Route::resource()`
yang sudah dilindungi `role:admin` tetap aman, tapi menambahkan
route admin baru #emph[di luar] grup itu, atau lupa memasukkannya ke
grup yang benar, membuat halaman itu bisa diakses siapa pun yang sudah
login, tanpa peduli perannya. Kesalahan ini tidak akan terlihat di
lingkungan pengembangan kalau yang menguji selalu login sebagai admin.
]

#branchref("chapter-07")

== Rangkuman <sec:autentikasi-dan-otorisasi-rangkuman>

- Login dan logout Simple POS memakai `Auth::attempt()`
      bawaan Laravel, dengan `session()->regenerate()` mencegah
      session fixation, dan dua akun demo (`admin@pos.test`,
      `kasir@pos.test`) yang dibedakan lewat kolom `role`.
- Middleware `EnsureUserHasRole`, didaftarkan sebagai
      alias `role` dan dipasang lewat `role:admin` pada
      grup route, membatasi akses halaman produk, kategori, dan laporan
      hanya untuk pengguna berperan admin, mengembalikan 403 untuk peran
      lain.
- Middleware kustom cocok untuk RBAC sederhana dengan sedikit
      peran tetap seperti Simple POS; paket seperti Laravel Breeze lebih
      cocok untuk scaffolding autentikasi siap pakai, dan Spatie
      Permission lebih cocok untuk izin granular per aksi dengan banyak
      kombinasi peran.

== Latihan

+ Login sebagai kasir, coba akses `/reports` langsung lewat
      URL, dan catat respons apa yang diterima dibanding saat login
      sebagai admin.
+ Tambahkan peran baru, misalnya `manager`, yang boleh
      melihat `/reports` tapi tidak boleh mengelola
      `/products`. Rancang bagaimana middleware perlu berubah untuk
      mendukung ini.
+ Jelaskan dengan kata-katamu sendiri perbedaan autentikasi dan
      otorisasi, memakai contoh konkret dari Simple POS selain yang sudah
      dibahas di bab ini.
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) apa yang dilakukan
      `Auth::attempt()`, (b) mengapa middleware `auth`
      dan `role:admin` perlu dipasang berurutan, dan (c) kapan
      Spatie Permission lebih masuk akal dipakai daripada middleware
      kustom. Cocokkan jawabanmu dengan isi bab ini.

#challengebox[
Tambahkan pesan error khusus saat kasir mencoba mengakses halaman
admin, menyebutkan nama halaman yang ditolak dan peran yang dibutuhkan,
alih-alih pesan 403 generik bawaan Laravel.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel #cite(<laraveldocs>) untuk
autentikasi, sesi, dan middleware.
