# Rencana Konten: Bab 2 - Protokol HTTP dan Pola MVC

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** konsep HTTP dan pola arsitektur + praktik langsung menulis route dan controller pada Simple POS.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Menjelaskan siklus request/response HTTP (method, status code, header) dan memetakannya ke potongan kode route Simple POS
2. Membandingkan pola MVC, MVVM, dan Clean Architecture, serta menjelaskan bagaimana Laravel mengimplementasikan MVC pada praktiknya
3. Menulis route dan controller untuk endpoint `/pos` dan `/transactions` pada Simple POS, termasuk pemisahan route web dari middleware group-nya

---

## Struktur Bab (Compact)

### Session 1: Siklus HTTP dan Pola Arsitektur (7-9 halaman)

#### 1.1 Siklus Request/Response HTTP
- Method HTTP (GET, POST, PATCH, DELETE) dan semantiknya
- Status code umum (200, 302, 404, 422, 500) dan kapan masing-masing dipakai
- Header request/response yang relevan bagi aplikasi web

#### 1.2 MVC, MVVM, dan Clean Architecture
- Pembagian tanggung jawab Model-View-Controller
- Perbandingan singkat dengan MVVM dan Clean Architecture
- Bagaimana Laravel memetakan konsep MVC ke direktori proyek nyata

**Tabel komparasi:**
| Pola | Pemisahan Utama | Contoh Pemakaian |
|---|---|---|
| MVC | Model - View - Controller | Laravel (default) |
| MVVM | Model - View - ViewModel | Aplikasi dengan binding dua arah |
| Clean Architecture | Lapisan use case terisolasi dari framework | Sistem berskala besar |

**Kotak Berwarna:**
- **istilahpenting**: Request, Response, Route, Controller, Middleware

---

### Session 2: Praktik Routing dan Controller (7-9 halaman)

#### 2.1 Praktik: Routing dan Controller Simple POS
- Mendaftarkan route `/pos` dan `/transactions` pada `routes/web.php`
- Memisahkan route tamu (`guest`) dari route yang memerlukan autentikasi
- Menulis controller pertama yang menangani request kasir

**Code Listings / Perintah CLI:**
```bash
php artisan make:controller TransactionController
php artisan route:list
```

**Kotak Berwarna:**
- **warningbox**: risiko mendaftarkan route tanpa middleware yang sesuai

---

## Estimasi Halaman

- **Session 1**: Siklus HTTP dan pola arsitektur - 7-9 halaman
- **Session 2**: Praktik routing dan controller - 7-9 halaman

**Total: 14-18 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram siklus request/response HTTP pada satu route Simple POS

**Tables (1 esensial):**
1. Perbandingan MVC vs MVVM vs Clean Architecture

**Code Listings / Perintah:**
- Pendaftaran route pada `routes/web.php`
- Perintah `php artisan make:controller` dan `php artisan route:list`

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Siklus HTTP, MVC/MVVM/Clean Architecture | 7-9 | lecture |
| 2 | Routing dan controller Simple POS | 7-9 | hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: siklus request/response, pola MVC, route dan controller `/pos`
2. **Should-have**: perbandingan MVVM/Clean Architecture
3. **Nice-to-have**: sejarah singkat pola MVC

**Fokus Praktik:**
- 50% teori (HTTP, pola arsitektur)
- 50% praktik (routing, controller)
- Semua praktik dapat diikuti dengan proyek Simple POS hasil Bab 1

**Tone:**
- Formal namun mudah diakses
- Jelaskan istilah teknis pada penggunaan pertama

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-02`, dibuat dari `chapter-01`
- Perubahan/berkas baru: route dan controller dasar untuk `/pos` dan `/transactions`

**Latihan:**
- 3-4 latihan: identifikasi method HTTP pada route yang ada, tambah route baru, jelaskan pemetaan MVC pada satu fitur
- `challengebox`: menambah satu route baru dengan controller kosong sebagai latihan pemetaan mandiri

---

**Status: Prosa ditulis (ID+EN)**
