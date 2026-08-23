# Rencana Konten: Bab 10 - Pengujian dan Kualitas Aplikasi

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** anatomi test fitur Simple POS yang sudah ada + praktik checklist milestone sebagai gerbang kualitas sebelum lanjut ke bab berikutnya.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Menjelaskan cakupan 13 test fitur Simple POS (login/logout, otorisasi peran, transaksi POS, alur token API) dan apa yang divalidasi tiap kelompok test
2. Menjalankan `php artisan test` dan menafsirkan hasil 27 assertion untuk menentukan apakah sebuah perubahan kode memecahkan perilaku yang sudah ada
3. Menyusun checklist milestone untuk memverifikasi bahwa CRUD, autentikasi, dan otorisasi Simple POS berfungsi sebelum lanjut ke bab berikutnya

---

## Struktur Bab (Compact)

### Session 1: Anatomi Test Fitur Simple POS (7-9 halaman)

#### 1.1 Anatomi Test Fitur Simple POS
- Empat kelompok test: autentikasi, otorisasi berbasis peran, transaksi POS (dekremen stok dan total), alur token API
- Struktur test fitur Laravel: `RefreshDatabase`, `actingAs()`, assertion HTTP

**Kotak Berwarna:**
- **istilahpenting**: Feature Test, Assertion, RefreshDatabase, Regresi

---

### Session 2: Menjalankan Test dan Checklist Milestone (7-9 halaman)

#### 2.1 Menjalankan dan Menafsirkan Hasil Test
- Membaca output `php artisan test`: hijau vs merah, jumlah assertion
- Test yang gagal setelah perubahan kode sebagai sinyal regresi

#### 2.2 Praktik: Checklist Milestone Sebelum Lanjut
- Menyusun checklist manual: CRUD produk berjalan, login/logout berjalan, kasir diblokir dari halaman admin, transaksi mendekremen stok dengan benar

**Kotak Berwarna:**
- **tipbox**: menjalankan test sebelum dan sesudah setiap perubahan signifikan

---

## Estimasi Halaman

- **Session 1**: Anatomi test fitur Simple POS - 7-9 halaman
- **Session 2**: Menjalankan test dan checklist milestone - 7-9 halaman

**Total: 14-18 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram alur satu test fitur: setup data -> aksi (request) -> assertion

**Tables (1 esensial):**
1. Ringkasan 13 test fitur Simple POS per kelompok

**Code Listings / Perintah:**
- Struktur satu test fitur (`test_kasir_cannot_access_admin_pages`)
- Perintah `php artisan test` dan opsi filter test

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Anatomi test fitur Simple POS | 7-9 | lecture/demo |
| 2 | Menjalankan test, checklist milestone | 7-9 | hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: anatomi test fitur, menjalankan `php artisan test`, checklist milestone
2. **Should-have**: contoh test yang sengaja dibuat gagal untuk menunjukkan regresi
3. **Nice-to-have**: pengenalan singkat test unit di luar test fitur

**Fokus Praktik:**
- 40% teori (anatomi test, arti assertion)
- 60% praktik (menjalankan test, menyusun checklist)

**Tone:**
- Formal namun mudah diakses
- Pakai test yang benar-benar ada di Simple POS sebagai contoh, bukan test rekaan

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-10`, dibuat dari `chapter-09`
- Perubahan/berkas baru: tidak ada test baru wajib; bab ini membaca test yang sudah ada sejak increment 1-7

**Latihan:**
- 3-4 latihan: jalankan test dan baca hasilnya, buat satu test gagal dengan sengaja untuk memahami output, tulis checklist milestone versi sendiri
- `challengebox`: menulis satu test fitur baru untuk endpoint laporan Bab 8

---

**Status: DRAFT - Belum Ditulis**
