---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    padding: 56px 72px;
    justify-content: center;
  }
  section.lead {
    background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 55%, #2563eb 100%);
    color: #fff;
    justify-content: center;
  }
  section.lead h1, section.lead h2, section.lead p {
    color: #fff;
  }
  section.divider {
    background: #1d4ed8;
    color: #fff;
  }
  section.divider h1 {
    color: #fff;
    font-size: 2.2em;
  }
  section.divider h2 {
    color: #fff;
  }
  section.divider p {
    color: #bfdbfe;
  }
  h1 {
    color: #1d4ed8;
    font-size: 1.6em;
  }
  h2 {
    color: #1d4ed8;
  }
  table {
    font-size: 0.72em;
    width: 100%;
  }
  table.small {
    font-size: 0.75em;
  }
  th, td {
    padding: 4px 10px;
  }
  th {
    background: #1d4ed8;
    color: #fff;
  }
  code {
    background: #f1f5f9;
    color: #0f172a;
  }
  pre {
    font-size: 0.68em;
  }
  .term-box {
    border-left: 6px solid #1d4ed8;
    background: #eff6ff;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.82em;
  }
  .term-box b {
    color: #1d4ed8;
  }
  .tip-box {
    border-left: 6px solid #16a34a;
    background: #f0fdf4;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .warn-box {
    border-left: 6px solid #dc2626;
    background: #fef2f2;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .cols {
    display: flex;
    gap: 24px;
  }
  .cols > div {
    flex: 1;
  }
  .flow {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-top: 30px;
    flex-wrap: wrap;
  }
  .flow .box {
    background: #1d4ed8;
    color: #fff;
    padding: 12px 18px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 0.85em;
  }
  .flow .arrow {
    font-size: 1.4em;
    color: #1d4ed8;
  }
  .stack .box {
    background: #1d4ed8;
    color: #fff;
    padding: 10px;
    border-radius: 6px;
    text-align: center;
    margin: 4px 0;
    font-weight: bold;
  }
  .footnote {
    font-size: 0.55em;
    color: #64748b;
    position: absolute;
    bottom: 20px;
  }
  .ref-link {
    display: inline-block;
    font-size: 0.62em;
    color: #1d4ed8;
    background: #eff6ff;
    border-left: 4px solid #93c5fd;
    border-radius: 0 6px 6px 0;
    padding: 6px 14px;
    margin-top: 14px;
  }
  .ref-link code {
    background: transparent;
    color: #1d4ed8;
  }
---

<!-- _class: lead -->

# Pemrograman Web Lanjut
## SIB245007 &nbsp;|&nbsp; D-IV Sistem Informasi Bisnis

Pertemuan 10: **Merancang dan Membangun REST API**

Endpoint yang konsisten, autentikasi token, dan dokumentasi yang bisa dipercaya

---

## Yang Akan Kamu Pelajari

1. Merancang endpoint REST API yang mengikuti semantik HTTP method secara konsisten, dan mengurasi bentuk respons lewat API Resource

2. Mengimplementasikan autentikasi berbasis token dengan Sanctum untuk klien yang tidak punya cookie jar, lengkap dengan cara klien itu sendiri mengonsumsi endpoint terproteksi

3. Mendokumentasikan kontrak API memakai spesifikasi OpenAPI, agar tim lain tidak perlu membaca kode controller untuk tahu cara memanggilnya

4. Memanggil endpoint JSON dari halaman web sendiri (AJAX) dengan aman, termasuk token CSRF dan penanganan galat validasi

<div class="tip-box">
Deck ini membahas konsep. Menerapkan endpoint REST, Sanctum, OpenAPI, dan AJAX pada Simple POS terjadi di jobsheet praktikum.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Merancang Endpoint REST API

---

## Istilah Penting (1/2)

<div class="term-box">
<b>REST (Representational State Transfer):</b> gaya arsitektur API yang memetakan operasi ke resource lewat method HTTP standar (GET, POST, PUT, DELETE) dan URL yang merepresentasikan resource itu sendiri.
</div>

<div class="term-box">
<b>Endpoint:</b> satu kombinasi method HTTP dan path URL yang menjalankan satu operasi spesifik, misalnya <code>POST /api/login</code>.
</div>

<div class="term-box">
<b>Token:</b> string acak yang mewakili identitas pengguna setelah login berhasil, dikirim ulang pada setiap request berikutnya sebagai bukti bahwa pengguna itu sudah terautentikasi.
</div>

---

## Istilah Penting (2/2)

<div class="term-box">
<b>Sanctum:</b> paket autentikasi bawaan Laravel untuk API berbasis token, dirancang untuk klien SPA maupun klien mobile murni.
</div>

<div class="term-box">
<b>API Resource:</b> kelas transformasi Laravel yang mengubah model Eloquent menjadi struktur JSON yang konsisten, memisahkan bentuk respons API dari struktur kolom tabel apa adanya.
</div>

<div class="tip-box">
REST bukan protokol baku dengan aturan ketat, melainkan sekumpulan konvensi yang disepakati bersama supaya API gampang ditebak perilakunya hanya dari method dan URL-nya.
</div>

---

## Semantik HTTP Method Bukan Formalitas

<div class="cols">
<div>

**GET harus aman dan idempoten**
- Tidak mengubah state apa pun di server
- Dipanggil berkali-kali = efek sama seperti sekali
- Klien boleh mengulang request tanpa ragu

</div>
<div>

**POST boleh mengubah state**
- Bisa membuat baris baru di database
- Dipanggil dua kali bisa membuat dua baris
- Klien harus menangani risiko ini sendiri

</div>
</div>

<div class="warn-box">
<code>GET /api/products</code> yang terpanggil berkali-kali karena koneksi terputus tidak pernah menggandakan data. <code>POST /api/transactions</code> yang terpanggil dua kali karena request pertama timeout, memang berpotensi membuat dua transaksi, bukan sesuatu yang aman diasumsikan tidak terjadi.
</div>

---

## API Resource: Mengurasi Bentuk Respons

Model Eloquent yang dikembalikan langsung sebagai JSON bisa membocorkan kolom internal (`updated_at`, `password`) atau relasi yang tidak relevan bagi klien. API Resource memastikan setiap endpoint mengembalikan bentuk JSON yang sudah dikurasi dan konsisten.

```php
class ArticleResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'author' => $this->author->name,
        ];
    }
}
```

Hanya tiga kolom yang dipilih untuk muncul di JSON, apa pun kolom tambahan yang kelak ditambahkan ke tabel `articles` tidak otomatis ikut bocor ke klien.

---

<!-- _class: divider -->

# Bagian 2
## Autentikasi Token dengan Sanctum

---

## Sesi Cookie vs Token: Beda Klien, Beda Mekanisme

<div class="cols">
<div>

**Halaman web (Pertemuan 7)**
- Browser menyimpan cookie otomatis
- Sesi dicocokkan lewat cookie itu
- Cocok untuk klien yang punya cookie jar

</div>
<div>

**Klien API (mobile, skrip luar)**
- Tidak punya cookie jar seperti browser
- Token disimpan sendiri oleh klien
- Dikirim ulang eksplisit tiap request

</div>
</div>

<div class="tip-box">
Keduanya sama-sama membuktikan "siapa yang sedang request ini", hanya mekanisme penyimpanan dan pengiriman buktinya yang berbeda, menyesuaikan jenis klien yang memakainya.
</div>

---

## Alur Autentikasi Sanctum

<div class="flow">
  <div class="box">POST /api/login</div>
  <div class="arrow">&rarr;</div>
  <div class="box">createToken()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Token dikirim ke klien</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Header Authorization: Bearer</div>
</div>

```php
$user = Auth::user();
$token = $user->createToken('klien-mobile')->plainTextToken;
```

`createToken()` menyimpan token itu dalam bentuk hash di tabel `personal_access_tokens`, dan `->plainTextToken` adalah satu-satunya kesempatan token mentah itu terlihat. Setelah respons login ini, server tidak bisa lagi menunjukkan ulang token yang sama dalam bentuk terbaca.

---

## Melindungi Route dengan auth:sanctum

Route yang perlu dilindungi cukup dibungkus middleware `auth:sanctum`, mirip pola `role:admin` pada Pertemuan 7, hanya saja yang diperiksa kali ini adalah keberadaan dan keabsahan token lewat header `Authorization`, bukan sesi cookie.

```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/articles', [ArticleController::class, 'index']);
    Route::post('/articles', [ArticleController::class, 'store']);
});
```

<div class="warn-box">
Tanpa header <code>Authorization: Bearer &lt;token&gt;</code> yang valid, middleware ini menolak request sebelum pernah sampai ke controller, persis seperti <code>role:admin</code> menolak pengguna yang bukan admin sebelum sampai ke aksi yang dilindungi.
</div>

---

<!-- _class: divider -->

# Bagian 3
## Mengonsumsi API dan Mendokumentasikannya

---

## Klien Wajib Memeriksa Status Sebelum Membaca Isi

Klien API (aplikasi mobile, skrip PHP, atau bahasa apa pun) tidak pernah boleh mengasumsikan setiap request selalu berhasil.

```php
$login = Http::post("{$baseUrl}/api/login", [
    'email' => $email,
    'password' => $password,
]);

if ($login->failed()) {
    // tangani galat di sini, jangan lanjut ke langkah berikutnya
}

$token = $login->json('token');
```

<div class="warn-box">
Klien yang langsung membaca <code>$login->json('token')</code> tanpa memeriksa <code>failed()</code> lebih dulu gagal secara diam-diam: kredensial yang salah membuat <code>$token</code> bernilai <code>null</code> tanpa pernah jelas kenapa, dan galatnya baru meledak beberapa langkah kemudian di tempat yang membingungkan.
</div>

---

## Membedakan Jenis Galat

Bukan semua galat ditangani dengan cara yang sama. Kode status HTTP memberi tahu klien tindakan apa yang tepat berikutnya.

```php
match ($response->status()) {
    201 => /* tersimpan, baca $response->json('data') */,
    401 => /* token tidak valid, klien harus login ulang */,
    422 => /* input ditolak, perbaiki input, bukan login ulang */,
    default => /* galat lain, tampilkan ke pengguna */,
};
```

<div class="tip-box">
401 berarti masalah ada pada identitas klien (token kedaluwarsa atau dicabut), sementara 422 berarti masalah ada pada data yang dikirim. Menyamaratakan keduanya sebagai "login ulang saja" membuat klien mengulang login tanpa guna saat masalahnya sebenarnya ada di input.
</div>

---

## OpenAPI: Kontrak, Bukan Catatan yang Cepat Basi

<div class="term-box">
<b>OpenAPI:</b> spesifikasi terstruktur (YAML atau JSON) yang mendeskripsikan endpoint API, bisa dibaca alat lain seperti generator dokumentasi interaktif atau generator kode klien.
</div>

```yaml
paths:
  /api/articles:
    get:
      summary: Ambil daftar artikel
      responses:
        '200':
          description: Daftar artikel
```

<div class="tip-box">
Catatan teks biasa di README cepat basi karena tidak ada yang memaksa pembaruannya saat satu field respons berubah nama. Format terstruktur seperti OpenAPI bisa diperiksa alat otomatis, sehingga dokumentasi yang basi ketahuan lewat test yang gagal, bukan lewat keluhan tim lain belakangan.
</div>

---

<!-- _class: divider -->

# Bagian 4
## AJAX: Halaman Sendiri Memanggil Endpoint JSON

---

## Apa Itu AJAX?

<div class="flow">
  <div class="box">Klik tombol</div>
  <div class="arrow">&rarr;</div>
  <div class="box">fetch()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Route + controller</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Respons JSON</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Alpine update halaman</div>
</div>

- Halaman memanggil server di background, tanpa reload
- Server membalas JSON, bukan HTML
- JavaScript memperbarui bagian halaman yang berubah saja

<div class="tip-box">
Contoh: menambah komentar pada artikel tanpa membuka ulang halaman artikelnya.
</div>

---

## Dua Klien, Satu Format JSON

| | AJAX dari halaman sendiri | Klien API luar (Sanctum) |
|---|---|---|
| **File route** | `routes/web.php` | `routes/api.php` |
| **Bukti identitas** | cookie sesi (login web) | header `Authorization: Bearer` |
| **CSRF** | wajib untuk POST/PUT/PATCH/DELETE | tidak ada |
| **Middleware** | `auth` | `auth:sanctum` |
| **Respons** | JSON + kode status | JSON + kode status |

<div class="warn-box">
AJAX dari halaman sendiri yang rutenya ada di <code>api.php</code> dijawab 401: di sana tidak ada sesi, hanya token.
</div>

---

## Sisi Backend: Route dan Controller

```php
// routes/web.php
Route::middleware('auth')->group(function () {
    Route::post('/articles/{article}/comments', [CommentController::class, 'store']);
});
```

```php
public function store(Request $request, Article $article): JsonResponse
{
    $data = $request->validate(['body' => ['required', 'string', 'max:500']]);

    $comment = $article->comments()->create($data + ['user_id' => $request->user()->id]);

    return response()->json($comment, 201);   // 201 Created, bukan 200
}
```

- Validasi tetap `validate()` atau Form Request (Pertemuan 6), tidak ada kode baru
- Kode status mengikuti hasilnya: 201 dibuat, 404 tidak ada, 422 input ditolak

---

## Header `Accept` Menentukan Bentuk Galat

<div class="cols">
<div>

**Tanpa `Accept: application/json`**
- `validate()` gagal
- Laravel membalas **302 redirect** ke halaman sebelumnya
- `fetch` mengikuti redirect dan menerima **HTML**
- `res.json()` melempar galat

</div>
<div>

**Dengan `Accept: application/json`**
- `validate()` gagal
- Laravel membalas **422** dan JSON:

```json
{
  "message": "The body field is required.",
  "errors": {
    "body": ["The body field is required."]
  }
}
```

</div>
</div>

<div class="tip-box">
Sama seperti 401 dan 403: request yang meminta JSON dijawab JSON, bukan redirect ke <code>/login</code>.
</div>

---

## Sisi Frontend (1/3): Token CSRF dan `fetch`

```html
<!-- layout, di dalam <head> -->
<meta name="csrf-token" content="{{ csrf_token() }}">
```

```js
const res = await fetch(`/articles/${articleId}/comments`, {
    method: 'POST',
    headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
    },
    body: JSON.stringify({ body: this.body }),
});
```

<div class="warn-box">
Laravel 13 memeriksa header browser <code>Sec-Fetch-Site</code> lebih dulu. Kalau tidak lolos (browser lama, proxy, koneksi tidak aman), token yang menentukan, dan tanpa <code>X-CSRF-TOKEN</code> hasilnya <b>419 Page Expired</b>. Selalu kirim token.
</div>

---

## Sisi Frontend (2/3): Komponen Alpine

```js
Alpine.data('commentForm', (articleId) => ({
    body: '', errors: {}, comments: [], loading: false,

    async submit() {
        if (this.loading) return;
        this.loading = true;
        this.errors = {};
        try {
            const res = await fetch(`/articles/${articleId}/comments`, { /* seperti slide sebelumnya */ });

            if (res.status === 201) {                       // berhasil
                this.comments.push(await res.json());
                this.body = '';
            } else if (res.status === 422) {                // input ditolak
                this.errors = (await res.json()).errors;
            } else if (res.status === 401 || res.status === 419) {
                location.reload();                          // sesi habis
            } else {
                this.errors = { body: ['Terjadi kesalahan, coba lagi.'] };
            }
        } catch (e) {
            this.errors = { body: ['Gagal terhubung ke server.'] };
        } finally {
            this.loading = false;
        }
    },
}));
```

---

## Sisi Frontend (3/3): Form di Blade

```html
<form x-data="commentForm({{ $article->id }})" @submit.prevent="submit()">
    <textarea x-model="body" rows="3"></textarea>
    <p x-text="errors.body?.[0]" class="text-red-600"></p>

    <button type="submit" :disabled="loading">
        <span x-show="!loading">Kirim</span>
        <span x-show="loading">Mengirim...</span>
    </button>

    <template x-for="c in comments" :key="c.id">
        <p x-text="c.body"></p>
    </template>
</form>
```

- `@submit.prevent` mencegah form dikirim dan halaman reload
- `:disabled="loading"` mencegah komentar tersimpan dobel saat tombol diklik dua kali

---

## Jebakan Umum AJAX

| Gejala | Penyebab |
|---|---|
| **419** Page Expired | header `X-CSRF-TOKEN` tidak dikirim, dan verifikasi origin tidak lolos |
| **302**, atau `res.json()` galat karena isinya HTML | header `Accept: application/json` tidak dikirim |
| **401** padahal sudah login di browser | rute ada di `api.php`, bukan `web.php` |
| **405** Method Not Allowed | method salah; `@method('PATCH')` hanya berlaku di form HTML, `fetch` harus memakai method aslinya |
| Data tersimpan dobel | tombol tidak dinonaktifkan selama request berjalan |

<div class="ref-link">Laravel docs: <code>CSRF Protection &rarr; X-CSRF-TOKEN</code> dan <code>Validation &rarr; Validation Error Response Format</code></div>

---

## Menerapkan pada Simple POS

Kamu akan merancang dan membangun endpoint `POST /api/login`, `GET /api/products`, dan `POST /api/transactions` untuk Simple POS di jobsheet praktikum: dilindungi token Sanctum, dikonsumsi lewat klien HTTP sungguhan, dan didokumentasikan dengan OpenAPI. Kamu juga menambahkan satu fitur AJAX kecil pada halaman web: form yang mengirim JSON lewat `fetch` dan menampilkan galat validasi tanpa reload.

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos-ch09</code></div>

---

## Rangkuman (1/3)

- Endpoint REST mengikuti semantik HTTP method secara konsisten: `GET` aman dan idempoten, `POST` boleh mengubah state dan berisiko tergandakan kalau diulang
- API Resource mengurasi bentuk JSON yang dikembalikan, memisahkan respons API dari struktur kolom tabel apa adanya
- Sanctum menerbitkan token lewat `createToken()`, dikirim klien lewat header `Authorization: Bearer`, diperiksa middleware `auth:sanctum` pada route yang dilindungi

---

## Rangkuman (2/3)

- Klien API wajib memeriksa `failed()` sebelum membaca isi respons, dan membedakan penanganan 401 (login ulang) dari 422 (perbaiki input), bukan menyamaratakan semua galat
- Spesifikasi OpenAPI mendokumentasikan `paths`, `requestBody`, dan `responses` tiap endpoint dalam format terstruktur yang bisa diperiksa alat otomatis, bukan sekadar catatan pasif yang cepat basi

---

## Rangkuman (3/3): AJAX

- AJAX dari halaman sendiri memakai route di `web.php` dengan sesi cookie, bukan `api.php` dengan token
- Setiap POST/PUT/PATCH/DELETE sebaiknya membawa token CSRF lewat header `X-CSRF-TOKEN` (dari `<meta name="csrf-token">`), karena tanpa itu bisa 419
- Header `Accept: application/json` membuat `validate()` membalas 422 JSON, bukan 302 redirect
- Klien memeriksa `res.status`: 201 berhasil, 422 tampilkan galat per field, 401/419 sesi habis
- Nonaktifkan tombol selama request berjalan supaya data tidak tersimpan dobel

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Sanctum, CSRF Protection, Validation), spesifikasi OpenAPI, dan makalah Fielding tentang prinsip arsitektur REST

Kode lengkap: `github.com/se-polinema/simple-pos-ch09`

**Pertemuan berikutnya:** awal proyek PBL (Project Based Learning), kamu akan merencanakan fitur dan arsitektur proyek webmu sendiri
