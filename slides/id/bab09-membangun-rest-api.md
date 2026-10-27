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

Dari use case ke resource, respons yang konsisten, autentikasi token, dan dokumentasi yang bisa dipercaya

---

## Yang Akan Kamu Pelajari

1. Menjelaskan prinsip **REST** dan menyusun **proses merancang API** dari use case sampai kontrak
2. Memodelkan **resource dan URL**, dan memilih method HTTP yang tepat (aman, idempotent)
3. Merancang **respons**: kode status, bentuk JSON, pagination, filter, format galat, dan versioning
4. Mengamankan API dengan **token Sanctum**, abilities, otorisasi, dan rate limiting
5. Mendokumentasikan kontrak dengan **OpenAPI**, menguji, dan mengonsumsi API dengan benar
6. Memanggil endpoint JSON dari halaman web sendiri (**AJAX**) dengan aman

<div class="tip-box">
Deck ini membahas konsep. Menerapkannya pada Simple POS dikerjakan di jobsheet praktikum.
</div>

---

## Peta Pertemuan

<div class="flow">
  <div class="box">Use case</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Resource</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Respons</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Keamanan</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Dokumentasi</div>
</div>

<div class="tip-box">
API adalah menu restoran: pelanggan (klien) tidak perlu tahu isi dapur, cukup tahu apa yang bisa dipesan dan seperti apa hidangannya datang. Merancang API berarti menulis menu itu dengan rapi.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Dasar REST dan Proses Desain

---

## Istilah Penting

| Istilah | Artinya |
|---|---|
| **API** | antarmuka yang dipanggil program lain, bukan manusia |
| **REST** | gaya arsitektur: resource diakses lewat URL dan method HTTP standar |
| **Resource** | benda yang dikelola API (artikel, komentar, penulis) |
| **Endpoint** | satu kombinasi method dan URL, misalnya `GET /api/v1/articles` |
| **Representasi** | bentuk resource yang dikirim, biasanya JSON |
| **Stateless** | tiap request membawa semua informasi yang dibutuhkan server |
| **Kontrak** | kesepakatan tertulis tentang endpoint, input, dan output |

---

## Kenapa Butuh API?

<div class="cols">
<div>

**Tanpa API**
- Tiap klien punya logika sendiri
- Aturan bisnis ditulis berkali-kali
- Satu perubahan, banyak tempat diperbaiki

</div>
<div>

**Dengan API**
- Satu backend, banyak klien: web, mobile, mitra
- Aturan bisnis ada di satu tempat
- Klien baru cukup membaca kontrak

</div>
</div>

<div class="tip-box">
Klien API sering ditulis orang lain, di bahasa lain, dan tidak bisa kamu perbaiki. Karena itu API harus dirancang, bukan sekadar "jalan".
</div>

---

## Lima Prinsip REST

| Prinsip | Maksudnya |
|---|---|
| **Client-server** | klien mengurus tampilan, server mengurus data dan aturan |
| **Stateless** | server tidak mengingat request sebelumnya, token dikirim tiap kali |
| **Uniform interface** | resource dan method HTTP dipakai seragam di semua endpoint |
| **Cacheable** | respons boleh menyatakan apakah bisa disimpan klien |
| **Layered** | klien tidak tahu apakah bicara langsung ke server atau lewat proxy |

<div class="tip-box">
REST bukan protokol baku, melainkan kumpulan konvensi. Yang diuji adalah apakah API-mu mudah ditebak.
</div>

---

## Anatomi Request dan Respons

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

**Respons**
```http
HTTP/1.1 201 Created
Content-Type: application/json
Location: /api/v1/articles/7

{"data": {"id": 7, "title": "Belajar REST"}}
```

</div>
</div>

- Method + URL: apa yang diminta. Header: konteks. Body: data
- Status code: hasilnya. Body: representasi resource atau galat

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
  <div class="box">5. Galat</div>
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

<!-- _class: divider -->

# Bagian 2
## Merancang Resource dan URL

---

## Dari Use Case ke Resource

Contoh domain: blog dengan **penulis**, **artikel**, dan **komentar**.

| Use case | Kata benda (resource) |
|---|---|
| Pembaca melihat daftar artikel | artikel |
| Pembaca membaca satu artikel | artikel |
| Pengguna menulis komentar | komentar |
| Penulis menerbitkan artikel | artikel (status berubah) |
| Melihat artikel milik satu penulis | penulis, artikel |

- Cari **kata benda**, bukan kata kerja
- Satu resource = satu konsep yang punya identitas (ID)

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

## Operasi CRUD Menjadi Method + URL

| Operasi | Method + URL | Sukses |
|---|---|---|
| Daftar artikel | `GET /articles` | 200 |
| Satu artikel | `GET /articles/{id}` | 200 |
| Buat artikel | `POST /articles` | 201 |
| Ganti seluruhnya | `PUT /articles/{id}` | 200 |
| Ubah sebagian | `PATCH /articles/{id}` | 200 |
| Hapus | `DELETE /articles/{id}` | 204 |

```php
Route::apiResource('articles', ArticleController::class);   // 5 route: index, store, show, update, destroy
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

<div class="tip-box">
Kalau anak sudah punya ID unik, akses satuannya cukup <code>/comments/31</code>. Nesting untuk daftar dan pembuatan.
</div>

---

## Method Aman dan Idempotent

| Method | Aman (tidak ubah data) | Idempotent (diulang = efek sama) |
|---|---|---|
| `GET` | ya | ya |
| `PUT` | tidak | ya |
| `PATCH` | tidak | tergantung desain |
| `DELETE` | tidak | ya |
| `POST` | tidak | **tidak** |

<div class="warn-box">
<code>POST /transactions</code> yang diulang karena timeout bisa membuat dua transaksi. <code>GET</code>, <code>PUT</code>, dan <code>DELETE</code> aman diulang oleh klien.
</div>

---

## PUT vs PATCH

<div class="cols">
<div>

**PUT**: ganti seluruh resource
```json
PUT /articles/7
{ "title": "Baru",
  "body": "Isi baru",
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

<div class="tip-box">
PATCH hanya mengirim sebagian field, jadi aturan validasinya perlu disesuaikan. Lihat slide berikutnya.
</div>

---

## Validasi PATCH: Gunakan `sometimes`

<div class="cols">
<div>

**Tanpa `sometimes`**
```php
'title' => ['required', 'string'],
'body'  => ['required', 'string'],
```
`PATCH {"title": "Baru"}` menghasilkan **422**: "The body field is required", padahal klien hanya ingin mengubah judul.

</div>
<div>

**Dengan `sometimes`**
```php
'title' => ['sometimes', 'required', 'string'],
'body'  => ['sometimes', 'required', 'string'],
```
`PATCH {"title": "Baru"}` menghasilkan **200**. `body` tidak dikirim, jadi tidak diperiksa dan isinya tidak berubah.

</div>
</div>

<div class="tip-box">
<code>sometimes</code> artinya "periksa field ini hanya kalau dikirim". Kalau field dikirim, <code>required</code> tetap berlaku: <code>{"title": ""}</code> tetap ditolak dengan 422.
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

## Idempotency Key: Membuat POST Aman Diulang

<div class="flow">
  <div class="box">Klien buat key</div>
  <div class="arrow">&rarr;</div>
  <div class="box">POST + key</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Server simpan</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Ulang: hasil lama</div>
</div>

```http
POST /api/v1/transactions
Idempotency-Key: 8f14e45f-ceea-467f-a0e1-8b1c2e1d9f10
```

- Key yang sama = request yang sama, server tidak membuat data kedua
- Dipakai pada operasi yang tidak boleh ganda: pembayaran, transaksi
- Laravel tidak menyediakannya bawaan: simpan key di tabel dengan unique index

---

<!-- _class: divider -->

# Bagian 3
## Merancang Respons

---

## Kode Status: Lima Kelompok

| Kelompok | Arti | Contoh |
|---|---|---|
| **2xx** | berhasil | 200 OK, 201 Created, 204 No Content |
| **3xx** | dialihkan | 301 Moved Permanently, 304 Not Modified |
| **4xx** | salah di sisi klien | 401, 403, 404, 422, 429 |
| **5xx** | salah di sisi server | 500, 503 |

<div class="tip-box">
Klien memutuskan tindakan dari <b>kode status</b> dulu, baru membaca isi. Jangan membalas <code>200</code> dengan isi <code>{"error": ...}</code>.
</div>

---

## Kode Status yang Sering Dipakai

| Kode | Pakai saat |
|---|---|
| **200** OK | GET, PUT, PATCH berhasil |
| **201** Created | POST membuat resource baru, sertakan header `Location` |
| **204** No Content | DELETE berhasil, tanpa body |
| **400** Bad Request | request rusak (JSON tidak valid) |
| **401** Unauthorized | tidak ada identitas atau token tidak valid |
| **403** Forbidden | identitas valid tapi tidak boleh mengakses |
| **404** Not Found | resource tidak ada |
| **409** Conflict | bentrok dengan keadaan saat ini (data ganda, versi basi) |
| **422** Unprocessable | format benar, tapi isi gagal validasi |
| **429** Too Many Requests | terkena rate limit |

---

## 401 vs 403 vs 404

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
- Resource memang tidak ada
- Atau sengaja disembunyikan dari yang tidak berhak (artikel draft milik orang lain)

**422: isi salah**
- Validasi gagal, sertakan field mana yang salah

</div>
</div>

<div class="warn-box">
Menyamaratakan semuanya jadi "gagal" membuat klien tidak tahu harus apa: login ulang, memperbaiki input, atau menyerah.
</div>

---

## Bentuk Respons: Satu Resource dan Koleksi

```json
// GET /api/v1/articles/7
{
  "data": { "id": 7, "title": "Belajar REST", "status": "published" }
}

// GET /api/v1/articles
{
  "data": [ { "id": 7, "title": "Belajar REST" }, { "id": 8, "title": "Belajar JSON" } ],
  "links": { "next": "/api/v1/articles?page=2" },
  "meta": { "current_page": 1, "per_page": 15, "total": 42 }
}
```

- Pakai **bentuk yang sama** di semua endpoint: data di `data`, info tambahan di `meta` dan `links`
- Koleksi selalu array, walau kosong (`[]`), bukan `null`

---

## Konvensi Data di JSON

| Hal | Aturan | Contoh |
|---|---|---|
| Nama field | satu gaya saja, `snake_case` | `published_at` |
| Tanggal | ISO 8601, zona waktu jelas | `"2026-08-20T10:30:00Z"` |
| Uang | bilangan bulat satuan terkecil | `"price": 15000` |
| Boolean | `true` / `false`, bukan `"yes"` | `"is_active": true` |
| Kosong | `null` untuk "tidak ada nilai", tetap tampil | `"image": null` |
| ID | konsisten, jangan bocorkan urutan jika sensitif | `"id": 7` |

<div class="warn-box">
Uang jangan memakai desimal float (<code>0.1 + 0.2</code> tidak sama dengan <code>0.3</code>). Simpan dan kirim sebagai bilangan bulat.
</div>

---

## API Resource: Menyaring Apa yang Keluar

<div class="cols">
<div>

**Tanpa Resource**
```php
return Article::find($id);
```
Semua column keluar, termasuk yang internal (`user_id`, `deleted_at`) dan kolom baru yang kelak ditambahkan.

</div>
<div>

**Dengan Resource**
```php
return new ArticleResource($article);
```
Hanya field yang kamu pilih. Tabel boleh berubah, kontrak tetap.

</div>
</div>

```bash
php artisan make:resource ArticleResource
```

---

## API Resource: Kode dan Relasi

```php
class ArticleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'status' => $this->status,
            'published_at' => $this->published_at,
            'author' => new AuthorResource($this->whenLoaded('author')),
            'comments_count' => $this->whenCounted('comments'),
        ];
    }
}
```

- `whenLoaded()` memasukkan relasi **hanya kalau sudah di-load**, jadi tidak memicu N+1 diam-diam
- Koleksi: `ArticleResource::collection($articles)`. Paginator ikut menghasilkan `links` dan `meta`

---

## Pagination: Jangan Kirim Semuanya

| | Offset (`paginate`) | Cursor (`cursorPaginate`) |
|---|---|---|
| **Query** | `limit 15 offset 30` | `where id > 45 limit 15` |
| **Parameter** | `?page=3` | `?cursor=eyJpZCI6NDV9` |
| **Lompat ke halaman N** | bisa | tidak |
| **Data berubah saat dibaca** | bisa terlewat atau ganda | stabil |
| **Data sangat besar** | melambat (scan offset) | tetap cepat (butuh index) |

```php
return ArticleResource::collection(
    Article::latest('id')->paginate(15)->withQueryString()
);
```

<div class="tip-box">
Batasi juga <code>per_page</code> maksimal (misalnya 100), supaya klien tidak meminta 100.000 row sekaligus.
</div>

---

## Filter, Sort, dan Search lewat Query String

```text
GET /api/v1/articles?status=published&author_id=3&sort=-published_at&q=rest&per_page=20
```

```php
$articles = Article::query()
    ->when($request->status, fn ($q, $v) => $q->where('status', $v))
    ->when($request->author_id, fn ($q, $v) => $q->where('author_id', $v))
    ->when($request->q, fn ($q, $v) => $q->where('title', 'like', "%{$v}%"))
    ->orderBy(ltrim($sort, '-'), str_starts_with($sort, '-') ? 'desc' : 'asc')
    ->paginate(min($request->integer('per_page', 15), 100));
```

<div class="warn-box">
Daftarkan column yang boleh dipakai untuk sort (<code>in_array</code> ke daftar putih). Jangan memasukkan input klien langsung ke <code>orderBy()</code>.
</div>

---

## Format Galat yang Konsisten

Semua galat, dari endpoint mana pun, memakai bentuk yang sama.

```json
// 422: validasi gagal
{ "message": "The title field is required.",
  "errors": { "title": ["The title field is required."] } }

// 404: tidak ditemukan
{ "message": "Artikel tidak ditemukan." }
```

- `message`: ringkasan yang bisa dibaca manusia
- `errors`: per field, hanya untuk 422
- Jangan bocorkan stack trace atau nama tabel di produksi (`APP_DEBUG=false`)

<div class="ref-link">Standar lain yang lebih ketat: RFC 9457 (Problem Details for HTTP APIs)</div>

---

## Mengatur Galat 404 untuk API di Laravel

```php
// bootstrap/app.php
->withExceptions(function (Exceptions $exceptions): void {
    $exceptions->shouldRenderJsonWhen(
        fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
    );

    $exceptions->render(function (NotFoundHttpException $e, Request $request) {
        if ($request->is('api/*')) {
            return response()->json(['message' => 'Resource tidak ditemukan.'], 404);
        }
    });
})
```

- `shouldRenderJsonWhen`: galat di `api/*` selalu JSON, tidak pernah halaman HTML
- Route model binding yang gagal (`Article $article`) ikut menjadi 404 di sini

---

## Versioning: API Berubah, Klien Lama Jangan Rusak

| Perubahan | Merusak klien lama? |
|---|---|
| Menambah field di respons | tidak |
| Menambah endpoint baru | tidak |
| Menghapus atau mengganti nama field | **ya** |
| Mengubah tipe data (`"15000"` jadi `15000`) | **ya** |
| Menambah field wajib di request | **ya** |

```php
Route::prefix('v1')->group(function () {          // /api/v1/articles
    Route::apiResource('articles', ArticleController::class);
});
```

- Perubahan yang merusak = versi baru (`/api/v2`). Versi lama tetap hidup sampai klien pindah
- Umumkan penghentian lewat header `Deprecation` dan `Sunset`

---

## Performa: Respons yang Murah

| Teknik | Efek |
|---|---|
| `with('author')` | menghindari N+1 query saat relasi ikut dikirim |
| `paginate()` + batas `per_page` | ukuran respons terkendali |
| index pada column filter dan sort | query tidak scan seluruh tabel |
| `Cache-Control` / `ETag` | klien boleh memakai ulang respons (304 Not Modified) |
| kompresi (gzip) di web server | payload lebih kecil |

```php
return ArticleResource::collection(Article::with('author')->paginate(15));
```

<div class="tip-box">
Rancang respons dari kebutuhan klien: kalau klien mobile hanya butuh judul, jangan kirim seluruh isi artikel di daftar.
</div>

---

<!-- _class: divider -->

# Bagian 4
## Autentikasi, Otorisasi, dan Keamanan

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
Keduanya sama-sama membuktikan "siapa yang sedang request ini". Yang beda hanya cara bukti itu disimpan dan dikirim.
</div>

---

## Alur Autentikasi Sanctum

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
$token = $user->createToken('klien-mobile')->plainTextToken;
```

- Token disimpan **hash**-nya di tabel `personal_access_tokens`
- `plainTextToken` hanya terlihat **sekali**, saat dibuat. Klien wajib menyimpannya

---

## Endpoint Login

```php
public function login(Request $request): JsonResponse
{
    $data = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    $user = User::where('email', $data['email'])->first();

    if (! $user || ! Hash::check($data['password'], $user->password)) {
        return response()->json(['message' => 'Kredensial tidak valid.'], 401);
    }

    return response()->json([
        'token' => $user->createToken('klien-mobile')->plainTextToken,
    ]);
}
```

<div class="tip-box">
Pesan galat sengaja sama untuk email salah dan password salah, supaya penyerang tidak bisa mengetahui email mana yang terdaftar.
</div>

---

## Melindungi Route dengan `auth:sanctum`

```php
Route::post('/login', [AuthController::class, 'login']);         // publik

Route::middleware('auth:sanctum')->group(function () {           // wajib token
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('articles', ArticleController::class);
});
```

- Tanpa header `Authorization: Bearer <token>` yang valid: **401** sebelum sampai ke controller
- Pola sama seperti `role:admin` di Pertemuan 7, hanya buktinya token, bukan sesi

---

## Token Abilities: Izin per Token

Satu pengguna bisa punya beberapa token dengan izin berbeda.

```php
$user->createToken('laporan-bot', ['articles:read'])->plainTextToken;
$user->createToken('editor-app', ['articles:read', 'articles:write'])->plainTextToken;
```

```php
// bootstrap/app.php: daftarkan alias middleware
$middleware->alias(['abilities' => CheckAbilities::class, 'ability' => CheckForAnyAbility::class]);

// routes/api.php
Route::post('/articles', [ArticleController::class, 'store'])
    ->middleware(['auth:sanctum', 'abilities:articles:write']);
```

<div class="tip-box">
Token tanpa ability yang cukup ditolak dengan <b>403</b>. Beri izin sekecil mungkin: bot laporan tidak perlu bisa menulis.
</div>

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

- Policy dan role dari Pertemuan 7 dipakai ulang di API, tidak ditulis ulang
- Batasi query ke milik user: `$request->user()->articles()`, bukan `Article::find($id)` dari input klien

---

## Siklus Hidup Token

| Hal | Cara |
|---|---|
| Logout (cabut token ini) | `$request->user()->currentAccessToken()->delete()` |
| Cabut semua token | `$user->tokens()->delete()` |
| Kedaluwarsa | `'expiration' => 525600` (menit) di `config/sanctum.php`, atau argumen ke-3 `createToken()` |
| Bersihkan token basi | `php artisan sanctum:prune-expired --hours=24` (dijadwalkan harian) |

<div class="warn-box">
Secara default token Sanctum <b>tidak pernah kedaluwarsa</b>. Untuk aplikasi nyata, atur masa berlaku dan sediakan jalan bagi pengguna untuk mencabut token yang hilang.
</div>

---

## Rate Limiting: Melindungi dari Banjir Request

```php
// AppServiceProvider::boot()
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});
```

```php
Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () { /* ... */ });
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');   // 5 kali per menit
```

- Terlampaui: **429 Too Many Requests** dengan header `Retry-After`
- Kuncinya per user (atau IP kalau belum login), bukan satu batas untuk semua
- Login diberi batas lebih ketat untuk menahan tebak password

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
- Batasi `per_page` dan kolom yang boleh di-sort
- Jangan kembalikan model mentah (`password`, `remember_token`)
- CORS hanya untuk origin yang dikenal (`config/cors.php`)
- Pesan galat tidak membocorkan detail internal

</div>
</div>

<div class="ref-link">Laravel docs: <code>Sanctum</code>, <code>Routing &rarr; Rate Limiting</code>, dan <code>Routing &rarr; CORS</code></div>

---

<!-- _class: divider -->

# Bagian 5
## Dokumentasi, Pengujian, dan Konsumsi API

---

## OpenAPI: Kontrak, Bukan Catatan yang Cepat Basi

<div class="term-box">
<b>OpenAPI:</b> spesifikasi terstruktur (YAML atau JSON) yang mendeskripsikan endpoint, input, output, dan autentikasi. Bisa dibaca alat: dokumentasi interaktif, generator kode klien, validator.
</div>

```yaml
openapi: 3.0.0
info: { title: Blog API, version: 1.0.0 }
paths:
  /api/v1/articles:
    get:
      summary: Daftar artikel
      responses:
        '200': { description: Daftar artikel }
```

<div class="tip-box">
Catatan teks di README basi begitu satu field berganti nama. Format terstruktur bisa diperiksa alat otomatis.
</div>

---

## OpenAPI: Skema dan Keamanan

```yaml
paths:
  /api/v1/articles:
    post:
      security: [ { bearerAuth: [] } ]
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/ArticleInput' }
      responses:
        '201': { description: Dibuat }
        '401': { description: Token tidak valid }
        '422': { description: Validasi gagal }
components:
  securitySchemes:
    bearerAuth: { type: http, scheme: bearer }
  schemas:
    ArticleInput:
      type: object
      required: [title]
      properties:
        title: { type: string }
```

---

## Alur Kerja Contract-First

<div class="flow">
  <div class="box">Tulis kontrak</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Sepakati</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Implementasi</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Uji kontrak</div>
</div>

- Tim mobile dan backend bekerja paralel dari kontrak yang sama
- Perubahan kontrak jadi pembicaraan, bukan kejutan
- Kontrak ikut masuk repositori dan di-review seperti kode

<div class="tip-box">
Alat seperti Swagger UI membuat kontrak bisa dicoba langsung dari browser, tanpa menulis klien dulu.
</div>

---

## Menguji API di Laravel

```php
public function test_guest_cannot_create_article(): void
{
    $this->postJson('/api/v1/articles', ['title' => 'X'])
        ->assertUnauthorized();                                  // 401
}

public function test_create_article_validates_title(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', [])
        ->assertUnprocessable()                                  // 422
        ->assertJsonValidationErrors('title');
}

public function test_create_article_returns_created(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', ['title' => 'Belajar REST'])
        ->assertCreated()                                        // 201
        ->assertJsonPath('data.title', 'Belajar REST');
}
```

---

## Klien Wajib Memeriksa Status Sebelum Membaca Isi

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
Klien yang langsung membaca <code>$login->json('token')</code> tanpa memeriksa <code>failed()</code> gagal diam-diam: <code>$token</code> bernilai <code>null</code>, dan galatnya baru meledak di tempat yang membingungkan.
</div>

---

## Membedakan Jenis Galat dan Mengulang dengan Benar

```php
match ($response->status()) {
    201 => /* tersimpan, baca $response->json('data') */,
    401 => /* token tidak valid, login ulang */,
    422 => /* input ditolak, perbaiki input */,
    429 => /* terlalu sering, tunggu sesuai header Retry-After */,
    default => /* galat lain, tampilkan ke pengguna */,
};
```

| Jenis | Boleh diulang otomatis? |
|---|---|
| 4xx (kecuali 429) | tidak, request-nya yang salah |
| 429, 503 | ya, setelah jeda (`Retry-After`) |
| 5xx pada `GET` | ya, dengan jeda yang makin panjang (backoff) |
| 5xx pada `POST` | hanya kalau memakai idempotency key |

---

<!-- _class: divider -->

# Bagian 6
## Studi Kasus: Merancang API Blog dari Nol

---

## Langkah 1-2: Use Case dan Resource

**Kebutuhan:** aplikasi mobile blog. Pembaca melihat artikel dan komentar. Penulis menulis dan menerbitkan artikel. Pembaca yang login boleh berkomentar.

| Use case | Siapa | Resource |
|---|---|---|
| Lihat daftar dan detail artikel | siapa saja | `articles` |
| Tulis, ubah, hapus artikel | penulis (pemilik) | `articles` |
| Terbitkan artikel | penulis (pemilik) | status pada `articles` |
| Lihat dan tulis komentar | lihat: siapa saja, tulis: pengguna login | `comments` (anak `articles`) |
| Masuk dan keluar | pengguna | `login`, `logout` |

---

## Langkah 3: Daftar Endpoint

| Method + URL | Auth | Sukses | Galat |
|---|---|---|---|
| `POST /api/v1/login` | publik | 200 | 401, 422, 429 |
| `GET /api/v1/articles` | publik | 200 | 429 |
| `GET /api/v1/articles/{id}` | publik | 200 | 404 |
| `POST /api/v1/articles` | token | 201 | 401, 403, 422 |
| `PATCH /api/v1/articles/{id}` | pemilik | 200 | 401, 403, 404, 422 |
| `DELETE /api/v1/articles/{id}` | pemilik | 204 | 401, 403, 404 |
| `GET /api/v1/articles/{id}/comments` | publik | 200 | 404 |
| `POST /api/v1/articles/{id}/comments` | token | 201 | 401, 404, 422 |

---

## Langkah 4: Bentuk Representasi

<div class="cols">
<div>

**Artikel (detail)**
```json
{
  "data": {
    "id": 7,
    "title": "Belajar REST",
    "body": "Isi artikel...",
    "status": "published",
    "published_at": "2026-08-20T10:30:00Z",
    "author": { "id": 3, "name": "Sari" },
    "comments_count": 12
  }
}
```

</div>
<div>

**Komentar**
```json
{
  "data": {
    "id": 31,
    "body": "Tulisan bagus",
    "created_at": "2026-08-21T08:00:00Z",
    "user": { "id": 9, "name": "Budi" }
  }
}
```

- Daftar artikel: tanpa `body` (hemat payload)
- Tidak ada `password`, `email`, atau `user_id` mentah

</div>
</div>

---

## Langkah 5: Parameter Daftar

```text
GET /api/v1/articles?status=published&author_id=3&q=rest&sort=-published_at&per_page=20&page=2
```

| Parameter | Arti | Aturan |
|---|---|---|
| `status` | filter status | `draft` hanya terlihat oleh penulisnya |
| `author_id` | filter penulis | integer yang ada |
| `q` | cari di judul | min 2 huruf |
| `sort` | urutan | daftar putih: `published_at`, `title`; awalan `-` = menurun |
| `per_page` | ukuran halaman | default 15, maksimal 100 |

---

## Langkah 6: Galat dan Keamanan

| Situasi | Status | Isi |
|---|---|---|
| Body POST artikel tanpa `title` | 422 | `message` + `errors.title` |
| Artikel 999 tidak ada | 404 | `message` |
| Token tidak dikirim | 401 | `message` |
| Mengubah artikel milik penulis lain | 403 | `message` |
| Melihat draft milik orang lain | 404 | disembunyikan, bukan 403 |
| Lebih dari 60 request per menit | 429 | `Retry-After` |

- Rate limit `throttle:api`, login lebih ketat
- Token punya ability `articles:write` untuk operasi tulis
- Semua POST/PATCH memakai `validate()` atau Form Request

---

## Langkah 7: Kontrak dan Versi

```yaml
paths:
  /api/v1/articles/{id}/comments:
    post:
      summary: Tambah komentar
      security: [ { bearerAuth: [] } ]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [body]
              properties:
                body: { type: string, maxLength: 500 }
      responses:
        '201': { description: Komentar dibuat }
        '401': { description: Token tidak valid }
        '404': { description: Artikel tidak ada }
        '422': { description: Validasi gagal }
```

- Semua route di bawah `/api/v1`. Perubahan yang merusak = `/api/v2`

---

## Checklist Review Desain API (1/2)

**Resource, URL, dan respons**

- URL kata benda jamak, tanpa kata kerja
- Method sesuai makna (aman, idempotent)
- Nesting maksimal 2 tingkat
- Aksi non-CRUD dimodelkan sebagai status atau sub-resource
- Kode status tepat, bukan selalu 200
- Bentuk sukses dan galat konsisten
- Koleksi dipaginasi dengan batas

---

## Checklist Review Desain API (2/2)

<div class="cols">
<div>

**Keamanan**
- Autentikasi dan otorisasi terpisah (401 vs 403)
- Cek kepemilikan resource
- Rate limit dan HTTPS

</div>
<div>

**Evolusi dan dokumentasi**
- Ada prefix versi
- Kontrak OpenAPI ikut di repositori
- Ada test untuk 401, 403, 422, dan jalur sukses

</div>
</div>

---

<!-- _class: divider -->

# Bagian 7
## AJAX: Halaman Sendiri Memanggil Endpoint JSON

---

## Apa Itu AJAX?

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

Di jobsheet, kamu menerapkan konsep ini pada Simple POS:

1. Memasang Sanctum, endpoint `POST /api/login`, dan token
2. Endpoint produk dan transaksi dengan API Resource, 401 dan 422
3. Merapikan desain: prefix versi, pagination, filter, dan format galat konsisten
4. Klien HTTP sungguhan dan dokumentasi OpenAPI
5. Satu fitur AJAX kecil pada halaman web: form yang mengirim JSON lewat `fetch`

<div class="ref-link">Kode lengkap: <code>github.com/se-polinema/simple-pos-ch09</code></div>

---

## Rangkuman (1/4): Proses Desain, Resource, dan URL

- Rancang dari use case: cari kata benda, petakan ke operasi, baru tulis kode
- URL kata benda jamak, method HTTP sebagai kata kerja, nesting maksimal 2 tingkat
- `GET`, `PUT`, `DELETE` aman diulang. `POST` tidak, kecuali memakai idempotency key
- Aksi non-CRUD dimodelkan sebagai perubahan status atau sub-resource

---

## Rangkuman (2/4): Merancang Respons

- Kode status memberi tahu klien tindakan berikutnya: 201, 204, 401, 403, 404, 422, 429
- Bentuk JSON konsisten: `data`, `meta`, `links`. Galat selalu `message` dan `errors`
- API Resource menyaring field. `paginate` atau `cursorPaginate` dengan batas `per_page`
- Filter dan sort lewat query string dengan daftar putih. Prefix versi untuk perubahan yang merusak

---

## Rangkuman (3/4): Keamanan, Dokumentasi, dan Pengujian

- Sanctum: `createToken()`, header `Authorization: Bearer`, middleware `auth:sanctum`
- Abilities membatasi token, policy membatasi aksi, `throttle` membatasi frekuensi
- Atur masa berlaku token dan sediakan pencabutan
- OpenAPI sebagai kontrak, dites dengan `getJson`, `postJson`, dan `Sanctum::actingAs`
- Klien memeriksa status sebelum membaca isi, dan hanya mengulang galat yang memang boleh diulang

---

## Rangkuman (4/4): AJAX

- AJAX dari halaman sendiri memakai route di `web.php` dengan sesi cookie, bukan `api.php` dengan token
- Setiap POST/PUT/PATCH/DELETE sebaiknya membawa token CSRF lewat header `X-CSRF-TOKEN` (dari `<meta name="csrf-token">`), karena tanpa itu bisa 419
- Header `Accept: application/json` membuat `validate()` membalas 422 JSON, bukan 302 redirect
- Klien memeriksa `res.status`: 201 berhasil, 422 tampilkan galat per field, 401/419 sesi habis
- Nonaktifkan tombol selama request berjalan supaya data tidak tersimpan dobel

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Sanctum, Eloquent API Resources, Pagination, Routing, CSRF Protection, Validation), spesifikasi OpenAPI, RFC 9457, dan makalah Fielding tentang prinsip arsitektur REST

Kode lengkap: `github.com/se-polinema/simple-pos-ch09`

**Pertemuan berikutnya:** awal proyek PBL (Project Based Learning), kamu akan merencanakan fitur dan arsitektur proyek webmu sendiri
