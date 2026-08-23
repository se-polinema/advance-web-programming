# Rencana Konten: Bab 9 - Merancang dan Membangun REST API

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 16-20 halaman
> **Pendekatan:** konsep desain REST API + praktik autentikasi token Sanctum dan dokumentasi OpenAPI untuk Simple POS.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Merancang endpoint REST API Simple POS (`POST /api/login`, `GET /api/products`, `POST /api/transactions`) mengikuti semantik HTTP method secara konsisten
2. Mengimplementasikan autentikasi berbasis token dengan Laravel Sanctum untuk klien kasir mobile, termasuk header `Authorization: Bearer`
3. Mendokumentasikan API Simple POS memakai spesifikasi OpenAPI agar kontrak endpoint dapat dipakai tim frontend atau mobile lain tanpa membaca kode controller

---

## Struktur Bab (Compact)

### Session 1: Merancang Endpoint dan Autentikasi Token (8-10 halaman)

#### 1.1 Merancang Endpoint REST API Simple POS
- Prinsip semantik HTTP method (GET aman/idempoten, POST mengubah state)
- Struktur respons JSON konsisten untuk sukses dan galat

#### 1.2 Autentikasi Token dengan Sanctum
- `POST /api/login` mengembalikan token Sanctum
- Middleware `auth:sanctum` melindungi endpoint produk dan transaksi
- Header `Authorization: Bearer <token>` pada setiap request terproteksi

**Kotak Berwarna:**
- **istilahpenting**: REST, Endpoint, Token, Sanctum, API Resource

**Code Listings / Perintah CLI:**
```bash
curl -X POST http://127.0.0.1:8000/api/login -d "email=kasir@pos.test&password=password"
```

---

### Session 2: Dokumentasi API dengan OpenAPI (8-10 halaman)

#### 2.1 Praktik: Mendokumentasikan API dengan OpenAPI
- Struktur dasar berkas spesifikasi OpenAPI (paths, method, request/response schema)
- Mendokumentasikan `POST /api/login`, `GET /api/products`, `POST /api/transactions`

**Kotak Berwarna:**
- **tipbox**: memakai dokumentasi OpenAPI sebagai kontrak yang diuji, bukan sekadar catatan

---

## Estimasi Halaman

- **Session 1**: Merancang endpoint dan autentikasi token - 8-10 halaman
- **Session 2**: Dokumentasi API dengan OpenAPI - 8-10 halaman

**Total: 16-20 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram alur token: login -> terima token -> request terproteksi dengan header Authorization

**Tables (1 esensial):**
1. Ringkasan endpoint API Simple POS (method, path, autentikasi)

**Code Listings / Perintah:**
- Definisi route API pada `routes/api.php`
- Contoh permintaan `curl` ke endpoint terproteksi

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Desain endpoint, autentikasi Sanctum | 8-10 | lecture/demo |
| 2 | Dokumentasi API dengan OpenAPI | 8-10 | hands-on |

**Total: ~16-20 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: endpoint login/products/transactions, autentikasi Sanctum, dokumentasi OpenAPI dasar
2. **Should-have**: struktur respons galat yang konsisten
3. **Nice-to-have**: versi API (`/api/v1`) sebagai pertimbangan desain lanjutan

**Fokus Praktik:**
- 45% teori (prinsip desain REST, semantik HTTP)
- 55% praktik (implementasi Sanctum, dokumentasi OpenAPI)

**Tone:**
- Formal namun mudah diakses
- Bingkai setiap konsep sebagai "cara kerja REST API pada umumnya", bukan trivia khusus Laravel/Sanctum

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-09`, dibuat dari `chapter-08`
- Perubahan/berkas baru: `routes/api.php`, `AuthController`, `ProductController`/`TransactionController` versi API

**Latihan:**
- 3-4 latihan: uji endpoint dengan `curl`, tambah endpoint baru, lengkapi dokumentasi OpenAPI untuk endpoint tambahan
- `challengebox`: menambah endpoint `GET /api/transactions/{id}` beserta dokumentasinya

---

**Status: DRAFT - Belum Ditulis**
