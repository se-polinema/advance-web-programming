# RPS PEMROGRAMAN WEB LANJUT (RTI254007)
**Versi General (Laravel sebagai Case Study) — Standar OBE + LAM INFOKOM | Revisi 2026**

---

## 📄 IDENTITAS MATA KULIAH

| Item | Keterangan |
|---|---|
| **Nama Mata Kuliah** | Pemrograman Web Lanjut |
| **Kode** | RTI254007 |
| **Bobot** | 3 SKS / 6 jam |
| **Semester** | 4 (Genap) |
| **Prasyarat** | Desain dan Pemrograman Web |
| **Tanggal Revisi** | 28 Juli 2026 |

---

## 📊 CAPAIAN PEMBELAJARAN

### CPL Prodi

| Kode | Deskripsi |
|---|---|
| **CPL02** | Mampu merancang, mengimplementasikan, dan menganalisis algoritma menggunakan berbagai paradigma pemrograman, serta mampu memecahkan masalah komputasional dengan logika yang sistematis dan tepat. |

### CPMK

| Kode | Deskripsi |
|---|---|
| **CPMK 02.2** | Mahasiswa mampu mengimplementasikan algoritma dalam program komputer menggunakan berbagai paradigma pemrograman, seperti prosedural, berorientasi objek, dan berbasis web/mobile. |

### Sub-CPMK (turunan CPMK 02.2)

| Kode | Deskripsi |
|---|---|
| **Sub-CPMK 1** | Mahasiswa mampu memahami konsep dasar web framework serta menerapkan routing, controller, dan pengelolaan basis data dalam pengembangan aplikasi web. |
| **Sub-CPMK 2** | Mahasiswa mampu menerapkan model, templating, dan operasi CRUD dalam pengembangan aplikasi web berbasis framework. |
| **Sub-CPMK 3** | Mahasiswa mampu menerapkan mekanisme autentikasi, otorisasi, dan pengembangan API pada aplikasi web. |
| **Sub-CPMK 4** | Mahasiswa mampu mengembangkan aplikasi web berbasis framework sesuai dengan kebutuhan pengguna. |

---

## 📅 RENCANA PEMBELAJARAN MINGGUAN

> **Catatan**: Proyek PBL berjalan sepanjang semester (minggu 1–16). UTS (minggu 8) menilai *progress* proyek; UAS (minggu 16) menilai proyek final.

| Minggu | Pokok Bahasan | Sub Pokok Bahasan | Kode Sub-CPMK | Bentuk Pembelajaran | Metode Pembelajaran | Mode Pembelajaran | Bentuk Penilaian | Bobot (%) |
|:---:|---|---|:---:|---|---|---|---|:---:|
| 1 | Pengenalan Mata Kuliah & Arsitektur Web Modern | RPS; Kontrak kuliah; Evolusi arsitektur web (Monolith vs Microservices vs Serverless); Perbandingan framework (Laravel vs Django vs Express vs Next.js); Setup lingkungan pengembangan framework (studi kasus: Laravel 13); Git flow dasar | Sub-CPMK 1 | Kuliah; Praktikum | Small Group Discussion (SGD); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 2 | HTTP Protocol & MVC Architecture | HTTP protocol deep dive (request/response cycle, methods, status codes, headers); MVC vs MVVM vs Clean Architecture; Routing modern; Controller organization | Sub-CPMK 1 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 3 | Frontend Landscape & Templating | Templating sisi server & komponen UI (studi kasus: Blade Components); Asset bundling & build pipeline (studi kasus: Vite); Utility-first CSS (studi kasus: Tailwind CSS); Progressive enhancement & interaktivitas ringan (studi kasus: Alpine.js); Perbandingan MPA vs SPA | Sub-CPMK 2 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 4 | Database Design & Migration | Indexing strategy; SQL vs NoSQL overview; Migration & schema evolution; Schema builder; Seeding & factory; Perbandingan Eloquent vs Prisma vs SQLAlchemy | Sub-CPMK 1 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 5 | ORM & Data Access Patterns | Pola ORM: Active Record vs Data Mapper (studi kasus: Eloquent); Pemetaan relasi antar-entitas (1-1, 1-N, N-N); Masalah N+1 & eager loading; Transformasi atribut (accessor/mutator) | Sub-CPMK 2 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 6 | Validasi & Security Input | Keamanan input: XSS, CSRF, SQL Injection, OWASP Top 10; Validasi & sanitization; Enkapsulasi aturan validasi (studi kasus: Form Request); Flash message & error-handling UX | Sub-CPMK 2 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 7 | Authentication & Authorization Standards | Konsep autentikasi web: session vs token, cookies, password hashing; Otorisasi & RBAC; Studi kasus: Laravel Breeze, Spatie Permission; Perbandingan auth lintas framework | Sub-CPMK 3 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| **8** | **UTS — Evaluasi Progress Proyek PBL** | Demonstrasi progress proyek: implementasi CRUD lengkap; REST principles; HTTP methods semantics; Arsitektur MVC; Database design; Validasi & autentikasi; Defense lisan (viva) | **Sub-CPMK 1; Sub-CPMK 2; Sub-CPMK 3** | Praktikum; Ujian | Hands-on Practice; Viva | Tatap Muka (TM) | **UTS Praktik** | **20** |
| 9 | Data Processing & Import/Export | ETL pipeline; Batch & queue-based processing; Memory management untuk dataset besar; Ekspor dokumen PDF/spreadsheet (studi kasus: DomPDF, Laravel Excel) | Sub-CPMK 4 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 10 | API Architecture & Design | Prinsip REST: statelessness, resource & representasi, semantik HTTP method, versioning, pagination; Spesifikasi OpenAPI/Swagger; Token auth untuk API (studi kasus: Sanctum, API Resource) | Sub-CPMK 3 | Kuliah; Praktikum | Problem Based Learning (PBL); Hands-on Practice | Tatap Muka (TM) | Tugas Individu | 5 |
| 11 | PBL Proyek Web Terintegrasi | Perencanaan fitur proyek; Arsitektur aplikasi; Pembagian peran tim | Sub-CPMK 4 | Praktikum | Project Based Learning (PBL); Mentoring | Tatap Muka (TM) | Tugas Kelompok | 3 |
| 12 | PBL Proyek Web Terintegrasi | Pengembangan fitur utama; Code review sesama tim | Sub-CPMK 4 | Praktikum | Project Based Learning (PBL); Mentoring | Tatap Muka (TM) | Tugas Kelompok | 4 |
| 13 | PBL Proyek Web Terintegrasi | Integrasi modul; Uji fungsional manual & UAT; Perbaikan iteratif | Sub-CPMK 4 | Praktikum | Project Based Learning (PBL); Mentoring | Tatap Muka (TM) | Tugas Kelompok | 4 |
| 14 | PBL Proyek Web Terintegrasi | Optimasi performa: profiling query, N+1, caching dasar; Deployment sederhana: konfigurasi environment, production build, satu server; Dokumentasi teknis | Sub-CPMK 4 | Praktikum | Project Based Learning (PBL); Mentoring | Tatap Muka (TM) | Tugas Kelompok | 4 |
| 15 | PBL Proyek Web Terintegrasi — Finalisasi | Finalisasi aplikasi web utuh; Dokumentasi arsitektur; Video demo; Presentasi | Sub-CPMK 4 | Praktikum | Project Based Learning (PBL); Mentoring | Tatap Muka (TM) | Tugas Kelompok | 10 |
| **16** | **UAS — Evaluasi Proyek Web Final** | Demonstrasi proyek final; Presentasi produk; Defense lisan (viva); Evaluasi ketercapaian kebutuhan pengguna | **Sub-CPMK 4** | Praktikum; Ujian | Viva; Presentasi | Tatap Muka (TM) | **UAS Praktik** | **10** |
| | | | | | | | **TOTAL** | **100%** ✅ |

> **Catatan tambahan**: Pengujian otomatis (unit/feature testing, CI) dibahas tuntas pada MK Penjaminan Mutu Perangkat Lunak — MK ini hanya mencakup uji fungsional manual/UAT sebagai bagian PBL, untuk menghindari duplikasi materi. Deployment lanjut (CI/CD, container, orkestrasi cloud) dibahas pada MK Cloud Computing; MK ini hanya mencakup deployment sederhana satu server.

---

## 📊 REKAP PENILAIAN

| Komponen | Minggu | Sub-CPMK | Bobot |
|---|:---:|:---:|:---:|
| Tugas Individu (7×) | 1–7 | Sub-1, Sub-2, Sub-3 | 35% |
| UTS Praktik — Progress Proyek PBL | 8 | Sub-1, Sub-2, Sub-3 | 20% |
| Tugas Individu (2×) | 9–10 | Sub-4, Sub-3 | 10% |
| Tugas Kelompok PBL (formative, 4×) | 11–14 | Sub-4 | 15% |
| Tugas Kelompok PBL (finalisasi) | 15 | Sub-4 | 10% |
| UAS Praktik — Proyek Final | 16 | Sub-4 | 10% |
| **TOTAL** | | | **100%** |
