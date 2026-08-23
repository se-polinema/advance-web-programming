# Rencana Konten: Bab 5 - Eloquent ORM dan Relasi

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** konsep relasi Eloquent + praktik eager loading dan paginasi pada data skala nyata dari Bab 4.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Memetakan relasi `hasOne`, `hasMany`, `belongsTo`, dan `belongsToMany` ke empat model Simple POS (`Category`, `Product`, `Transaction`, `TransactionDetail`)
2. Menggunakan eager loading (`with()`) untuk menghindari masalah N+1 query saat menampilkan daftar transaksi beserta detail dan produknya
3. Menerapkan `paginate()` pada listing 300 produk dan 2.500 transaksi, dan membuktikan bahwa halaman kedua benar-benar mengembalikan baris berbeda dari halaman pertama

---

## Struktur Bab (Compact)

### Session 1: Relasi Eloquent dan Eager Loading (7-9 halaman)

#### 1.1 Relasi Eloquent pada Model Simple POS
- `Category::hasMany(Product)`, `Product::belongsTo(Category)`
- `Transaction::hasMany(TransactionDetail)`, `TransactionDetail::belongsTo(Product)`

#### 1.2 Eager Loading dan Masalah N+1
- Query N+1: satu query daftar + N query tambahan per baris
- `with('details.product')` sebagai solusi lazy vs eager loading

**Kotak Berwarna:**
- **istilahpenting**: Relasi, Eager Loading, N+1, Lazy Loading, Paginasi

**Code Listings / Perintah CLI:**
```bash
php artisan tinker
```

**Cuplikan kode inline** (maks. ~15 baris):
```php
$transactions = Transaction::with('details.product')->latest()->paginate(15);
```

---

### Session 2: Paginasi pada Skala Nyata (7-9 halaman)

#### 2.1 Praktik: Paginasi pada Data Skala Nyata
- `paginate(10)` pada 300 produk, `paginate(15)` pada 2.500 transaksi
- Membuktikan halaman 2 mengembalikan baris berbeda dari halaman 1 (verifikasi manual)

**Kotak Berwarna:**
- **tipbox**: kapan `paginate()` lebih tepat dibanding `get()` biasa

---

## Estimasi Halaman

- **Session 1**: Relasi Eloquent dan eager loading - 7-9 halaman
- **Session 2**: Paginasi pada skala nyata - 7-9 halaman

**Total: 14-18 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram relasi antar keempat model (mirip ERD Bab 4, versi Eloquent)

**Tables (1 esensial):**
1. Perbandingan jumlah query: lazy loading vs eager loading pada daftar transaksi

**Code Listings / Perintah:**
- Definisi relasi pada model (`hasMany`, `belongsTo`)
- Query dengan `with()` dan `paginate()`

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Relasi Eloquent, eager loading | 7-9 | lecture/demo |
| 2 | Paginasi pada data skala nyata | 7-9 | hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: relasi keempat model, eager loading, paginasi
2. **Should-have**: perbandingan jumlah query lazy vs eager
3. **Nice-to-have**: relasi `belongsToMany` pada skenario tambahan (mis. varian produk)

**Fokus Praktik:**
- 45% teori (relasi, N+1)
- 55% praktik (query eager loading, paginasi)

**Tone:**
- Formal namun mudah diakses
- Pakai data seed Bab 4 sebagai bukti konkret, bukan contoh rekaan kecil

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-05`, dibuat dari `chapter-04`
- Perubahan/berkas baru: definisi relasi pada model, query listing dengan `with()` dan `paginate()`

**Latihan:**
- 3-4 latihan: hitung jumlah query sebelum/sesudah eager loading, tambah relasi baru, uji `paginate()` pada endpoint lain
- `challengebox`: menulis query yang menampilkan lima produk terlaris memakai relasi dan agregasi

---

**Status: DRAFT - Belum Ditulis**
