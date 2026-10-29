#import "/template.typ": *

= Merancang dan Membangun REST API <ch:membangun-rest-api>

#chapterhero("purple", [Rancang endpoint REST Simple POS yang konsisten, lindungi lewat token Sanctum, lalu dokumentasikan kontraknya lewat OpenAPI agar tim lain tak perlu membaca kode controller.], [#icon("plug")#h(1em)endpoint REST], [#icon("key")#h(1em)Sanctum], [#icon("code")#h(1em)OpenAPI])

Loket layanan publik yang tertib punya formulir baku untuk setiap
keperluan: formulir pengajuan warna biru, formulir pengaduan warna
kuning, masing-masing dengan kolom yang sudah ditentukan dan urutan
langkah yang sama setiap kali. Warga tidak perlu bertanya ke petugas
"formulir apa yang harus saya isi untuk keperluan ini", karena jenis
formulirnya sudah bisa ditebak dari jenis keperluannya. REST API bekerja
dengan prinsip yang sama: method HTTP dan struktur URL sudah memberi
tahu apa yang akan terjadi sebelum satu baris dokumentasi pun dibaca.
`GET /api/products` sudah menyiratkan "ambil daftar produk, tidak
mengubah apa pun", dan `POST /api/transactions` sudah menyiratkan
"buat transaksi baru". Klien mobile kasir Simple POS bergantung penuh
pada konsistensi semacam ini, karena berbeda dengan halaman Blade, tidak
ada manusia yang membaca tampilan API secara langsung untuk menebak apa
yang harus dilakukan selanjutnya.

#strong[Yang Akan Kamu Pelajari]

+ merancang endpoint REST API Simple POS (`POST /api/login`, `GET /api/products`, `POST /api/transactions`) mengikuti semantik HTTP method secara konsisten;
+ mengimplementasikan autentikasi berbasis token dengan Laravel Sanctum untuk klien kasir mobile, termasuk header `Authorization: Bearer`, dan menulis klien yang benar-benar mengonsumsi endpoint terproteksi itu dari luar aplikasi;
+ mendokumentasikan API Simple POS memakai spesifikasi OpenAPI agar kontrak endpoint dapat dipakai tim frontend atau mobile lain tanpa membaca kode controller.

== Merancang Endpoint REST API Simple POS <sec:membangun-rest-api-1>

#istilahpenting[
/ REST: #emph[Representational State Transfer], gaya arsitektur API yang memetakan operasi ke resource lewat method HTTP standar (GET, POST, PUT, DELETE) dan URL yang merepresentasikan resource itu sendiri.
/ Endpoint: Satu kombinasi method HTTP dan path URL yang menjalankan satu operasi spesifik, misalnya `POST /api/login`.
/ Token: String acak yang mewakili identitas pengguna setelah login berhasil, dikirim ulang pada setiap request berikutnya sebagai bukti bahwa pengguna itu sudah terautentikasi.
/ Sanctum: Paket autentikasi bawaan Laravel untuk API berbasis token, dirancang untuk klien SPA maupun klien mobile murni.
/ API Resource: Kelas transformasi Laravel yang mengubah model Eloquent menjadi struktur JSON yang konsisten, memisahkan bentuk respons API dari struktur kolom tabel apa adanya.
]

Semantik method HTTP bukan sekadar konvensi kosmetik: `GET`
seharusnya aman (tidak mengubah state apa pun di server) dan idempoten
(dipanggil berkali-kali menghasilkan efek yang sama seperti dipanggil
sekali), sementara `POST` boleh mengubah state, seperti membuat
baris baru. Klien mobile kasir bisa mengandalkan aturan ini: memanggil
ulang `GET /api/products` berkali-kali karena koneksi terputus
tidak akan pernah menggandakan data, sedangkan `POST
/api/transactions` yang terpanggil dua kali karena request pertama
timeout memang berpotensi membuat dua transaksi, dan klien harus
menangani kasus itu secara eksplisit (misalnya lewat idempotency key),
bukan mengasumsikan POST aman diulang.

#listing(file: "app/Http/Resources/ProductResource.php", ```php
class ProductResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'price' => $this->price,
            'category' => $this->category->name,
        ];
    }
}
```)

`JsonResource` memastikan setiap endpoint mengembalikan bentuk
JSON yang konsisten dan sudah dikurasi, bukan hasil `toJson()`
mentah dari model Eloquent yang bisa saja ikut membocorkan kolom
internal seperti `updated_at` atau relasi yang tidak relevan
bagi klien.

== Autentikasi Token dengan Sanctum <sec:membangun-rest-api-2>

Halaman web Simple POS memakai sesi berbasis cookie (Bab~7), cocok
untuk browser yang menyimpan cookie otomatis. Klien mobile kasir tidak
punya cookie jar seperti itu, sehingga butuh mekanisme autentikasi yang
berbeda: token yang disimpan sendiri oleh aplikasi mobile dan dikirim
ulang secara eksplisit pada setiap request. Siapkan dulu Sanctum dan
kerangka API-nya:

+ Pasang Sanctum, kalau proyek Simple POS belum pernah
      memasangnya:

  #listing(```bash
  php artisan install:api
    
  ```)

  Perintah ini membuat `routes/api.php` (kalau belum ada) dan
      mendaftarkan middleware `auth:sanctum`.
+ Buat controller autentikasi API-nya:

  #listing(```bash
  php artisan make:controller Api/AuthController
    
  ```)
+ Buka `routes/api.php`, daftarkan route login di luar
      middleware `auth:sanctum` (klien belum punya token saat
      login):

  #listing(file: "routes/api.php", ```php
  Route::post('/login', [App\Http\Controllers\Api\AuthController::class, 'login']);
    
  ```)

#listing(file: "app/Http/Controllers/Api/AuthController.php", ```php
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
```)

`createToken('mobile-kasir')` menghasilkan token baru yang
tersimpan (dalam bentuk hash) di tabel `personal_access_tokens`,
dan `->plainTextToken` adalah satu-satunya kesempatan token
mentah itu terlihat; setelah respons ini, aplikasi tidak bisa lagi
meminta ulang token yang sama dalam bentuk terbaca. Setiap request
terproteksi berikutnya wajib menyertakan token itu di header:

Buka `app/Http/Controllers/Api/AuthController.php` yang dibuat
pada langkah 2 di atas, isi metode `login()` dengan kode yang baru
ditunjukkan, lalu jalankan `php artisan serve` dan uji lewat
`curl`:

#listing(```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -d "email=kasir@pos.test&password=password"
```)

#strong[Yang diharapkan]: respons JSON berisi
`{"token":"1|xxxxxxxxxxxxxxxxxxxx"}`. Salin nilai token itu
(termasuk angka dan tanda `|` di depannya), lalu pakai pada
request berikutnya:

#listing(```bash
curl http://127.0.0.1:8000/api/products \
  -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx"
```)

#strong[Yang diharapkan]: respons JSON berisi daftar produk. Coba juga
tanpa header `Authorization` sama sekali; #strong[yang
diharapkan] kali ini: respons `401 Unauthorized` dengan pesan
`{"message":"Unauthenticated."}`, bukti bahwa middleware
`auth:sanctum` benar-benar aktif.

Route yang perlu dilindungi cukup dibungkus middleware
`auth:sanctum`, mirip pola `role:admin` pada Bab~7,
hanya saja di sini yang diperiksa adalah keberadaan dan keabsahan token
lewat header `Authorization`, bukan sesi cookie.

#listing(file: "routes/api.php", ```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
});
```)

== Mengonsumsi API: Klien Sederhana untuk Kasir Mobile <sec:membangun-rest-api-3>

Bagian sebelumnya membangun API dari sisi server. Klien mobile kasir
yang sebenarnya memanggilnya tidak menulis satu baris Laravel pun; ia
hanya melempar request HTTP dan membaca respons JSON, entah itu
aplikasi Flutter, React Native, atau, seperti pada langkah-langkah
berikut, skrip PHP biasa yang memakai facade `Http` milik
Laravel. Polanya sama saja dipakai dari bahasa atau kerangka kerja
lain; yang berubah cuma cara memanggil HTTP-nya.

+ Mulai dari login untuk mendapatkan token, dari kode yang
      berdiri terpisah dari server (bisa berupa command Artisan, skrip
      mandiri, atau proyek lain sepenuhnya):

  #listing(file: "app/Console/Commands/ApiClientDemo.php", ```php
  $login = Http::post("{$baseUrl}/api/login", [
      'email' => 'kasir@pos.test',
      'password' => 'password',
  ]);

  if ($login->failed()) {
      // tangani galat di sini, jangan lanjut ke langkah berikutnya
  }

  $token = $login->json('token');
    
  ```)

  `$login->failed()` memeriksa kode status HTTP sebelum
      kode lanjut membaca `$login->json('token')`; tanpa
      pemeriksaan ini, kredensial yang salah (401) akan membuat
      `$token` bernilai `null` tanpa pernah jelas
      kenapa, dan galat itu baru muncul beberapa langkah kemudian di
      tempat yang membingungkan.
+ Pakai token itu pada request berikutnya lewat
      `Http::withToken()`, yang menambahkan header
      `Authorization: Bearer <token>` secara otomatis:

  #listing(file: "app/Console/Commands/ApiClientDemo.php", ```php
  $products = Http::withToken($token)->get("{$baseUrl}/api/products");

  if ($products->failed()) {
      // token kedaluwarsa/dicabut, atau server sedang bermasalah
  }
    
  ```)
+ Kirim transaksi, dan bedakan dua jenis galat yang butuh
      penanganan berbeda: 401 (token tidak valid) berarti klien perlu
      login ulang, sementara 422 (validasi gagal, mis. stok tidak cukup)
      berarti permintaannya sendiri yang salah dan login ulang tidak akan
      membantu:

  #listing(file: "app/Console/Commands/ApiClientDemo.php", ```php
  $transaction = Http::withToken($token)->post("{$baseUrl}/api/transactions", [
      'items' => [['product_id' => $productId, 'qty' => 1]],
  ]);

  match ($transaction->status()) {
      201 => /* transaksi tersimpan, baca $transaction->json('data') */,
      401 => /* token tidak valid, login ulang */,
      422 => /* input ditolak, tampilkan $transaction->json('message') */,
      default => /* galat lain, tampilkan ke pengguna */,
  };
    
  ```)
+ Jalankan `php artisan serve`, lalu coba jalankan
      kode di atas terhadap Simple POS yang sedang berjalan.
      #strong[Yang diharapkan]: token diterima, daftar produk terbaca,
      dan transaksi tersimpan dengan status 201, persis seperti kalau
      dipanggil lewat `curl` pada bagian sebelumnya, hanya kali ini
      dari kode PHP yang bisa diperluas jadi aplikasi klien sungguhan.
+ #strong[Kalau langkah kedua atau ketiga selalu gagal dengan
      401] meski login di langkah pertama sukses, periksa apakah token
      benar-benar diteruskan ke `withToken()` (bukan variabel
      kosong karena langkah pertama sebenarnya gagal tapi tidak
      diperiksa), atau apakah token itu sudah dicabut lewat
      `POST /api/logout` di percobaan sebelumnya.

#warningbox[
Klien yang mengasumsikan setiap request selalu berhasil, langsung
membaca `$response->json('token')` tanpa memeriksa
`failed()` lebih dulu, gagal secara diam-diam: bukan error
yang jelas, tapi nilai `null` yang menjalar ke request
berikutnya dan baru meledak beberapa langkah kemudian dengan pesan
yang membingungkan.
]

Kode lengkap pola ini sudah tersedia sebagai perintah Artisan yang
bisa langsung dijalankan, `php artisan api:demo`, mendemonstrasikan
ketiga langkah di atas secara berurutan terhadap Simple POS yang
sedang berjalan; lihat `app/Console/Commands/ApiClientDemo.php`
pada kode lengkap bab ini.

== Praktik: Mendokumentasikan API dengan OpenAPI <sec:membangun-rest-api-4>

Dokumentasi API yang hanya berupa catatan teks di README cepat basi:
begitu satu field respons berubah nama, tidak ada yang memaksa siapa
pun memperbarui catatan itu. OpenAPI mendeskripsikan endpoint dalam
format terstruktur (YAML atau JSON) yang bisa dibaca alat lain, mulai
dari generator dokumentasi interaktif sampai generator kode klien.

+ Buat berkas `docs/openapi.yaml` di root proyek Simple
      POS (belum ada bawaan Laravel; ini berkas baru yang berdiri sendiri,
      tidak dibaca otomatis oleh aplikasi).
+ Isi bagian `paths` untuk endpoint login:

  #listing(```
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
    
  ```)

  Struktur `paths` memetakan path URL ke method HTTP, dan
      setiap method mendeskripsikan bentuk `requestBody` yang
      diterima beserta `responses` yang mungkin dikembalikan,
      lengkap dengan kode status HTTP-nya.
+ Tambahkan entri serupa untuk `GET /api/products` dan
      `POST /api/transactions` di bawah `paths` yang sama,
      mengikuti pola yang sama seperti endpoint login.
+ Buka berkas itu di editor Swagger daring
      (`editor.swagger.io`), tempel isi `docs/openapi.yaml`
      ke sana. #strong[Yang diharapkan]: panel pratinjau di sisi kanan
      menampilkan ketiga endpoint sebagai daftar interaktif yang bisa
      diklik, tanpa galat sintaks YAML.
+ #strong[Kalau panel pratinjau menampilkan pesan galat], itu
      hampir selalu indentasi YAML yang salah (YAML memakai spasi,
      bukan tab, dan tiap level indentasi harus konsisten); bandingkan
      ulang lekukan tiap baris dengan contoh di langkah 2.

Tabel berikut merangkum ketiga endpoint yang sudah dibangun sekaligus
dikonsumsi pada bagian sebelumnya, kombinasi method dan path yang perlu
diingat baik saat menulis controller di server maupun saat memanggilnya
dari klien.

#figure(
  table(
    columns: (0.5fr, 1.1fr, 1fr),
    align: (left, left, center),
    table.hline(stroke: 0.8pt),
    [Method], [Path], [Autentikasi],
    table.hline(stroke: 0.5pt),
    [POST], [`/api/login`], [Tidak perlu token],
    [GET], [`/api/products`], [`auth:sanctum`],
    [POST], [`/api/transactions`], [`auth:sanctum`],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Ringkasan endpoint API Simple POS],
) <tab:endpoint-summary>

#tipbox[
Perlakukan spesifikasi OpenAPI sebagai kontrak yang bisa diuji, bukan
sekadar catatan pasif: alat seperti validator skema bisa memeriksa
apakah respons controller yang sebenarnya benar-benar cocok dengan
skema yang didokumentasikan, sehingga dokumentasi yang basi akan
ketahuan lewat test yang gagal, bukan lewat keluhan tim frontend
belakangan.
]

#branchref("chapter-09")

== Rangkuman <sec:membangun-rest-api-rangkuman>

- Endpoint REST Simple POS mengikuti semantik HTTP method secara
      konsisten (`GET` aman dan idempoten, `POST` mengubah
      state), dengan respons dikurasi lewat `JsonResource` agar
      tidak membocorkan struktur tabel apa adanya.
- Sanctum menerbitkan token lewat `POST /api/login`, dan
      setiap request terproteksi menyertakan token itu lewat header
      `Authorization: Bearer`, diperiksa middleware
      `auth:sanctum` pada route API. Klien yang mengonsumsi API ini
      wajib memeriksa status respons (`failed()`) sebelum
      membaca isinya, dan membedakan penanganan galat 401 (login ulang)
      dari 422 (perbaiki input), bukan mengasumsikan setiap panggilan
      selalu berhasil.
- Spesifikasi OpenAPI mendokumentasikan `paths`,
      `requestBody`, dan `responses` tiap endpoint dalam
      format terstruktur, memungkinkan tim frontend atau mobile lain
      memakai kontrak API tanpa membaca kode controller, dan bisa diuji
      otomatis alih-alih sekadar catatan pasif.

== Latihan

+ Uji ketiga endpoint (`login`, `products`,
      `transactions`) lewat `curl`, termasuk mencoba mengakses
      `/api/products` tanpa header `Authorization` sama
      sekali dan mengamati respons galatnya.
+ Tambahkan endpoint baru `GET /api/categories`, lengkap
      dengan `JsonResource`-nya.
+ Lengkapi dokumentasi OpenAPI untuk endpoint
      `GET /api/products`, termasuk skema query parameter untuk
      paginasi.
+ Ubah `php artisan api:demo` agar mencoba login dengan
      kata sandi yang salah lebih dulu, lalu amati bagaimana kode itu
      berhenti pada langkah pertama alih-alih melanjutkan dengan token
      kosong.
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) mengapa `GET` harus tetap
      aman dan idempoten, (b) apa yang sebenarnya dikembalikan
      `createToken()`, (c) mengapa dokumentasi OpenAPI lebih
      dapat diandalkan dibanding catatan README biasa, dan (d) kenapa
      klien API wajib memeriksa `failed()` sebelum membaca isi
      respons. Cocokkan jawabanmu dengan isi bab ini.

#challengebox[
Tambahkan endpoint `GET /api/transactions/{id}` yang
mengembalikan satu transaksi beserta detail dan produknya, lengkap
dengan dokumentasi OpenAPI-nya.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel Sanctum
#cite(<sanctumdocs>) untuk autentikasi berbasis token, spesifikasi
OpenAPI #cite(<openapispec>) untuk format dokumentasi API, dan makalah
Fielding #cite(<fielding2000rest>) untuk prinsip arsitektur REST.
