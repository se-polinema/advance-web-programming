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

Dari use case ke resource, response yang konsisten, autentikasi token, sampai API dipakai klien

---

## Yang Akan Kamu Pelajari

1. Menjelaskan prinsip **REST** dan menyusun **proses merancang API** dari use case sampai kontrak
2. Memodelkan **resource, URL, dan method HTTP** yang tepat (aman, idempotent)
3. Merancang **response**: kode status, bentuk JSON, pagination, format error, dan versioning
4. Mengamankan API dengan **token Sanctum**, otorisasi, dan rate limiting
5. Mendokumentasikan dengan **OpenAPI**, menguji, dan **mengonsumsi** API dari klien (HTTP client dan AJAX)

<div class="tip-box">
Deck ini terbagi dalam 5 bagian yang berdiri sendiri. Menerapkannya pada Simple POS dikerjakan di jobsheet praktikum.
</div>

---

## Peta Pertemuan

<div class="flow">
  <div class="box">1. Dasar</div>
  <div class="arrow">&rarr;</div>
  <div class="box">2. Resource</div>
  <div class="arrow">&rarr;</div>
  <div class="box">3. Response</div>
  <div class="arrow">&rarr;</div>
  <div class="box">4. Keamanan</div>
  <div class="arrow">&rarr;</div>
  <div class="box">5. Konsumsi</div>
</div>

<div class="tip-box">
API adalah menu restoran: pelanggan (klien) tidak perlu tahu isi dapur, cukup tahu apa yang bisa dipesan dan seperti apa hidangannya datang. Merancang API berarti menulis menu itu dengan rapi.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Dasar REST dan Proses Desain

---

## Apa Itu API dan REST?

| Istilah | Artinya |
|---|---|
| **API** | antarmuka yang dipanggil program lain, bukan manusia |
| **REST** | gaya arsitektur: resource diakses lewat URL dan method HTTP standar |
| **Resource** | benda yang dikelola API (artikel, komentar, penulis) |
| **Endpoint** | satu kombinasi method dan URL, misalnya `GET /api/v1/articles` |
| **Representasi** | bentuk resource yang dikirim, biasanya JSON |
| **Kontrak** | kesepakatan tertulis tentang endpoint, input, dan output |

<div class="tip-box">
Satu backend, banyak klien (web, mobile, mitra), dan aturan bisnis ada di satu tempat. Klien API sering ditulis orang lain, jadi API harus dirancang, bukan sekadar "jalan".
</div>

---

## Lima Prinsip REST

| Prinsip | Maksudnya |
|---|---|
| **Client-server** | klien mengurus tampilan, server mengurus data dan aturan |
| **Stateless** | server tidak mengingat request sebelumnya, token dikirim tiap kali |
| **Uniform interface** | resource dan method HTTP dipakai seragam di semua endpoint |
| **Cacheable** | response boleh menyatakan apakah bisa disimpan klien |
| **Layered** | klien tidak tahu apakah bicara langsung ke server atau lewat proxy |

<div class="tip-box">
REST bukan protokol baku, melainkan kumpulan konvensi. Yang diuji adalah apakah API-mu mudah ditebak.
</div>

---

## Anatomi Request dan Response

<div class="cols">
<div>

**Request**
```http
POST /api/v1/articles HTTP/1.1
Accept: application/json
Content-Type: application/json
Authorization: Bearer 1|abc...

{"title": "Belajar REST"}
```

</div>
<div>

**Response**
```http
HTTP/1.1 201 Created
Content-Type: application/json
Location: /api/v1/articles/7

{"data": {"id": 7, "title": "Belajar REST"}}
```

</div>
</div>

- Method + URL: apa yang diminta. Header: konteks. Body: data
- Status code: hasilnya. Body: representasi resource atau error

---

## Proses Merancang API

<div class="flow">
  <div class="box">1. Use case</div>
  <div class="arrow">&rarr;</div>
  <div class="box">2. Resource</div>
  <div class="arrow">&rarr;</div>
  <div class="box">3. Operasi</div>
  <div class="arrow">&rarr;</div>
  <div class="box">4. Representasi</div>
</div>
<div class="flow">
  <div class="box">5. Error</div>
  <div class="arrow">&rarr;</div>
  <div class="box">6. Keamanan</div>
  <div class="arrow">&rarr;</div>
  <div class="box">7. Versi</div>
  <div class="arrow">&rarr;</div>
  <div class="box">8. Dokumentasi</div>
</div>

<div class="tip-box">
Rancang dulu di kertas, baru tulis kode. Mengubah URL atau bentuk JSON setelah klien memakainya jauh lebih mahal daripada mengubah kode controller.
</div>

---

## Contoh yang Kita Pakai: API Blog

Aplikasi mobile blog dengan **penulis**, **artikel**, dan **komentar**.

| Use case | Siapa | Resource |
|---|---|---|
| Lihat daftar dan detail artikel | siapa saja | `articles` |
| Tulis, ubah, hapus artikel | penulis (pemilik) | `articles` |
| Terbitkan artikel | penulis (pemilik) | status pada `articles` |
| Lihat dan tulis komentar | lihat: siapa saja, tulis: pengguna login | `comments` (anak `articles`) |
| Masuk dan keluar | pengguna | `login`, `logout` |

- Cari **kata benda**, bukan kata kerja. Satu resource = satu konsep dengan identitas (ID)

---

## Ringkas Bagian 1

- API = antarmuka untuk program lain, dan harus **dirancang** karena klien tidak bisa kamu perbaiki
- REST: client-server, stateless, uniform interface, cacheable, layered
- Request = method + URL + header + body. Response = status code + body
- Proses: use case, resource, operasi, representasi, error, keamanan, versi, dokumentasi
- Rancang di kertas dulu: mengubah kontrak setelah dipakai klien itu mahal

---

<!-- _class: divider -->

# Bagian 2
## Resource, URL, dan Method

---

## Aturan Penamaan URL

| Aturan | Baik | Buruk |
|---|---|---|
| Kata benda, bukan kata kerja | `/articles` | `/getArticles` |
| Jamak | `/articles/7` | `/article/7` |
| Huruf kecil, tanda hubung | `/article-tags` | `/ArticleTags` |
| Tanpa ekstensi dan slash akhir | `/articles` | `/articles.json/` |
| ID di path, filter di query | `/articles/7`, `?status=draft` | `/articles/status/draft` |

<div class="tip-box">
Method HTTP sudah menjadi kata kerjanya. <code>GET /articles</code> dibaca "ambil artikel", jadi tidak perlu <code>getArticles</code>.
</div>

---

## CRUD Menjadi Method + URL

| Operasi | Method + URL | Sukses |
|---|---|---|
| Daftar artikel | `GET /articles` | 200 |
| Satu artikel | `GET /articles/{id}` | 200 |
| Buat artikel | `POST /articles` | 201 |
| Ganti seluruhnya | `PUT /articles/{id}` | 200 |
| Ubah sebagian | `PATCH /articles/{id}` | 200 |
| Hapus | `DELETE /articles/{id}` | 204 |

```php
Route::apiResource('articles', ArticleController::class);   // index, store, show, update, destroy
```

---

## Relasi dan Nesting

```text
GET  /articles/7/comments        komentar milik artikel 7
POST /articles/7/comments        tambah komentar ke artikel 7
GET  /comments/31                satu komentar (ID sudah unik)
```

<div class="cols">
<div>

**Nesting dipakai kalau**
- Anak tidak bermakna tanpa induk
- Ingin mengambil daftar anak dari induk

</div>
<div>

**Hindari**
- Lebih dari 2 tingkat: `/a/1/b/2/c/3/d`
- Menyalin semua operasi di dua jalur

</div>
</div>

---

## Method Aman dan Idempotent

| Method | Aman (tidak ubah data) | Idempotent (diulang = efek sama) |
|---|---|---|
| `GET` | ya | ya |
| `PUT`, `DELETE` | tidak | ya |
| `PATCH` | tidak | tergantung desain |
| `POST` | tidak | **tidak** |

<div class="warn-box">
<code>POST /transactions</code> yang diulang karena timeout bisa membuat dua transaksi. Solusi: <b>idempotency key</b>, yaitu klien mengirim header <code>Idempotency-Key: &lt;uuid&gt;</code> dan server mengembalikan hasil lama untuk key yang sama. Laravel tidak menyediakannya bawaan: simpan key di tabel dengan unique index.
</div>

---

## PUT vs PATCH

<div class="cols">
<div>

**PUT**: ganti seluruh resource
```json
PUT /articles/7
{ "title": "Baru", "body": "Isi baru",
  "status": "draft" }
```
Field yang tidak dikirim dianggap kosong.

</div>
<div>

**PATCH**: ubah sebagian
```json
PATCH /articles/7
{ "title": "Baru" }
```
Hanya field yang dikirim yang berubah.

</div>
</div>

```php
// validasi PATCH: periksa field hanya kalau dikirim
'title' => ['sometimes', 'required', 'string'],
'body'  => ['sometimes', 'required', 'string'],
```

<div class="tip-box">
Tanpa <code>sometimes</code>, <code>PATCH {"title": "Baru"}</code> ditolak 422 karena <code>body</code> wajib. Kalau field dikirim, <code>required</code> tetap berlaku: <code>{"title": ""}</code> tetap 422.
</div>

---

## Aksi yang Bukan CRUD

Bagaimana "menerbitkan artikel" atau "membatalkan transaksi"?

| Pilihan | Contoh | Kapan |
|---|---|---|
| Ubah **status** lewat PATCH | `PATCH /articles/7` `{"status":"published"}` | status adalah atribut resource (disarankan) |
| Aksi sebagai **sub-resource** | `POST /articles/7/publication` | aksi punya efek samping dan riwayat |
| Aksi sebagai kata kerja | `POST /articles/7/publish` | jalan terakhir kalau dua opsi lain tidak cocok |

<div class="warn-box">
Jangan membuat <code>POST /publishArticle</code>. Cari kata benda atau status yang menggambarkan hasilnya.
</div>

---

## Ringkas Bagian 2

- URL = kata benda jamak, method HTTP = kata kerja, nesting maksimal 2 tingkat
- `apiResource` menghasilkan 5 route CRUD sekaligus
- `GET`, `PUT`, `DELETE` aman diulang. `POST` tidak, kecuali memakai idempotency key
- PUT mengganti semua, PATCH mengubah sebagian (validasi pakai `sometimes`)
- Aksi non-CRUD: ubah status atau buat sub-resource, bukan kata kerja di URL

---

<!-- _class: divider -->

# Bagian 3
## Merancang Response

---

## Kode Status

Lima kelompok: **2xx** berhasil, **3xx** dialihkan, **4xx** salah di sisi klien, **5xx** salah di sisi server.

| Kode | Pakai saat |
|---|---|
| **200** OK / **201** Created | GET, PUT, PATCH berhasil / POST membuat resource (sertakan `Location`) |
| **204** No Content | DELETE berhasil, tanpa body |
| **400** / **422** | request rusak (JSON tidak valid) / format benar tapi validasi gagal |
| **401** / **403** | tidak ada identitas atau token tidak valid / identitas valid tapi tidak boleh |
| **404** / **409** | resource tidak ada / bentrok dengan keadaan saat ini |
| **429** | terkena rate limit |

<div class="tip-box">
Klien memutuskan tindakan dari <b>kode status</b> dulu, baru membaca isi. Jangan membalas <code>200</code> dengan isi <code>{"error": ...}</code>.
</div>

---

## 401 vs 403 vs 404 vs 422

<div class="cols">
<div>

**401: siapa kamu?**
- Token tidak ada, salah, atau kedaluwarsa
- Klien: login ulang

**403: kamu tidak boleh**
- Token valid, tapi role atau ability tidak cukup
- Klien: tampilkan "tidak punya akses"

</div>
<div>

**404: tidak ada**
- Resource memang tidak ada, atau sengaja disembunyikan dari yang tidak berhak (draft milik orang lain)

**422: isi salah**
- Validasi gagal, sertakan field mana yang salah

</div>
</div>

<div class="warn-box">
Menyamaratakan semuanya jadi "gagal" membuat klien tidak tahu harus apa: login ulang, memperbaiki input, atau menyerah.
</div>

---

## Bentuk Response dan Konvensi JSON

```json
// GET /api/v1/articles
{
  "data": [ { "id": 7, "title": "Belajar REST" } ],
  "links": { "next": "/api/v1/articles?page=2" },
  "meta": { "current_page": 1, "per_page": 15, "total": 42 }
}
```

- Bentuk yang sama di semua endpoint: data di `data`, info tambahan di `meta` dan `links`. Koleksi selalu array (`[]`, bukan `null`)
- Field `snake_case`, tanggal ISO 8601 (`"2026-08-20T10:30:00Z"`), boolean `true`/`false`, kosong tetap tampil sebagai `null`
- Uang sebagai bilangan bulat satuan terkecil (`15000`), bukan float: `0.1 + 0.2` tidak sama dengan `0.3`

---

## API Resource: Menyaring Apa yang Keluar

Tanpa Resource, **semua** column ikut keluar (termasuk yang internal). Dengan Resource, hanya field pilihanmu.

```php
class ArticleResource extends JsonResource   // php artisan make:resource ArticleResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'author' => new AuthorResource($this->whenLoaded('author')),
            'comments_count' => $this->whenCounted('comments'),
        ];
    }
}
```

- `whenLoaded()` hanya memasukkan relasi yang sudah di-load (tanpa N+1 diam-diam). Koleksi: `ArticleResource::collection($articles)`

---

## Pagination, Filter, Sort, dan Search

| | Offset (`paginate`) | Cursor (`cursorPaginate`) |
|---|---|---|
| **Parameter** | `?page=3` | `?cursor=eyJpZCI6NDV9` |
| **Lompat ke halaman N** | bisa | tidak |
| **Data berubah / sangat besar** | bisa terlewat atau melambat | stabil dan cepat (butuh index) |

```php
Article::query()
    ->when($request->status, fn ($q, $v) => $q->where('status', $v))        // ?status=published
    ->when($request->q, fn ($q, $v) => $q->where('title', 'like', "%{$v}%"))
    ->orderBy($sortColumn, $direction)                                       // ?sort=-published_at
    ->paginate(min($request->integer('per_page', 15), 100));                 // batasi per_page
```

<div class="warn-box">
Column untuk sort harus dari daftar putih, dan <code>per_page</code> dibatasi. Jangan memasukkan input klien langsung ke <code>orderBy()</code>.
</div>

---

## Format Error yang Konsisten

```json
// 422: validasi gagal
{ "message": "The title field is required.", "errors": { "title": ["The title field is required."] } }

// 404: tidak ditemukan
{ "message": "Resource tidak ditemukan." }
```

```php
// bootstrap/app.php: error di api/* selalu JSON
->withExceptions(function (Exceptions $exceptions): void {
    $exceptions->shouldRenderJsonWhen(fn (Request $request) => $request->is('api/*') || $request->expectsJson());
})
```

- `message` untuk manusia, `errors` per field hanya untuk 422. Route model binding yang gagal ikut menjadi 404 JSON
- Production: `APP_DEBUG=false`, jangan bocorkan stack trace atau nama tabel
- Standar yang lebih ketat: RFC 9457 (Problem Details for HTTP APIs)

---

## Versioning dan Performa

| Perubahan | Merusak klien lama? |
|---|---|
| Menambah field atau endpoint baru | tidak |
| Menghapus atau mengganti nama field | **ya** |
| Mengubah tipe data (`"15000"` jadi `15000`) | **ya** |
| Menambah field wajib di request | **ya** |

```php
Route::prefix('v1')->group(function () {          // /api/v1/articles
    Route::apiResource('articles', ArticleController::class);
});
```

- Perubahan yang merusak = versi baru (`/api/v2`). Versi lama hidup sampai klien pindah, umumkan lewat header `Deprecation` dan `Sunset`
- Response murah: `with('author')` (hindari N+1), `paginate()`, index pada column filter, `Cache-Control`/`ETag` (304), gzip

---

## Ringkas Bagian 3

- Kode status memberi tahu klien tindakan berikutnya: 201, 204, 401, 403, 404, 422, 429
- Bentuk JSON konsisten: `data`, `meta`, `links`. Error selalu `message` dan `errors`
- API Resource menyaring field, `whenLoaded()` mencegah N+1
- `paginate` atau `cursorPaginate` dengan batas `per_page`. Filter dan sort lewat query string dengan daftar putih
- Prefix versi (`/v1`) untuk perubahan yang merusak. `shouldRenderJsonWhen` membuat error API selalu JSON

---

<!-- _class: divider -->

# Bagian 4
## Autentikasi, Otorisasi, dan Keamanan

---

## Sesi Cookie vs Token

<div class="cols">
<div>

**Halaman web (Pertemuan 7)**
- Browser menyimpan cookie otomatis
- Sesi dicocokkan lewat cookie itu

</div>
<div>

**Klien API (mobile, skrip luar)**
- Tidak punya cookie jar seperti browser
- Token disimpan klien, dikirim ulang eksplisit tiap request

</div>
</div>

<div class="tip-box">
Keduanya sama-sama membuktikan "siapa yang sedang request ini". Yang beda hanya cara bukti itu disimpan dan dikirim.
</div>

---

## Sanctum: Alur dan Endpoint Login

<div class="flow">
  <div class="box">POST /api/login</div>
  <div class="arrow">&rarr;</div>
  <div class="box">createToken()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Token ke klien</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Authorization: Bearer</div>
</div>

```php
$user = User::where('email', $data['email'])->first();

if (! $user || ! Hash::check($data['password'], $user->password)) {
    return response()->json(['message' => 'Kredensial tidak valid.'], 401);   // pesan sama untuk email/password salah
}

return response()->json(['token' => $user->createToken('klien-mobile')->plainTextToken]);
```

- Token disimpan sebagai **hash** di `personal_access_tokens`. `plainTextToken` hanya terlihat sekali, klien wajib menyimpannya

---

## Melindungi Route dan Token Abilities

```php
Route::post('/login', [AuthController::class, 'login']);                  // publik

Route::middleware('auth:sanctum')->group(function () {                    // wajib token
    Route::apiResource('articles', ArticleController::class)->only(['index', 'show']);
    Route::post('/articles', [ArticleController::class, 'store'])
        ->middleware('abilities:articles:write');                        // butuh ability
});
```

```php
$user->createToken('laporan-bot', ['articles:read']);                       // izin sekecil mungkin
$user->createToken('editor-app', ['articles:read', 'articles:write']);
```

- Tanpa token yang valid: **401** sebelum sampai ke controller. Token tanpa ability cukup: **403**
- Alias middleware `abilities` dan `ability` didaftarkan di `bootstrap/app.php`

---

## Otorisasi: Token Valid Belum Berarti Boleh

<div class="cols">
<div>

**Autentikasi**: siapa kamu?
- Token valid, user ditemukan
- Gagal: 401

</div>
<div>

**Otorisasi**: boleh apa?
- Policy, role, atau ability
- Gagal: 403

</div>
</div>

```php
public function update(Request $request, Article $article): ArticleResource
{
    $this->authorize('update', $article);     // ArticlePolicy: hanya penulisnya
    $article->update($request->validated());
    return new ArticleResource($article);
}
```

- Policy dan role dari Pertemuan 7 dipakai ulang di API
- Batasi query ke milik user: `$request->user()->articles()`, bukan `Article::find($id)` dari input klien (cegah IDOR)

---

## Siklus Hidup Token dan Rate Limiting

| Hal | Cara |
|---|---|
| Logout (cabut token ini) | `$request->user()->currentAccessToken()->delete()` |
| Cabut semua token | `$user->tokens()->delete()` |
| Kedaluwarsa | `'expiration' => 525600` di `config/sanctum.php` |
| Bersihkan token basi | `php artisan sanctum:prune-expired --hours=24` |

```php
RateLimiter::for('api', fn (Request $request) => Limit::perMinute(60)->by($request->user()?->id ?: $request->ip()));

Route::middleware(['auth:sanctum', 'throttle:api'])->group(/* ... */);
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');   // login lebih ketat
```

<div class="warn-box">
Token Sanctum secara default <b>tidak pernah kedaluwarsa</b>. Terlampaui rate limit: <b>429</b> dengan header <code>Retry-After</code>.
</div>

---

## Checklist Keamanan API

<div class="cols">
<div>

**Wajib**
- HTTPS di production
- Validasi semua input (`validate()`)
- `$fillable` di model, bukan `$guarded = []`
- Token dihash di database, tidak di-log
- Rate limit, terutama di `/login`
- `APP_DEBUG=false` di production

</div>
<div>

**Sering terlupa**
- Cek kepemilikan resource (IDOR)
- Batasi `per_page` dan column untuk sort
- Jangan kembalikan model mentah (`password`, `remember_token`)
- CORS hanya untuk origin yang dikenal
- Pesan error tidak membocorkan detail internal

</div>
</div>

<div class="ref-link">Laravel docs: <code>Sanctum</code>, <code>Routing &rarr; Rate Limiting</code>, dan <code>Routing &rarr; CORS</code></div>

---

## Ringkas Bagian 4

- Web memakai sesi cookie, klien API memakai token Bearer (Sanctum: `createToken()`, `auth:sanctum`)
- Autentikasi gagal = 401, otorisasi gagal = 403. Abilities membatasi token, policy membatasi aksi
- Cek kepemilikan resource lewat query milik user atau policy (cegah IDOR)
- Atur masa berlaku token, sediakan pencabutan, dan pasang `throttle` (login lebih ketat)
- HTTPS, `APP_DEBUG=false`, dan jangan kembalikan model mentah

---

<!-- _class: divider -->

# Bagian 5
## Dokumentasi, Pengujian, dan Konsumsi API

---

## OpenAPI: Kontrak, Bukan Catatan yang Cepat Basi

<div class="term-box">
<b>OpenAPI:</b> spesifikasi terstruktur (YAML atau JSON) yang mendeskripsikan endpoint, input, output, dan autentikasi. Bisa dibaca alat: dokumentasi interaktif (Swagger UI), generator klien, validator.
</div>

```yaml
paths:
  /api/v1/articles:
    post:
      security: [ { bearerAuth: [] } ]
      requestBody:
        content: { application/json: { schema: { $ref: '#/components/schemas/ArticleInput' } } }
      responses:
        '201': { description: Dibuat }
        '401': { description: Token tidak valid }
        '422': { description: Validasi gagal }
components:
  securitySchemes: { bearerAuth: { type: http, scheme: bearer } }
  schemas:
    ArticleInput: { type: object, required: [title], properties: { title: { type: string } } }
```

- **Contract-first**: tulis kontrak, sepakati, implementasi, uji. Tim mobile dan backend bekerja paralel, dan kontrak ikut di repositori

---

## Menguji API di Laravel

```php
public function test_guest_cannot_create_article(): void
{
    $this->postJson('/api/v1/articles', ['title' => 'X'])->assertUnauthorized();          // 401
}

public function test_create_article_validates_title(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', [])
        ->assertUnprocessable()->assertJsonValidationErrors('title');                     // 422
}

public function test_create_article_returns_created(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', ['title' => 'Belajar REST'])
        ->assertCreated()->assertJsonPath('data.title', 'Belajar REST');                  // 201
}
```

---

## Klien HTTP: Status, Error, dan Retry

```php
$login = Http::post("{$baseUrl}/api/login", ['email' => $email, 'password' => $password]);

if ($login->failed()) { /* tangani error, jangan lanjut */ }   // bukan langsung ->json('token')

$token = $login->json('token');

match ($response->status()) {
    201 => /* tersimpan, baca $response->json('data') */,
    401 => /* token tidak valid, login ulang */,
    422 => /* input ditolak, perbaiki input */,
    429 => /* terlalu sering, tunggu sesuai Retry-After */,
    default => /* error lain, tampilkan ke pengguna */,
};
```

| Jenis | Boleh diulang otomatis? |
|---|---|
| 4xx (kecuali 429) | tidak, request-nya yang salah |
| 429, 503 | ya, setelah jeda (`Retry-After`) |
| 5xx pada `GET` | ya, dengan backoff. Pada `POST`: hanya dengan idempotency key |

---

## AJAX: Halaman Sendiri Memanggil Endpoint JSON

<div class="flow">
  <div class="box">Klik</div>
  <div class="arrow">&rarr;</div>
  <div class="box">fetch()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Route</div>
  <div class="arrow">&rarr;</div>
  <div class="box">JSON</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Alpine update</div>
</div>

| | AJAX dari halaman sendiri | Klien API luar (Sanctum) |
|---|---|---|
| **File route** | `routes/web.php` | `routes/api.php` |
| **Bukti identitas** | cookie sesi (login web) | header `Authorization: Bearer` |
| **CSRF** | wajib untuk POST/PUT/PATCH/DELETE | tidak ada |
| **Middleware** | `auth` | `auth:sanctum` |

<div class="warn-box">
AJAX dari halaman sendiri yang rutenya ada di <code>api.php</code> dijawab 401: di sana tidak ada sesi, hanya token.
</div>

---

## AJAX Backend: Route, Controller, dan Header `Accept`

```php
Route::middleware('auth')->post('/articles/{article}/comments', [CommentController::class, 'store']);   // web.php

public function store(Request $request, Article $article): JsonResponse
{
    $data = $request->validate(['body' => ['required', 'string', 'max:500']]);

    return response()->json($article->comments()->create($data + ['user_id' => $request->user()->id]), 201);
}
```

<div class="cols">
<div>

**Tanpa `Accept: application/json`**
- `validate()` gagal: **302 redirect**
- `fetch` menerima HTML, `res.json()` melempar error

</div>
<div>

**Dengan `Accept: application/json`**
- `validate()` gagal: **422** + JSON
- `{"message": "...", "errors": {"body": [...]}}`

</div>
</div>

---

## AJAX Frontend: CSRF, `fetch`, dan Alpine

```html
<meta name="csrf-token" content="{{ csrf_token() }}">   <!-- di <head> layout -->
```

```js
Alpine.data('commentForm', (articleId) => ({
    body: '', errors: {}, comments: [], loading: false,

    async submit() {
        if (this.loading) return;
        this.loading = true; this.errors = {};
        const res = await fetch(`/articles/${articleId}/comments`, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content },
            body: JSON.stringify({ body: this.body }),
        });
        if (res.status === 201) { this.comments.push(await res.json()); this.body = ''; }
        else if (res.status === 422) { this.errors = (await res.json()).errors; }
        else if (res.status === 401 || res.status === 419) { location.reload(); }
        this.loading = false;
    },
}));
```

---

## Jebakan Umum AJAX

| Gejala | Penyebab |
|---|---|
| **419** Page Expired | header `X-CSRF-TOKEN` tidak dikirim (kalau verifikasi origin `Sec-Fetch-Site` tidak lolos, token yang menentukan) |
| **302**, atau `res.json()` error karena isinya HTML | header `Accept: application/json` tidak dikirim |
| **401** padahal sudah login di browser | rute ada di `api.php`, bukan `web.php` |
| **405** Method Not Allowed | `@method('PATCH')` hanya berlaku di form HTML, `fetch` harus memakai method aslinya |
| Data tersimpan dobel | tombol tidak dinonaktifkan (`:disabled="loading"`) selama request berjalan |

<div class="ref-link">Laravel docs: <code>CSRF Protection &rarr; X-CSRF-TOKEN</code> dan <code>Validation &rarr; Validation Error Response Format</code></div>

---

## Ringkas Bagian 5

- OpenAPI = kontrak yang bisa dibaca alat. Contract-first: tulis, sepakati, implementasi, uji
- Uji dengan `getJson`, `postJson`, `Sanctum::actingAs`: minimal 401, 403, 422, dan jalur sukses
- Klien memeriksa status sebelum membaca isi, dan hanya mengulang error yang boleh diulang
- AJAX dari halaman sendiri memakai `web.php` + sesi + CSRF, bukan `api.php` + token
- Kirim `Accept: application/json` dan `X-CSRF-TOKEN`, periksa `res.status`, dan nonaktifkan tombol saat request berjalan

---

## Checklist Review Desain API

<div class="cols">
<div>

**Resource, URL, dan response**
- URL kata benda jamak, tanpa kata kerja
- Method sesuai makna (aman, idempotent), nesting maksimal 2 tingkat
- Aksi non-CRUD sebagai status atau sub-resource
- Kode status tepat, bentuk sukses dan error konsisten
- Koleksi dipaginasi dengan batas

</div>
<div>

**Keamanan, evolusi, dokumentasi**
- Autentikasi dan otorisasi terpisah (401 vs 403)
- Cek kepemilikan resource, rate limit, HTTPS
- Ada prefix versi
- Kontrak OpenAPI ikut di repositori
- Ada test untuk 401, 403, 422, dan jalur sukses

</div>
</div>

---

## Menerapkan pada Simple POS

Di jobsheet, kamu menerapkan konsep ini pada Simple POS:

1. Memasang Sanctum, endpoint `POST /api/login`, dan token
2. Endpoint produk dan transaksi dengan API Resource, 401 dan 422
3. Merapikan desain: prefix versi, pagination, filter, dan format error konsisten
4. Klien HTTP sungguhan dan dokumentasi OpenAPI
5. Satu fitur AJAX kecil pada halaman web: form yang mengirim JSON lewat `fetch`

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos-ch09</code></div>

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Sanctum, Eloquent API Resources, Pagination, Routing, CSRF Protection, Validation), spesifikasi OpenAPI, RFC 9457, dan makalah Fielding tentang prinsip arsitektur REST

Kode lengkap: `github.com/se-polinema/simple-pos-ch09`

**Pertemuan berikutnya:** awal proyek PBL (Project Based Learning), kamu akan merencanakan fitur dan arsitektur proyek webmu sendiri
