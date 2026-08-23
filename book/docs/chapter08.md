# Rencana Konten: Bab 8 - Pengolahan Data: Impor, Ekspor, dan Antrean

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 16-20 halaman
> **Pendekatan:** konsep pengolahan data berskala + praktik laporan, ekspor/impor CSV, dan diskusi kapan memakai antrean.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Menyusun halaman laporan penjualan Simple POS dengan filter rentang tanggal dan total penjualan yang dihitung dari data transaksi
2. Mengekspor laporan penjualan ke CSV dan mengimpor data produk dari berkas CSV, termasuk penanganan galat pada baris yang tidak valid
3. Menjelaskan kapan pemrosesan data sebaiknya dipindah ke antrean (queue) alih-alih dijalankan langsung pada siklus request, memakai contoh impor produk berskala besar pada Simple POS

---

## Struktur Bab (Compact)

### Session 1: Laporan dan Ekspor/Impor CSV (8-10 halaman)

#### 1.1 Laporan Penjualan dan Filter Tanggal
- `ReportController@index` dengan filter `whereBetween` pada `transactions.created_at`
- Menghitung total penjualan dari agregasi `transaction_details`

#### 1.2 Ekspor dan Impor CSV
- `ReportController@export` menghasilkan berkas CSV
- `ReportController@import` membaca CSV dan membuat/memperbarui produk
- Menangani baris CSV yang tidak valid tanpa menghentikan seluruh proses impor

**Kotak Berwarna:**
- **istilahpenting**: ETL, Batch Processing, Antrean (Queue), Import/Export

**Code Listings / Perintah CLI:**
```bash
php artisan queue:work
```

---

### Session 2: Kapan Memakai Antrean (8-10 halaman)

#### 2.1 Praktik: Kapan Memakai Antrean
- Batas wajar memproses data langsung pada siklus request vs memindahkannya ke job antrean
- Simulasi impor produk berskala besar sebagai kandidat job antrean

**Tabel komparasi:**
| Pendekatan | Waktu Respons Pengguna | Cocok Untuk |
|---|---|---|
| Proses langsung (request) | Menunggu hingga selesai | Impor kecil, < beberapa ratus baris |
| Job antrean | Instan, hasil diproses di latar belakang | Impor besar, laporan berat, kirim email massal |

**Kotak Berwarna:**
- **tipbox**: tanda-tanda sebuah proses sebaiknya dipindah ke antrean

---

## Estimasi Halaman

- **Session 1**: Laporan dan ekspor/impor CSV - 8-10 halaman
- **Session 2**: Kapan memakai antrean - 8-10 halaman

**Total: 16-20 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram alur impor CSV: unggah -> parsing -> validasi baris -> simpan/lewati

**Tables (1 esensial):**
1. Perbandingan proses langsung vs job antrean

**Code Listings / Perintah:**
- Query agregasi laporan penjualan dengan filter tanggal
- Struktur parsing CSV dan penanganan baris tidak valid

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Laporan penjualan, ekspor/impor CSV | 8-10 | lecture/demo |
| 2 | Diskusi dan praktik kapan memakai antrean | 8-10 | hands-on |

**Total: ~16-20 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: laporan dengan filter tanggal, ekspor CSV, impor CSV dengan penanganan galat
2. **Should-have**: kriteria kapan memakai antrean
3. **Nice-to-have**: implementasi job antrean penuh untuk impor produk

**Fokus Praktik:**
- 40% teori (ETL, kapan memakai antrean)
- 60% praktik (laporan, ekspor, impor)

**Tone:**
- Formal namun mudah diakses
- Pakai angka nyata dari volume data seed Bab 4 sebagai konteks skala

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-08`, dibuat dari `chapter-07`
- Perubahan/berkas baru: `ReportController` (index, export, import), halaman laporan Blade

**Latihan:**
- 3-4 latihan: ubah filter laporan, uji impor dengan CSV berisi baris tidak valid, identifikasi proses lain di Simple POS yang layak jadi job antrean
- `challengebox`: menambah kolom ringkasan produk terlaris pada laporan

---

**Status: DRAFT - Belum Ditulis**
