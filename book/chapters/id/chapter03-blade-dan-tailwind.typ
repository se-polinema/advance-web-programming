#import "/template.typ": *

= Antarmuka dengan Blade, Tailwind, dan Alpine <ch:blade-dan-tailwind>

#chapterhero("blue", [Bangun tampilan kasir Simple POS dengan Blade dan Tailwind, lalu hidupkan keranjang belanjanya dengan Alpine.js tanpa reload halaman.], [#icon("layer-group")#h(1em)MPA vs SPA], [#icon("palette")#h(1em)Blade & Tailwind], [#icon("bolt")#h(1em)Alpine.js])

Etalase toko kelontong yang hanya memajang barang di balik kaca tidak pernah
berubah sampai pemiliknya sendiri turun tangan menata ulang. Pembeli yang
ingin tahu berapa stok yang tersisa, atau ingin membatalkan barang yang
sudah diambil dari rak, harus memanggil pramuniaga dan menunggu jawaban.
Pramuniaga yang sigap bekerja dengan cara berbeda: begitu pembeli mengambil
satu barang dan meletakkannya ke keranjang, ia langsung tahu, menghitung
ulang totalnya di tempat, dan siap membatalkan pilihan itu tanpa pembeli
perlu mengulang dari awal. Halaman kasir Simple POS yang dibangun murni
dengan Blade, tanpa sentuhan JavaScript sama sekali, berperilaku persis
seperti etalase kaca itu: setiap kali kasir menambah satu produk ke
keranjang, seluruh halaman harus dimuat ulang dari server. Kios dengan
volume transaksi tinggi tidak punya waktu untuk reload halaman puluhan
kali dalam satu shift; kasir yang menunggu tiap klik selesai memuat ulang
melayani pembeli lebih lambat, dan antrean di depan kasir ikut merasakan
akibatnya.

#strong[Yang Akan Kamu Pelajari]

+ membandingkan pola multi-page application (MPA) dan single-page application (SPA), serta menjelaskan posisi Blade dan Alpine.js sebagai pendekatan hibrida;
+ menyusun layout Blade dan halaman kasir (`/pos`) Simple POS dengan Tailwind CSS lewat Vite, memakai `npm run dev` untuk hot reload selama pengembangan;
+ mengimplementasikan keranjang belanja dinamis pada halaman kasir memakai Alpine.js, diinstal lewat npm dan dibundel bersama aset lain oleh Vite, untuk interaktivitas sisi klien tanpa reload halaman.

== MPA vs SPA dan Peran Blade <sec:blade-dan-tailwind-1>

#istilahpenting[
/ Blade: Mesin templating bawaan Laravel yang merender HTML di server, memakai sintaks direktif seperti `@if` dan `@foreach` langsung di dalam berkas `.blade.php`.
/ Directive: Instruksi Blade yang diawali `@`, misalnya `@extends`, `@section`, dan `@yield`, yang dikompilasi Laravel menjadi PHP biasa sebelum dijalankan.
/ Component: Potongan Blade yang bisa dipakai ulang lintas halaman, misalnya kartu produk atau tombol, didaftarkan sebagai berkas terpisah dan dipanggil lewat tag `<x-nama-component>`.
/ Alpine.js: Pustaka JavaScript ringan yang menambahkan state dan interaktivitas langsung lewat atribut HTML (`x-data`, `x-model`, `@click`), diinstal lewat npm seperti dependensi JavaScript lain.
/ Vite: Build tool frontend yang dipakai Laravel secara bawaan: menjalankan dev server dengan hot reload lewat `npm run dev` selama pengembangan, dan membundel/meminifikasi seluruh CSS & JavaScript jadi berkas produksi lewat `npm run build`.
]

Sebuah #term[multi-page application] (MPA) memuat ulang seluruh halaman dari
server setiap kali pengguna berpindah tautan atau mengirim form: browser
membuang HTML lama, meminta yang baru, dan merender dari nol. Pendekatan ini
sederhana untuk dipahami dan gampang di-debug karena setiap request punya
jawaban HTML yang lengkap, tapi terasa lambat untuk interaksi kecil yang
sering berulang, seperti menambah satu produk ke keranjang belanja.
#term[Single-page application] (SPA) mengambil jalan berlawanan: satu
halaman HTML dimuat sekali di awal, lalu seluruh perubahan berikutnya
ditangani JavaScript di browser, yang mengambil data lewat request
tersembunyi dan memperbarui sebagian DOM saja tanpa reload. React, Vue, dan
Angular adalah contoh pustaka yang dibangun khusus untuk pola SPA.

#figure(
  table(
    columns: (0.7fr, 1.3fr, 1.3fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Pola], [Sumber render], [Cocok untuk],
    table.hline(stroke: 0.5pt),
    [MPA murni], [Server, HTML penuh tiap navigasi], [Halaman dengan interaksi jarang, SEO penting],
    [SPA murni], [Klien, JavaScript merender DOM], [Aplikasi dengan interaksi sangat sering, state kompleks],
    [Blade + Alpine.js], [Server untuk struktur, klien untuk interaksi lokal], [Aplikasi seperti Simple POS: halaman umumnya statis, sebagian kecil butuh reaktif],
    table.hline(stroke: 0.8pt),
  ),
  caption: [MPA, SPA, dan pendekatan hibrida Blade + Alpine.js],
) <tab:mpa-spa>

Simple POS tidak memerlukan SPA penuh. Halaman kategori, daftar transaksi,
dan laporan penjualan jarang berubah dalam satu sesi kerja, jadi render
server biasa lewat Blade sudah cukup cepat dan jauh lebih sederhana untuk
dirawat. Satu-satunya bagian yang benar-benar butuh interaktivitas tanpa
reload adalah keranjang belanja di halaman kasir: kasir menambah dan
mengurangi item berkali-kali dalam satu transaksi, dan menunggu reload
setiap klik akan terasa mengganggu. Alpine.js mengisi celah itu tanpa
memaksa seluruh aplikasi pindah ke arsitektur SPA; ia hanya menambahkan
state dan reaktivitas pada elemen HTML yang memang membutuhkannya, sementara
sisa halaman tetap dirender Blade seperti biasa.

#notebox[
Pendekatan ini kadang disebut hibrida atau, dalam ekosistem Laravel, dekat
dengan pola yang dipopulerkan Livewire dan Hotwire: server tetap jadi
sumber kebenaran, JavaScript hanya bertugas mempercepat bagian yang terasa
lambat kalau harus reload penuh.
]

== Layout dan Halaman Kasir dengan Tailwind <sec:blade-dan-tailwind-2>

Hampir setiap halaman Simple POS berbagi kerangka yang sama: judul tab
browser, menu navigasi di sisi kiri, dan area konten yang berubah-ubah
tergantung halaman mana yang dibuka. Blade menghindari pengulangan kerangka
itu di setiap berkas lewat direktif `@extends`, `@section`, dan
`@yield`: satu berkas layout mendefinisikan kerangka lengkap dengan
lubang bernama tempat konten halaman akan disisipkan, dan setiap halaman
individual cukup mengisi lubang itu tanpa menulis ulang `<html>`,
`<head>`, atau menu navigasi.

#listing(file: "resources/views/layouts/app.blade.php", ```php
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
```)

Direktif `@vite([...])` menggantikan tag `<script>`/`<link>`
manual: ia menyuntikkan tag CSS dan JavaScript yang tepat secara otomatis,
berbeda tergantung mode. Tiga berkas bekerja sama di baliknya, dan ketiganya
sudah tersedia sejak `npm install` di Bab~1:

+ `resources/css/app.css` memuat Tailwind lewat satu baris
      `@import 'tailwindcss';` di baris pertama, bukan berkas
      konfigurasi `tailwind.config.js` terpisah seperti versi Tailwind
      yang lebih lama.
+ `vite.config.js` mendaftarkan dua plugin:
      `laravel()` (menghubungkan Vite ke direktif `@vite` dan
      mendeteksi berkas yang berubah) dan `tailwindcss()` (memproses
      class utility jadi CSS asli).
+ `package.json` mendaftarkan kedua paket itu sebagai
      `devDependencies`, sudah terunduh ke `node_modules/`
      sejak `npm install` dijalankan.

Selama pengembangan, Vite berjalan sebagai dev server terpisah dari
`php artisan serve`, dijalankan di terminal kedua:

#listing(```bash
npm run dev
```)

#strong[Yang diharapkan]: baris `VITE vX.X.X ready in N ms` diikuti
alamat lokal seperti `Local: http://localhost:5173/`. Selama
perintah ini berjalan, direktif `@vite` di halaman yang dibuka lewat
`php artisan serve` otomatis memuat aset dari dev server itu, dan
menyunting `app.css` atau berkas Blade langsung terlihat di browser
tanpa refresh manual (#emph[hot reload]), sesuatu yang tidak dimiliki
CDN. Tailwind sendiri tetap bekerja lewat class utility yang ditempel
langsung pada elemen HTML, misalnya `class="bg-slate-900 text-white
rounded-md px-4 py-2"` untuk sebuah tombol gelap dengan sudut membulat dan
padding, alih-alih menulis aturan CSS terpisah di berkas lain; hanya
sumber Tailwind-nya yang berubah dari CDN menjadi Vite.

#warningbox[
`npm run dev` harus tetap berjalan di terminal terpisah selama
pengembangan. Kalau dihentikan, direktif `@vite` pada halaman yang
dimuat ulang akan gagal menemukan dev server dan melempar
`ViteManifestNotFoundException`, kecuali sebuah build produksi
(`npm run build`, dibahas penuh di Bab~11) sudah pernah dijalankan
sebelumnya.
]

#tipbox[
Menjalankan dan mengingat dua terminal terpisah cukup merepotkan begitu
sudah terbiasa. Skrip `composer run dev`, sudah didefinisikan di
bagian `scripts` pada `composer.json` proyek Laravel bawaan,
menjalankan `php artisan serve`, `npm run dev`, queue
listener, dan tail log aplikasi sekaligus dalam satu terminal lewat satu
perintah `php artisan dev` di baliknya; satu `Ctrl+C`
menghentikan semuanya bersamaan. Buku ini sengaja memulai dengan dua
terminal terpisah supaya jelas proses mana yang menangani apa, terutama
saat salah satunya gagal (misalnya Vite melempar galat, dan terminal
khususnya membuat sumber masalah langsung terlihat); setelah pola itu
terasa akrab, `composer run dev` jadi cara yang lebih praktis untuk
dipakai sehari-hari.
]

#listing(file: "resources/views/pos/create.blade.php", ```php
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
```)

Halaman `/pos` memanggil `@extends('layouts.app')` untuk
mewarisi kerangka layout, lalu mengisi lubang `@section('content')`
dengan grid produk. Perhatikan `{{ $product->name }}`: kurung
kurawal ganda itu adalah sintaks output Blade, otomatis melakukan escaping
HTML supaya nama produk yang mengandung karakter seperti `<` tidak
bisa disalahgunakan untuk menyuntikkan markup asing ke halaman.

#warningbox[
Data yang berasal dari input pengguna, termasuk nama produk yang diketik
admin lewat form, selalu wajib ditampilkan lewat `{{ }}`, bukan
`{!! !!}`. Sintaks kedua melewati proses escaping sama sekali dan
membuka celah #emph[cross-site scripting] kalau isinya pernah datang dari
input yang tidak dipercaya.
]

== Praktik: Keranjang Belanja Dinamis dengan Alpine.js <sec:blade-dan-tailwind-3>

Menambahkan Alpine.js ke sebuah elemen dimulai dari atribut `x-data`,
yang mendeklarasikan state lokal dalam bentuk objek JavaScript langsung di
markup HTML. Elemen apa pun di dalam `x-data` itu, termasuk
elemen-elemen anaknya, bisa membaca dan mengubah state tersebut lewat
atribut Alpine lain seperti `@click` untuk event dan `x-text` untuk
menampilkan nilai reaktif.

#listing(```html
<div x-data="{ cart: [] }">
  <button @click="cart.push({ id: 1, price: 15000 })">
    Tambah
  </button>
  <span x-text="cart.length"></span> item di keranjang
</div>
```)

Potongan di atas cukup untuk menunjukkan mekanismenya: `cart` dimulai
sebagai array kosong, tombol #emph[Tambah] mendorong satu objek baru ke
dalamnya setiap kali diklik, dan `x-text="cart.length"` otomatis
memperbarui angka yang ditampilkan tanpa satu baris pun kode yang secara
eksplisit memerintahkan DOM untuk di-refresh. Alpine mengamati perubahan
pada `cart` dan menyinkronkan tampilan sendiri. Langkah-langkah
berikut memasang pola yang sama, pada skala sebenarnya, ke grid produk
`/pos` yang sudah dibuat di bagian sebelumnya.

+ Instal Alpine.js sebagai dependensi npm, bukan lewat CDN:

  #listing(```bash
  npm install alpinejs
    
  ```)

  Buka `resources/js/app.js`, lalu impor dan jalankan Alpine di
      sana:

  #listing(file: "resources/js/app.js", ```
  import Alpine from 'alpinejs';

  window.Alpine = Alpine;
  Alpine.start();
  ```)

  Karena `app.js` sudah dimuat lewat direktif `@vite` di
      `layouts/app.blade.php` (bagian sebelumnya), tidak ada tag
      `<script>` baru yang perlu ditambahkan; Vite membundel Alpine
      bersama kode aplikasi lainnya. Urutan pemuatan lewat bundler ini
      otomatis menghindari masalah yang biasanya diatasi atribut
      `defer` pada tag CDN: `Alpine.start()` baru terpanggil
      setelah seluruh modul termuat.
+ Buka `resources/views/pos/create.blade.php` (berkas yang
      sudah dibuat di bagian sebelumnya). Bungkus seluruh grid produk dengan
      satu `x-data` yang mendefinisikan `cart` sebagai array kosong
      beserta dua method, `addToCart` dan `subtotal`:

  #listing(file: "resources/views/pos/create.blade.php", ```html
  <div x-data="{
      cart: [],
      addToCart(id, name, price) {
          this.cart.push({ id, name, price });
      },
      subtotal() {
          return this.cart.reduce((sum, item) => sum + item.price, 0);
      }
  }">
    
  ```)
+ Pada tiap kartu produk di dalam `@foreach`, tambahkan
      `@click` yang memanggil `addToCart` dengan data produk baris
      itu:

  #listing(file: "resources/views/pos/create.blade.php", ```html
  <div class="border rounded-md p-3 cursor-pointer"
       @click="addToCart({{ $product->id }}, '{{ $product->name }}', {{ $product->price }})">
      <p class="font-medium">{{ $product->name }}</p>
      <p class="text-sm text-slate-500">Rp {{ number_format($product->price) }}</p>
  </div>
    
  ```)
+ Tambahkan area ringkasan keranjang di bawah grid, memakai
      `x-for` untuk menampilkan tiap item dan `x-text` untuk
      subtotal berjalan:

  #listing(file: "resources/views/pos/create.blade.php", ```html
  <div class="mt-4 border-t pt-3">
      <template x-for="item in cart" :key="item.id">
          <p x-text="item.name + ' - Rp ' + item.price"></p>
      </template>
      <p class="font-semibold mt-2">Subtotal: Rp <span x-text="subtotal()"></span></p>
  </div>
    
  ```)
+ Pastikan dua server berjalan bersamaan, di dua terminal terpisah:
      `php artisan serve` dan `npm run dev`. Lalu buka
      `http://127.0.0.1:8000/pos` di browser.
+ Klik salah satu kartu produk. #strong[Yang diharapkan]: nama dan
      harga produk itu langsung muncul di area ringkasan di bawah grid, dan
      angka subtotal bertambah, tanpa halaman ikut memuat ulang (perhatikan
      address bar dan favicon tab; keduanya tidak berkedip seperti saat
      reload).
+ #strong[Kalau klik tidak menghasilkan apa pun], periksa tiga hal
      paling umum: (a) buka console browser (F12), error
      `Alpine is not defined` berarti `npm run dev` tidak sedang
      berjalan, atau langkah 1 belum menyimpan perubahan pada
      `app.js`; (b) error `ViteManifestNotFoundException` di
      halaman itu sendiri berarti `npm run dev` belum dijalankan sama
      sekali; (c) pastikan seluruh grid produk, termasuk area ringkasan di
      langkah 4, benar-benar berada #emph[di dalam] elemen yang membawa
      `x-data` dari langkah 2, bukan jadi elemen bertetangga di luarnya.

Objek `x-data` inline di atas cukup untuk memahami mekanismenya, tapi
versi Simple POS yang sebenarnya mendaftarkan keranjang sebagai satu
komponen Alpine bernama lewat `Alpine.data('posCart', ...)` di dalam
`app.js`, lengkap dengan pemindaian SKU, diskon, dan penyimpanan
sementara ke `sessionStorage` supaya keranjang bertahan saat
berpindah halaman. Itu versi dewasa dari objek `x-data` yang baru saja
dibangun di sini, bukan konsep berbeda; tautan repositori di akhir bab ini
menunjukkan kode lengkapnya.

Subtotal yang dihitung Alpine di sisi klien murni untuk keperluan tampilan;
kasir perlu melihat angka berjalan sebelum transaksi disimpan. Angka itu
bukan sumber kebenaran. Setiap kali form kasir benar-benar dikirim ke
server, Simple POS menghitung ulang totalnya dari data produk dan jumlah
yang tersimpan di basis data, bukan dari angka yang sempat ditampilkan
Alpine di browser. Bab~6 akan menjelaskan alasannya lebih rinci: apa pun
yang berasal dari browser, termasuk hasil hitungan JavaScript yang terlihat
benar, tetap bisa dimanipulasi sebelum sampai ke server, dan tidak pernah
boleh dipercaya begitu saja untuk angka yang menyangkut uang.

#tipbox[
Aturan praktis yang berguna: logika yang murni kosmetik, seperti
menampilkan subtotal berjalan atau menyorot item yang baru ditambahkan,
aman ditaruh di Alpine.js. Logika yang menentukan keputusan bisnis, seperti
angka final yang tersimpan sebagai total transaksi atau apakah stok cukup
untuk memenuhi pesanan, wajib dihitung ulang di server, tidak peduli seberapa
meyakinkan angka yang sudah dihitung di klien.
]

#challengebox[
Tambahkan tombol #emph[Hapus] pada tiap baris item di keranjang, yang
memanggil sebuah method Alpine baru untuk mengeluarkan item itu dari array
`cart` berdasarkan `id`-nya. Setelah tombol berfungsi, jelaskan
dengan kata-katamu sendiri: kenapa menghapus item lewat Alpine saja, tanpa
mengirim apa pun ke server, sudah cukup aman di titik ini, padahal
angkanya tetap akan dihitung ulang saat form disimpan?
]

#branchref("chapter-03")

== Rangkuman <sec:blade-dan-tailwind-rangkuman>

- MPA memuat ulang seluruh halaman dari server tiap navigasi, SPA
      merender semuanya di klien lewat JavaScript, dan Blade dipadukan dengan
      Alpine.js mengambil jalan tengah: server tetap merender struktur
      halaman, Alpine hanya menambahkan reaktivitas pada bagian yang memang
      membutuhkannya, seperti keranjang belanja kasir.
- Layout Blade lewat `@extends`/`@section`/`@yield`
      menghindari pengulangan kerangka HTML, dan direktif `@vite` memuat
      Tailwind CSS serta JavaScript lewat Vite, dengan `npm run dev`
      memberi hot reload selama pengembangan.
- Alpine.js diinstal lewat `npm install alpinejs` dan dibundel
      Vite bersama kode aplikasi lain; atribut `x-data` mendeklarasikan
      state Alpine langsung di markup, `@click` dan `x-text` membaca
      serta mengubahnya secara reaktif, dan subtotal yang dihitung di klien
      tetap wajib diverifikasi ulang di server sebelum dipercaya sebagai
      angka final.

== Latihan

+ Buat satu berkas layout Blade baru dengan `@extends` dan
      `@yield('content')`, lalu buktikan satu halaman bisa mewarisinya
      tanpa menulis ulang tag `<html>` atau `<head>`.
+ Pada grid produk halaman `/pos`, tambahkan badge kecil yang
      menampilkan teks "Stok Menipis" memakai class Tailwind
      `bg-amber-100 text-amber-700`, muncul hanya ketika stok produk
      di bawah 10.
+ Jelaskan dengan kata-katamu sendiri: kenapa `{{ }}` lebih
      aman dipakai untuk menampilkan nama produk dibanding `{!! !!}`.
+ #strong[Evaluasi mandiri:] tanpa membuka kembali isi bab ini, coba
      jelaskan dengan kata-katamu sendiri: (a) perbedaan MPA dan SPA, (b)
      kenapa Simple POS memilih Blade + Alpine.js dibanding SPA penuh, dan
      (c) kenapa subtotal keranjang yang dihitung Alpine.js tidak boleh
      langsung dipercaya di server. Periksa kembali jawabanmu dengan isi bab
      ini.

== Referensi

Pembahasan pada bab ini merujuk pada dokumentasi resmi Laravel
#cite(<laraveldocs>) untuk konvensi Blade, serta dokumentasi Tailwind CSS
#cite(<tailwinddocs>) untuk sistem class utility yang dipakai sepanjang
Simple POS.
