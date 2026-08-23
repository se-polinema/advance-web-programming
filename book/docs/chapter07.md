# Rencana Konten: Bab 7 - Autentikasi, Otorisasi, dan RBAC

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** konsep autentikasi vs otorisasi + praktik middleware peran kustom pada Simple POS.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Mengimplementasikan login dan logout Simple POS memakai sistem autentikasi bawaan Laravel, termasuk akun demo admin dan kasir
2. Menulis middleware `role:admin` kustom untuk membatasi akses halaman produk, kategori, dan laporan hanya untuk peran admin
3. Membandingkan pendekatan RBAC manual (middleware kustom) pada Simple POS dengan paket seperti Laravel Breeze dan Spatie Permission, serta kapan masing-masing lebih sesuai dipakai

---

## Struktur Bab (Compact)

### Session 1: Autentikasi dan Sesi Pengguna (7-9 halaman)

#### 1.1 Autentikasi: Login dan Sesi Pengguna
- Perbedaan autentikasi (siapa kamu) dan otorisasi (apa yang boleh kamu lakukan)
- `LoginController`, `Auth::attempt()`, sesi pengguna
- Akun demo: `admin@pos.test` dan `kasir@pos.test`

**Kotak Berwarna:**
- **istilahpenting**: Autentikasi, Otorisasi, Middleware, RBAC, Sesi

---

### Session 2: RBAC dengan Middleware Kustom (7-9 halaman)

#### 2.1 RBAC dengan Middleware Kustom
- Menulis middleware `role:admin` yang memeriksa kolom `users.role`
- Mendaftarkan middleware pada `bootstrap/app.php` dan memasangnya pada grup route

#### 2.2 Praktik: Membatasi Akses Halaman Admin
- Membatasi `/products`, `/categories`, `/reports` hanya untuk admin
- Menguji akses sebagai kasir dan memastikan diblokir (403)

**Tabel komparasi:**
| Pendekatan | Kompleksitas Setup | Cocok Untuk |
|---|---|---|
| Middleware kustom (Simple POS) | Rendah | Peran sederhana (2-3 peran) |
| Laravel Breeze | Sedang | Autentikasi siap pakai + scaffolding UI |
| Spatie Permission | Sedang-Tinggi | Peran dan izin granular, banyak kombinasi |

**Kotak Berwarna:**
- **warningbox**: risiko lupa memasang middleware pada route baru

---

## Estimasi Halaman

- **Session 1**: Autentikasi dan sesi pengguna - 7-9 halaman
- **Session 2**: RBAC dengan middleware kustom - 7-9 halaman

**Total: 14-18 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram alur request melewati middleware `auth` lalu `role:admin`

**Tables (1 esensial):**
1. Perbandingan middleware kustom vs Laravel Breeze vs Spatie Permission

**Code Listings / Perintah:**
- Definisi middleware `EnsureUserHasRole`
- Pendaftaran middleware pada grup route

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Autentikasi, login, sesi | 7-9 | lecture/demo |
| 2 | RBAC, middleware peran, praktik | 7-9 | hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: login/logout, middleware `role:admin`, pengujian akses
2. **Should-have**: perbandingan dengan Breeze/Spatie Permission
3. **Nice-to-have**: izin granular per aksi (bukan hanya per peran)

**Fokus Praktik:**
- 40% teori (autentikasi vs otorisasi, RBAC)
- 60% praktik (middleware, pengujian akses)

**Tone:**
- Formal namun mudah diakses
- Tekankan konsekuensi keamanan nyata (kasir mengakses laporan penjualan semua kasir lain)

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-07`, dibuat dari `chapter-06`
- Perubahan/berkas baru: `LoginController`, middleware `role:admin`, pembatasan route admin

**Latihan:**
- 3-4 latihan: uji login dengan akun berbeda, tambah peran baru, jelaskan perbedaan autentikasi vs otorisasi dengan kata sendiri
- `challengebox`: menambah pesan khusus saat kasir mencoba mengakses halaman admin

---

**Status: DRAFT - Belum Ditulis**
