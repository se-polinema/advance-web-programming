# Jobsheet Praktikum: Pertemuan 3
## Frontend & Templating dengan Blade, Tailwind, dan Alpine (Kerja Kelompok)

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Web Lanjut (SIB245007) |
| **Pertemuan** | 3 (Minggu 3) |
| **Durasi** | 2 sesi &times; 170 menit |
| **Sub-CPMK** | Sub-CPMK 2: Mahasiswa mampu menerapkan model, templating, dan operasi CRUD dalam pengembangan aplikasi web berbasis framework. |
| **Mode Pengerjaan** | Kelompok (sesuai pembagian dosen), satu repositori GitHub bersama per kelompok |
| **Kode Awal** | branch `chapter-02` di `github.com/se-polinema/simple-pos` |
| **Kode Akhir** | branch `chapter-03` di `github.com/se-polinema/simple-pos` |

## A. Capaian Praktikum

Setelah menyelesaikan jobsheet ini, kamu mampu:

1. Menyiapkan repositori GitHub bersama untuk kerja kelompok dan berkontribusi lewat commit atas nama sendiri, dengan disiplin pull sebelum push.
2. Menyusun layout Blade (`@extends`/`@section`/`@yield`) dan component navigasi yang dipakai ulang lintas halaman.
3. Menata halaman kasir `/pos` dengan class utility Tailwind CSS yang dimuat lewat Vite, memakai `npm run dev` untuk hot reload.
4. Mengimplementasikan keranjang belanja dinamis dengan Alpine.js (`x-data`, `@click`, `x-for`, `x-text`) tanpa reload halaman.
5. Menjelaskan mengapa `{{ }}` wajib dipakai untuk data pengguna, dan mengapa subtotal yang dihitung di klien harus dihitung ulang di server.

## B. Persiapan dan Prasyarat

- **Alat**: sama seperti Pertemuan 2 (PHP 8.2+, Composer, Node.js, Git), ditambah akun GitHub aktif untuk setiap anggota kelompok.
- **Pembagian kelompok**: bekerja dalam kelompok sesuai pembagian dosen. Anggota 1 membuat repositori kelompok; anggota lain diberi nomor urut 2, 3, dan seterusnya untuk pembagian tugas di Langkah Kerja (kalau tugas lebih banyak daripada anggota, tugas berikutnya kembali ke Anggota 1).
- **Identitas git per anggota**: sebelum mulai, setiap anggota memeriksa identitas git di laptopnya sendiri:
  ```bash
  git config --global user.name "Nama Lengkap"
  git config --global user.email "email-akun-github-kamu@..."
  ```
  Email ini sebaiknya sama dengan email akun GitHub kamu, supaya tiap commit terhubung ke profilmu dan kontribusimu terhitung saat dinilai.

  > ⚠️ **Kalau memakai komputer lab bersama:** pakai `git config --local` (tanpa `--global`) di dalam folder proyek yang sudah kamu clone, supaya identitas git tidak tertinggal untuk pengguna berikutnya.
- **Kode awal kelompok**: kelompok memulai bersih dari `chapter-02`, bukan dari proyek pribadi siapa pun. Proyek individu dari Pertemuan 1 dan 2 tetap milikmu sendiri dan tidak dipakai di sini.

## C. Langkah Kerja

Kelompok bekerja di satu branch `main` saja, bergiliran, dengan aturan pull sebelum push. Cara ini dipilih karena branch dan pull request menambah beberapa konsep baru sekaligus (branch, merge, penyelesaian konflik) yang belum pernah kamu pakai, sementara pembangunan halaman kasir di jobsheet ini memang berurutan: halaman butuh layout dulu, keranjang butuh halaman dulu. Anggota yang sedang tidak mengetik tetap ikut `git pull` dan memverifikasi setiap Checkpoint di laptopnya sendiri, supaya tidak ada yang menunggu tanpa kerja.

### Langkah 1: Anggota 1 membuat repositori kelompok

Satu repositori jadi satu sumber kebenaran untuk seluruh kelompok.

```bash
git clone -b chapter-02 https://github.com/se-polinema/simple-pos.git simple-pos-kelompok
cd simple-pos-kelompok
git remote remove origin
```

Buat repositori baru dan kosong (tanpa README) di akun GitHub Anggota 1, misalnya `simple-pos-kelompok-03`, lalu:

```bash
git remote add origin https://github.com/<username-anggota-1>/simple-pos-kelompok-03.git
git push -u origin chapter-02:main
```

Di halaman GitHub repositori itu, buka **Settings &rarr; Collaborators**, lalu tambahkan setiap anggota kelompok, ditambah dosen atau asisten yang menilai.

> ✅ **Checkpoint:** halaman repositori di GitHub menampilkan commit `fix: routes/web.php hanya merujuk controller yang sudah ada di titik ini` sebagai commit teratas, dan setiap anggota sudah menerima serta menyetujui undangan collaborator.

> ⚠️ **Jika gagal:** error `403` saat push berarti undangan collaborator belum disetujui, atau alamat `origin` salah ketik.

### Langkah 2: Semua anggota melakukan clone dan setup

Setiap anggota, di laptop masing-masing:

```bash
git clone https://github.com/<username-anggota-1>/simple-pos-kelompok-03.git
cd simple-pos-kelompok-03
composer install
npm install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate:fresh --seed
```

> ✅ **Checkpoint:** `git log --oneline` menampilkan baris yang sama persis di setiap laptop, dan `php artisan serve` berjalan tanpa error.

### Langkah 3: Menyepakati aturan main git kelompok

Sebelum mulai menulis kode, kelompok sepakat memakai kebiasaan berikut untuk setiap langkah berikutnya:

```bash
git pull
# ...kerjakan tugasmu...
git add .
git commit -m "pesan singkat sesuai tugas"
git push
```

Sepakati juga: hanya satu anggota yang push pada satu waktu, dan beri tahu kelompok lewat grup chat sebelum push supaya tidak bertumbukan.

> ⚠️ **Jika gagal:** error `! [rejected] (fetch first)` saat push berarti ada commit baru di GitHub yang belum kamu ambil. Jalankan `git pull` dulu, pastikan tidak ada konflik, lalu push ulang.

### Langkah 4: Semua anggota menjalankan Vite

```bash
npm run dev
```

Jalankan di terminal kedua, terpisah dari `php artisan serve`. Sambil menunggu, buka `resources/css/app.css` dan pastikan baris pertamanya `@import 'tailwindcss';`, lalu intip `vite.config.js` dan perhatikan plugin `laravel()` dan `tailwindcss()` yang sudah terdaftar sejak Pertemuan 1.

> ✅ **Checkpoint:** terminal menampilkan baris `VITE vX.X.X ready` diikuti alamat lokal seperti `http://localhost:5173/`.

> ⚠️ **Jika gagal:** membuka `/pos` di browser dan melihat `ViteManifestNotFoundException` berarti `npm run dev` belum berjalan di terminal itu.

### Langkah 5: Anggota 1 menyederhanakan `TransactionController`

Kode awal kelompok (`chapter-02`) sudah berisi versi produksi `TransactionController`, yang memanggil Model `Product` dan beberapa Model lain. Model-model itu baru akan kamu buat sendiri pada pertemuan desain basis data, jadi untuk sekarang sederhanakan dulu controller-nya agar halaman kasir bisa dibangun tanpa menunggu Model.

Ganti seluruh isi `app/Http/Controllers/TransactionController.php` menjadi:

```php
<?php

namespace App\Http\Controllers;

class TransactionController extends Controller
{
    public function create()
    {
        $products = collect([
            (object) ['id' => 1, 'name' => 'Kopi Sachet', 'price' => 3000, 'stock' => 40],
            (object) ['id' => 2, 'name' => 'Teh Celup', 'price' => 2500, 'stock' => 25],
            (object) ['id' => 3, 'name' => 'Mie Instan', 'price' => 3500, 'stock' => 8],
            (object) ['id' => 4, 'name' => 'Air Mineral 600ml', 'price' => 4000, 'stock' => 60],
            (object) ['id' => 5, 'name' => 'Roti Tawar', 'price' => 12000, 'stock' => 15],
            (object) ['id' => 6, 'name' => 'Gula Pasir 1kg', 'price' => 15000, 'stock' => 5],
        ]);

        return view('pos.create', ['products' => $products]);
    }

    public function store()
    {
        return 'Transaksi disimpan (belum ada logika penyimpanan)';
    }

    public function index()
    {
        return 'Daftar transaksi';
    }

    public function show(string $id)
    {
        return "Detail transaksi #{$id}";
    }
}
```

Data produk di atas sengaja ditulis langsung di controller (bukan dari basis data): cukup untuk membangun tampilan sekarang, dan akan diganti dengan Model `Product` sungguhan pada pertemuan berikutnya.

```bash
git add .
git commit -m "sederhanakan TransactionController untuk pertemuan 3"
git push
```

Anggota lain: `git pull`.

> ✅ **Checkpoint:** membuka `/pos` di browser menampilkan error "view [pos.create] not found", bukan lagi error Model. Ini wajar, karena view-nya belum dibuat sampai Langkah 8.

### Langkah 6: Anggota 2 membuat layout `app.blade.php`

Ganti seluruh isi `resources/views/layouts/app.blade.php` (buat berkas dan foldernya kalau belum ada):

```php
<!DOCTYPE html>
<html lang="id">
<head>
    <title>@yield('title', 'Simple POS')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <x-nav />
    <main>@yield('content')</main>
</body>
</html>
```

```bash
git add .
git commit -m "tambah layout dasar aplikasi"
git push
```

Anggota lain: `git pull`.

> ✅ **Checkpoint:** berkas `resources/views/layouts/app.blade.php` ada di semua laptop setelah pull. Halaman `/pos` belum berubah tampilannya, layout ini baru benar-benar terpakai di Langkah 8.

### Langkah 7: Anggota 3 membuat component navigasi

Buat berkas baru `resources/views/components/nav.blade.php`:

```php
<nav class="bg-slate-900 text-white px-4 py-3 flex gap-4">
    <span class="font-semibold">Simple POS</span>
    <a href="{{ route('pos.create') }}" class="hover:underline">Kasir</a>
    <a href="{{ route('transactions.index') }}" class="hover:underline">Transaksi</a>
</nav>
```

Component ini otomatis terdeteksi Laravel dari namanya: dipanggil lewat `<x-nav />`, seperti yang sudah ditulis di layout pada Langkah 6.

```bash
git add .
git commit -m "tambah component nav"
git push
```

Anggota lain: `git pull`.

> ✅ **Checkpoint:** berkas `resources/views/components/nav.blade.php` ada di semua laptop.

### Langkah 8: Anggota 4 (atau bergiliran kembali ke Anggota 1) membuat halaman kasir

Buat berkas baru `resources/views/pos/create.blade.php`:

```php
@extends('layouts.app')

@section('title', 'Kasir')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Transaksi Kasir</h1>
    <div class="grid grid-cols-3 gap-4">
        @foreach ($products as $product)
            <div class="border rounded-md p-3">
                <p class="font-medium">{{ $product->name }}</p>
                <p class="text-sm text-slate-500">Rp {{ number_format($product->price) }}</p>
            </div>
        @endforeach
    </div>
@endsection
```

Perhatikan `{{ $product->name }}`: kurung kurawal ganda ini otomatis melakukan escaping HTML, supaya nama produk yang mengandung karakter seperti `<` tidak bisa dipakai untuk menyuntikkan markup asing ke halaman. Data yang berasal dari input pengguna wajib ditampilkan lewat `{{ }}`, bukan `{!! !!}`, yang melewati escaping sama sekali.

```bash
git add .
git commit -m "tambah halaman kasir dengan tailwind"
git push
```

Anggota lain: `git pull`.

> ✅ **Checkpoint:** membuka `http://127.0.0.1:8000/pos` menampilkan grid enam produk dengan nav di atasnya. Sambil `npm run dev` berjalan, coba ubah satu class Tailwind di berkas ini dan lihat perubahannya langsung terlihat di browser tanpa refresh manual.

### Langkah 9: Anggota berikutnya menginstal Alpine.js

```bash
npm install alpinejs
```

Ganti seluruh isi `resources/js/app.js`:

```js
import './bootstrap';
import Alpine from 'alpinejs';

window.Alpine = Alpine;
Alpine.start();
```

```bash
git add .
git commit -m "instal alpine.js"
git push
```

Anggota lain: `git pull`, **lalu jalankan `npm install` lagi** karena `package.json` ikut berubah.

> ✅ **Checkpoint:** buka console browser (F12) di halaman `/pos`, ketik `Alpine.version`, dan pastikan muncul nomor versi.

> ⚠️ **Jika gagal:** error `Alpine is not defined` di console setelah pull biasanya berarti kamu lupa menjalankan `npm install` ulang, atau `npm run dev` belum di-restart.

### Langkah 10: Anggota berikutnya membangun keranjang dinamis

Ubah `resources/views/pos/create.blade.php` menjadi:

```php
@extends('layouts.app')

@section('title', 'Kasir')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Transaksi Kasir</h1>
    <div x-data="{
        cart: [],
        addToCart(id, name, price) {
            this.cart.push({ id, name, price });
        },
        subtotal() {
            return this.cart.reduce((sum, item) => sum + item.price, 0);
        }
    }">
        <div class="grid grid-cols-3 gap-4">
            @foreach ($products as $product)
                <div class="border rounded-md p-3 cursor-pointer"
                     @click="addToCart({{ $product->id }}, '{{ $product->name }}', {{ $product->price }})">
                    <p class="font-medium">{{ $product->name }}</p>
                    <p class="text-sm text-slate-500">Rp {{ number_format($product->price) }}</p>
                </div>
            @endforeach
        </div>

        <div class="mt-4 border-t pt-3">
            <template x-for="item in cart" :key="item.id">
                <p x-text="item.name + ' - Rp ' + item.price"></p>
            </template>
            <p class="font-semibold mt-2">Subtotal: Rp <span x-text="subtotal()"></span></p>
        </div>
    </div>
@endsection
```

```bash
git add .
git commit -m "tambah keranjang dinamis dengan alpine"
git push
```

Anggota lain: `git pull`.

> ✅ **Checkpoint:** mengklik salah satu kartu produk langsung menambahkan namanya ke area ringkasan di bawah grid dan subtotal bertambah, tanpa halaman ikut memuat ulang (perhatikan address bar dan favicon tab, keduanya tidak berkedip).

> ⚠️ **Jika gagal**, periksa tiga hal paling umum: (a) console browser menampilkan `Alpine is not defined`, berarti `npm run dev` tidak berjalan atau Langkah 9 belum tersimpan; (b) halaman menampilkan `ViteManifestNotFoundException`, berarti `npm run dev` belum dijalankan sama sekali; (c) pastikan seluruh grid produk dan area ringkasan benar-benar berada di dalam elemen yang membawa `x-data`, bukan jadi elemen bertetangga di luarnya.

### Langkah 11: Bersama, uji integrasi dan review kode

Semua anggota `git pull`, jalankan kedua server, dan ulangi uji klik dari Langkah 10 di laptop masing-masing. Setelah itu, kelompok membaca kode bersama: setiap anggota menjelaskan satu berkas yang **bukan** ia tulis sendiri.

> ✅ **Checkpoint:** halaman `/pos` berperilaku sama persis di setiap laptop anggota.

### Langkah 12: Tantangan mandiri kelompok dan commit `increment 3`

Bagi tugas berikut di antara anggota, supaya setiap anggota tercatat minimal satu commit bermakna:

- Tambahkan tombol *Hapus* pada tiap baris item di keranjang, memanggil method Alpine baru yang mengeluarkan item itu dari array `cart` berdasarkan `id`-nya.
- Tambahkan badge kecil bertuliskan "Stok Menipis" memakai class Tailwind `bg-amber-100 text-amber-700`, muncul hanya ketika `stock` produk di bawah 10.
- Tambahkan highlight (misalnya class Tailwind `ring-2 ring-blue-500`) pada kartu produk yang baru saja diklik.
- Rapikan tampilan nav: beri jarak antar link, dan tandai link halaman yang sedang aktif.
- Tambahkan `@section('title', 'Riwayat Transaksi')` yang berbeda untuk method `index`, dengan view stub baru `resources/views/transactions/index.blade.php`.

Setiap tugas: `git pull`, kerjakan, `git add .`, `git commit -m "pesan sesuai tugas"`, `git push`.

Setelah semua tugas masuk, Anggota 1 melakukan pull terakhir dan menutup pekerjaan kelompok:

```bash
git pull
git commit --allow-empty -m "increment 3: tampilan kasir dengan blade, tailwind, dan alpine"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** baris teratas `git log --pretty="%h %an %s"` menunjukkan `increment 3: ...`, dan baris-baris di bawahnya menunjukkan nama setiap anggota kelompok.

## D. Tugas dan Deliverable

Kumpulkan hal berikut sesuai format yang diminta asisten/dosen:

- Link repositori GitHub kelompok.
- Screenshot halaman `/pos` dengan minimal 2 item di keranjang dan subtotal terisi.
- Output `git log --pretty="%h %an %s"` yang menunjukkan minimal satu commit per anggota.
- Tabel pembagian tugas: nama anggota | langkah/tugas yang dikerjakan | hash commit.
- **Tugas mandiri (dikerjakan dan dikumpulkan masing-masing anggota):** jelaskan dengan kata-katamu sendiri, dalam 3-5 kalimat: (a) kenapa `{{ }}` lebih aman dipakai untuk menampilkan nama produk dibanding `{!! !!}`, dan (b) kenapa subtotal yang dihitung Alpine.js di keranjang tidak boleh langsung dipercaya sebagai total transaksi final oleh server.

## E. Kriteria Penilaian

| Komponen | Bobot | Kriteria Lengkap (100%) | Kriteria Minimum |
|---|---:|---|---|
| Langkah kerja tuntas (kelompok) | 30% | Langkah 1-12 selesai, `/pos` berfungsi dengan keranjang dinamis | Sebagian besar langkah selesai, halaman kasir tampil |
| Checkpoint terverifikasi (kelompok) | 20% | Screenshot, tabel pembagian tugas, dan git log lengkap dan benar | Sebagian checkpoint terbukti |
| Kontribusi per anggota (individu) | 25% | Minimal satu commit bermakna atas nama tiap anggota, sesuai tabel pembagian tugas | Commit ada tapi kecil atau kurang jelas kaitannya |
| Tugas mandiri (individu) | 15% | Kedua penjelasan tepat dan berdiri sendiri | Jawaban ada meski belum lengkap |
| Kerapian repositori dan commit | 10% | Pesan `increment 3` persis, tanpa menyertakan `vendor/`/`node_modules/`/`.env`, riwayat pull-sebelum-push bersih | Commit ada meski pesan kurang rapi |
