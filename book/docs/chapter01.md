# Rencana Konten: Bab 1 - Arsitektur Web Modern dan Ekosistem Laravel

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** teori pengantar (lanskap arsitektur web, posisi Laravel) + praktik ringan (setup proyek, SQLite, alur Git). Bab pembuka, tanpa `challengebox` (lihat authoring-guide.md).

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Membandingkan arsitektur monolith, microservices, dan serverless untuk menjelaskan alasan Laravel dipilih sebagai kerangka kerja monolith bagi Simple POS
2. Menyiapkan proyek Laravel 13 baru dengan SQLite sebagai basis data zero-setup, lengkap dengan `migrate:fresh --seed` dan `php artisan serve`
3. Menjelaskan konvensi commit "increment N" pada repositori Simple POS dan bagaimana urutan increment memetakan pertumbuhan aplikasi bab demi bab

---

## Struktur Bab (Compact)

### Session 1: Lanskap Arsitektur Web dan Posisi Laravel (7-9 halaman)

#### 1.1 Monolith, Microservices, dan Mengapa Laravel
- Evolusi arsitektur: monolith tunggal, microservices terdistribusi, serverless
- Trade-off: kompleksitas operasional vs kecepatan pengembangan awal
- Posisi Laravel sebagai kerangka kerja monolith full-stack yang produktif untuk aplikasi skala kecil-menengah seperti Simple POS

**Tabel komparasi (jika relevan):**
| Arsitektur | Deployment | Kompleksitas Awal | Cocok Untuk |
|---|---|---|---|
| Monolith | Satu unit | Rendah | Simple POS, MVP, tim kecil |
| Microservices | Banyak unit independen | Tinggi | Sistem skala besar, tim besar |
| Serverless | Fungsi per event | Sedang | Beban kerja sporadis |

**Diagram:**
- Diagram lapisan Laravel (request masuk -> router -> controller -> model -> view/response)

**Kotak Berwarna:**
- **notebox**: posisi Laravel di antara framework PHP lain
- **istilahpenting**: Monolith, Microservices, MVC, Artisan, Migrasi

**Code Listings / Perintah CLI:**
```bash
# instalasi dan verifikasi proyek
composer create-project laravel/laravel simple-pos
php artisan serve
```

---

### Session 2: Menyiapkan Proyek dan Alur Git (7-9 halaman)

#### 2.1 Menyiapkan Proyek Laravel dan SQLite
- Mengapa SQLite dipilih sebagai basis data zero-setup untuk buku ini
- `.env`, `php artisan key:generate`, `touch database/database.sqlite`
- `php artisan migrate:fresh --seed`

#### 2.2 Praktik: Inisialisasi Simple POS dan Alur Git
- Struktur direktori proyek Laravel yang relevan (`routes/`, `app/Http/Controllers/`, `database/`)
- Konvensi commit `increment N` pada repositori Simple POS

**Kotak Berwarna:**
- **tipbox**: cara mengikuti kode lewat branch GitHub sepanjang buku

---

## Estimasi Halaman

- **Session 1**: Lanskap arsitektur web dan posisi Laravel - 7-9 halaman
- **Session 2**: Menyiapkan proyek dan alur Git - 7-9 halaman

**Total: 14-18 halaman** sesuai target bab pengantar

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram lapisan Laravel (request -> router -> controller -> model -> response)

**Tables (1 esensial):**
1. Perbandingan monolith vs microservices vs serverless

**Code Listings / Perintah:**
- Perintah instalasi dan verifikasi proyek (`composer create-project`, `php artisan serve`)
- Perintah migrasi dan seeding awal

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | Lanskap arsitektur web, posisi Laravel | 7-9 | lecture |
| 2 | Setup proyek, SQLite, alur Git | 7-9 | demo/hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: monolith vs microservices, setup proyek Laravel + SQLite, konvensi increment/Git
2. **Should-have**: diagram lapisan Laravel, gambaran repositori Simple POS
3. **Nice-to-have**: sejarah singkat Laravel

**Fokus Praktik:**
- 60% teori (lanskap arsitektur, posisi Laravel)
- 40% praktik (setup proyek, migrasi awal)
- Semua praktik dapat diikuti dengan PHP dan Composer gratis

**Tone:**
- Formal namun mudah diakses, ramah untuk pemula total
- Jelaskan istilah teknis pada penggunaan pertama
- Perkenalkan Simple POS sebagai janji naratif buku, bukan sekadar contoh

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-01` (branch awal, tanpa induk)
- Perubahan: proyek Laravel kosong hasil `composer create-project`, siap dikembangkan

**Latihan:**
- 3-4 latihan: verifikasi instalasi, eksplorasi struktur proyek, identifikasi lapisan MVC pada proyek kosong
- Tidak ada `challengebox` (bab teori pembuka, lihat authoring-guide.md)

---

**Status: Prosa ditulis (ID+EN)**
