# Rencana Konten: Bab 11 - Optimasi, Deployment, dan Dokumentasi

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** profiling performa lanjutan pada data skala Bab 4-5 + praktik persiapan deployment dan dokumentasi teknis.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Memprofilkan query N+1 dan query tanpa index pada Simple POS memakai `EXPLAIN QUERY PLAN`, lalu mengukur perbaikannya setelah eager loading dan index ditambahkan
2. Menyiapkan Simple POS untuk deployment (konfigurasi environment produksi, migrasi, caching konfigurasi dan route)
3. Menyusun dokumentasi teknis ringkas yang menjelaskan keputusan arsitektur Simple POS bagi pengembang lain yang melanjutkan proyek

---

## Struktur Bab (Compact)

### Session 1: Profiling Query N+1 dan Index (7-9 halaman)

#### 1.1 Memprofilkan Query N+1 dan Index
- Mengulang kasus N+1 dari Bab 5 dan kasus index FK dari Bab 4 sebagai studi profiling menyeluruh
- Mengukur jumlah query dan waktu eksekusi sebelum/sesudah perbaikan

**Kotak Berwarna:**
- **istilahpenting**: Profiling, Query Cache, Route Cache, Config Cache

---

### Session 2: Deployment dan Dokumentasi Teknis (7-9 halaman)

#### 2.1 Menyiapkan Deployment
- Perbedaan environment lokal vs produksi (`.env` produksi, `APP_DEBUG=false`)
- `php artisan config:cache`, `php artisan route:cache`, `php artisan migrate --force`

#### 2.2 Praktik: Dokumentasi Teknis Simple POS
- Menyusun ringkasan arsitektur (skema, alur autentikasi, endpoint API) untuk pengembang baru
- Mendokumentasikan keputusan desain (mengapa SQLite, mengapa middleware kustom, dsb.)

**Kotak Berwarna:**
- **warningbox**: risiko men-deploy dengan `APP_DEBUG=true` (kebocoran informasi sensitif)

---

## Estimasi Halaman

- **Session 1**: Profiling query N+1 dan index - 7-9 halaman
- **Session 2**: Deployment dan dokumentasi teknis - 7-9 halaman

**Total: 14-18 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram sebelum/sesudah: jumlah query dan waktu eksekusi pada listing transaksi

**Tables (1 esensial):**
1. Checklist kesiapan deployment (konfigurasi, cache, migrasi)

**Code Listings / Perintah:**
- Perintah `php artisan config:cache`, `route:cache`, `migrate --force`
- Query `EXPLAIN QUERY PLAN` sebelum/sesudah index

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Profiling N+1 dan index | 7-9 | lecture/demo |
| 2 | Deployment dan dokumentasi teknis | 7-9 | hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: profiling N+1/index, checklist deployment, dokumentasi teknis ringkas
2. **Should-have**: perbandingan angka performa sebelum/sesudah
3. **Nice-to-have**: pengenalan singkat monitoring produksi

**Fokus Praktik:**
- 45% teori (mengapa profiling dan dokumentasi penting)
- 55% praktik (perintah cache, penyusunan dokumentasi)

**Tone:**
- Formal namun mudah diakses
- Pakai angka konkret dari data seed Bab 4 sebagai bukti perbaikan performa

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-11`, dibuat dari `chapter-10`
- Perubahan/berkas baru: `README` deployment ringkas, catatan keputusan arsitektur

**Latihan:**
- 3-4 latihan: profilkan satu query lain, siapkan checklist deployment versi sendiri, tulis satu halaman dokumentasi arsitektur
- `challengebox`: mengukur perbaikan performa pada endpoint laporan Bab 8 setelah index ditambahkan

---

**Status: DRAFT - Belum Ditulis**
