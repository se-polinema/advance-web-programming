# Rencana Konten: Bab 6 - Validasi dan Keamanan Input

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** konsep validasi dan keamanan input + praktik FormRequest pada form produk dan transaksi Simple POS.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Menulis `FormRequest` untuk memvalidasi input produk dan transaksi Simple POS, termasuk aturan validasi kustom
2. Menjelaskan mengapa total transaksi dan subtotal detail transaksi wajib dihitung di sisi server, bukan diterima langsung dari input klien
3. Menangani pesan error validasi dan flash message pada form Blade Simple POS agar pengguna mendapat umpan balik yang jelas saat input ditolak

---

## Struktur Bab (Compact)

### Session 1: FormRequest dan Aturan Validasi (7-9 halaman)

#### 1.1 FormRequest dan Aturan Validasi
- Memisahkan aturan validasi dari controller lewat kelas `FormRequest`
- Aturan bawaan (`required`, `numeric`, `exists`) dan aturan kustom sederhana

**Kotak Berwarna:**
- **istilahpenting**: FormRequest, Validasi, Sanitasi, Flash Message

**Code Listings / Perintah CLI:**
```bash
php artisan make:request StoreTransactionRequest
```

---

### Session 2: Total di Server dan Pengalaman Form (7-9 halaman)

#### 2.1 Mengapa Total Dihitung di Server
- Risiko menerima total langsung dari input klien (keranjang Alpine.js Bab 3)
- Menghitung ulang subtotal dan total dari harga produk di basis data, bukan dari payload

#### 2.2 Praktik: Validasi Form Produk dan Transaksi
- Menulis `FormRequest` untuk form produk dan form transaksi
- Menampilkan pesan error dan flash message pada Blade

**Kotak Berwarna:**
- **warningbox**: bahaya mempercayai nilai total dari input klien secara langsung

---

## Estimasi Halaman

- **Session 1**: FormRequest dan aturan validasi - 7-9 halaman
- **Session 2**: Total di server dan pengalaman form - 7-9 halaman

**Total: 14-18 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram alur validasi: request masuk -> FormRequest -> controller -> respons error/sukses

**Tables (1 esensial):**
1. Daftar aturan validasi dipakai pada form produk dan transaksi

**Code Listings / Perintah:**
- Definisi `rules()` pada `FormRequest`
- Perhitungan total di controller/service, bukan dari input

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | FormRequest dan aturan validasi | 7-9 | lecture/demo |
| 2 | Total di server, validasi form Simple POS | 7-9 | hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: FormRequest, aturan validasi, perhitungan total di server
2. **Should-have**: penanganan pesan error pada Blade
3. **Nice-to-have**: aturan validasi kustom lanjutan (mis. validasi stok mencukupi)

**Fokus Praktik:**
- 45% teori (mengapa validasi dan perhitungan server penting)
- 55% praktik (menulis FormRequest, uji form)

**Tone:**
- Formal namun mudah diakses
- Tunjukkan konsekuensi nyata (stok minus, total dimanipulasi) sebagai alasan validasi ketat

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-06`, dibuat dari `chapter-05`
- Perubahan/berkas baru: `StoreProductRequest`, `StoreTransactionRequest`, perhitungan total server-side

**Latihan:**
- 3-4 latihan: tambah aturan validasi baru, uji form dengan input tidak valid, jelaskan risiko total dari klien
- `challengebox`: menambah validasi stok mencukupi sebelum transaksi disimpan

---

**Status: DRAFT - Belum Ditulis**
