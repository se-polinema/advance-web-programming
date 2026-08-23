# Rencana Konten: Bab 3 - Antarmuka dengan Blade, Tailwind, dan Alpine

> **Scope:** 2 sesi x 170 menit = 340 menit instruksi
> **Target:** 14-18 halaman
> **Pendekatan:** konsep MPA vs SPA + praktik langsung membangun layout Blade dan keranjang belanja dinamis dengan Alpine.js.

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. Membandingkan pola multi-page application (MPA) dan single-page application (SPA), serta menjelaskan posisi Blade dan Alpine.js sebagai pendekatan hibrida
2. Menyusun layout Blade dan halaman kasir (`/pos`) Simple POS dengan Tailwind CSS lewat CDN, tanpa langkah build frontend
3. Mengimplementasikan keranjang belanja dinamis pada halaman kasir memakai Alpine.js untuk interaktivitas sisi klien tanpa reload halaman

---

## Struktur Bab (Compact)

### Session 1: MPA vs SPA dan Layout Blade (7-9 halaman)

#### 1.1 MPA vs SPA dan Peran Blade
- Multi-page application: setiap navigasi memuat ulang halaman penuh
- Single-page application: satu halaman, konten diperbarui lewat JavaScript
- Blade + Alpine.js sebagai jalan tengah: markup sisi server, interaktivitas ringan sisi klien

#### 1.2 Layout dan Halaman Kasir dengan Tailwind
- Struktur `layout.blade.php` dan `@yield`/`@section`
- Memuat Tailwind CSS lewat CDN (tanpa Vite/npm)
- Menyusun grid produk pada halaman `/pos`

**Kotak Berwarna:**
- **istilahpenting**: Blade, Directive, Component, Alpine.js, CDN

**Code Listings / Perintah CLI:**
```bash
# tidak ada langkah build frontend; Tailwind dimuat lewat CDN
php artisan serve
```

---

### Session 2: Keranjang Belanja Dinamis (7-9 halaman)

#### 2.1 Praktik: Keranjang Belanja Dinamis dengan Alpine.js
- State `x-data` untuk daftar item di keranjang
- Menambah/menghapus item tanpa reload halaman
- Menghitung subtotal secara langsung di sisi klien (dikonfirmasi ulang di server, lihat Bab 6)

**Cuplikan kode inline** (maks. ~15 baris):
```html
<div x-data="{ cart: [] }">
  <button @click="cart.push({ id: 1, price: 15000 })">Tambah</button>
  <span x-text="cart.length"></span>
</div>
```

**Kotak Berwarna:**
- **tipbox**: kapan logika sebaiknya tetap di server, bukan di Alpine.js

---

## Estimasi Halaman

- **Session 1**: MPA vs SPA dan layout Blade - 7-9 halaman
- **Session 2**: Keranjang belanja dinamis - 7-9 halaman

**Total: 14-18 halaman**

---

## Visual Assets

**Diagrams (1 esensial):**
1. Diagram alur render halaman: server (Blade) -> klien (Alpine.js) -> DOM

**Tables (1 esensial):**
1. Perbandingan MPA vs SPA vs pendekatan hibrida Blade+Alpine

**Code Listings / Perintah:**
- Struktur layout Blade dasar
- Cuplikan `x-data`/`x-model`/`@click` Alpine.js

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | MPA vs SPA, layout Blade+Tailwind | 7-9 | lecture/demo |
| 2 | Keranjang belanja dinamis dengan Alpine.js | 7-9 | hands-on |

**Total: ~14-18 halaman** untuk 340 menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: layout Blade, halaman `/pos`, keranjang dinamis Alpine.js
2. **Should-have**: perbandingan MPA/SPA
3. **Nice-to-have**: variasi komponen Blade lanjutan

**Fokus Praktik:**
- 40% teori (MPA vs SPA, peran Blade)
- 60% praktik (layout, halaman kasir, keranjang dinamis)

**Tone:**
- Formal namun mudah diakses
- Jelaskan istilah teknis pada penggunaan pertama

**Kode dan Branch GitHub:**
- Branch sumber: `chapter-03`, dibuat dari `chapter-02`
- Perubahan/berkas baru: `resources/views/layouts/app.blade.php`, halaman `/pos` dengan keranjang Alpine.js

**Latihan:**
- 3-4 latihan: modifikasi layout, tambah tombol hapus item pada keranjang, jelaskan mengapa subtotal klien tetap perlu diverifikasi server
- `challengebox`: menambah indikator jumlah item di keranjang pada navbar

---

**Status: DRAFT - Belum Ditulis**
