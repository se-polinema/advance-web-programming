# Rencana Konten: Bab 4 - Desain Basis Data, Migrasi, dan Seeding

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 16-20 halaman
> **Pendekatan:** desain skema + praktik seeding skala nyata dan investigasi performa lewat `EXPLAIN QUERY PLAN`.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Merancang skema basis data Simple POS (`categories`, `products`, `transactions`, `transaction_details`) beserta relasinya
2. Menulis migrasi dan seeder skala nyata (300 produk, 2.500 transaksi) memakai bulk insert lewat `DB::table()->insert()` dalam batch, bukan `Model::create()` satu per satu
3. Menjelaskan mengapa `constrained()` pada SQLite tidak otomatis membuat index pada kolom foreign key, dampaknya pada query listing produk, dan cara memverifikasinya dengan `EXPLAIN QUERY PLAN`

---

## Struktur Bab (Compact)

### Session 1: Merancang Skema dan Migrasi (8-10 halaman)

#### 1.1 Merancang Skema Simple POS
- Empat tabel inti dan relasinya: `categories` 1--* `products` 1--* `transaction_details` *--1 `transactions` *--1 `users`
- Kolom kunci: `products.stock`, `transactions.total`, `transaction_details.subtotal`

**Diagram:**
- Diagram entitas-relasi (ERD) keempat tabel inti

**Tabel komparasi (jika relevan):**
| Tabel | Kolom Utama |
|---|---|
| `categories` | `id`, `name` |
| `products` | `id`, `category_id` (fk), `name`, `price`, `stock` |
| `transactions` | `id`, `user_id` (fk), `total`, `created_at` |
| `transaction_details` | `id`, `transaction_id` (fk), `product_id` (fk), `qty`, `subtotal` |

**Kotak Berwarna:**
- **istilahpenting**: Migrasi, Skema, Foreign Key, Index, Seeder

---

### Session 2: Seeding Skala Nyata dan Index (8-10 halaman)

#### 2.1 Migrasi dan Seeding Skala Nyata
- Mengapa bulk insert (`DB::table(...)->insert($chunk)` dalam batch) dipakai, bukan `Model::create()` per baris
- Membungkus insert transaksi + detail dalam satu `DB::transaction()`

#### 2.2 Praktik: Index Foreign Key dan EXPLAIN QUERY PLAN
- `constrained()` di SQLite hanya menambah constraint, bukan index
- Menambahkan `$table->index(...)` eksplisit pada kolom foreign key dan `transactions.created_at`
- Membaca hasil `EXPLAIN QUERY PLAN`: `SEARCH ... USING INDEX` vs `SCAN` (full table scan)

**Code Listings / Perintah CLI:**
```bash
php artisan migrate:fresh --seed
sqlite3 database/database.sqlite "EXPLAIN QUERY PLAN SELECT * FROM transactions WHERE created_at BETWEEN ? AND ?;"
```

**Kotak Berwarna:**
- **warningbox**: dampak full table scan pada tabel berisi ribuan baris

---

## Estimasi Halaman

- **Session 1**: Merancang skema dan migrasi - 8-10 halaman
- **Session 2**: Seeding skala nyata dan index - 8-10 halaman

**Total: 16-20 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram entitas-relasi (ERD) `categories`-`products`-`transactions`-`transaction_details`

**Tables (2 esensial):**
1. Skema kolom keempat tabel inti
2. Volume data seed (produk, transaksi, detail transaksi)

**Code Listings / Perintah:**
- Migrasi dengan `$table->foreignId()->constrained()` dan `$table->index(...)`
- Seeder dengan bulk insert batch

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Skema dan migrasi Simple POS | 8-10 | lecture/demo |
| 2 | Seeding skala nyata, index, EXPLAIN QUERY PLAN | 8-10 | hands-on |

**Total: ~16-20 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: skema empat tabel, migrasi, seeder bulk insert, index FK eksplisit
2. **Should-have**: pembacaan `EXPLAIN QUERY PLAN`
3. **Nice-to-have**: perbandingan performa sebelum/sesudah index secara kuantitatif

**Fokus Praktik:**
- 40% teori (desain skema, alasan index)
- 60% praktik (migrasi, seeding, verifikasi index)

**Tone:**
- Formal namun mudah diakses
- Tunjukkan bug performa nyata (index FK) sebagai pelajaran konkret, bukan trivia abstrak

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-04`, dibuat dari `chapter-03`
- Perubahan/berkas baru: migrasi keempat tabel, `DatabaseSeeder.php` dengan bulk insert

**Latihan:**
- 3-4 latihan: tambah index pada kolom lain, jalankan `EXPLAIN QUERY PLAN` pada query listing sendiri, hitung ulang skala data
- `challengebox`: menambah kolom baru pada `products` beserta migrasinya

---

**Status: DRAFT - Belum Ditulis**
