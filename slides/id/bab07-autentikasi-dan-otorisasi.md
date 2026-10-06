---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    padding: 56px 72px;
    justify-content: center;
  }
  section.lead {
    background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 55%, #2563eb 100%);
    color: #fff;
    justify-content: center;
  }
  section.lead h1, section.lead h2, section.lead p {
    color: #fff;
  }
  section.divider {
    background: #1d4ed8;
    color: #fff;
  }
  section.divider h1 {
    color: #fff;
    font-size: 2.2em;
  }
  section.divider h2 {
    color: #fff;
  }
  section.divider p {
    color: #bfdbfe;
  }
  h1 {
    color: #1d4ed8;
    font-size: 1.6em;
  }
  h2 {
    color: #1d4ed8;
  }
  table {
    font-size: 0.72em;
    width: 100%;
  }
  table.small {
    font-size: 0.75em;
  }
  th, td {
    padding: 4px 10px;
  }
  th {
    background: #1d4ed8;
    color: #fff;
  }
  code {
    background: #f1f5f9;
    color: #0f172a;
  }
  pre {
    font-size: 0.68em;
  }
  .term-box {
    border-left: 6px solid #1d4ed8;
    background: #eff6ff;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.82em;
  }
  .term-box b {
    color: #1d4ed8;
  }
  .tip-box {
    border-left: 6px solid #16a34a;
    background: #f0fdf4;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .warn-box {
    border-left: 6px solid #dc2626;
    background: #fef2f2;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .cols {
    display: flex;
    gap: 24px;
  }
  .cols > div {
    flex: 1;
  }
  .flow {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-top: 30px;
    flex-wrap: wrap;
  }
  .flow .box {
    background: #1d4ed8;
    color: #fff;
    padding: 12px 18px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 0.85em;
  }
  .flow .arrow {
    font-size: 1.4em;
    color: #1d4ed8;
  }
  .stack .box {
    background: #1d4ed8;
    color: #fff;
    padding: 10px;
    border-radius: 6px;
    text-align: center;
    margin: 4px 0;
    font-weight: bold;
  }
  .footnote {
    font-size: 0.55em;
    color: #64748b;
    position: absolute;
    bottom: 20px;
  }
  .ref-link {
    display: inline-block;
    font-size: 0.62em;
    color: #1d4ed8;
    background: #eff6ff;
    border-left: 4px solid #93c5fd;
    border-radius: 0 6px 6px 0;
    padding: 6px 14px;
    margin-top: 14px;
  }
  .ref-link code {
    background: transparent;
    color: #1d4ed8;
  }
---

<!-- _class: lead -->

# Pemrograman Web Lanjut
## SIB245007 &nbsp;|&nbsp; D-IV Sistem Informasi Bisnis

Pertemuan 7: **Autentikasi, Otorisasi, dan RBAC**

Siapa kamu, apa yang boleh kamu lakukan, dan bagaimana memeriksanya di setiap request

---

## Yang Akan Kamu Pelajari

1. Membedakan **autentikasi** (membuktikan identitas) dan **otorisasi** (menentukan izin), serta mengapa keduanya perlu dipisah

2. Memahami bagaimana **sesi**, **cookie**, dan fitur terkait (remember me, lupa kata sandi, pembatasan percobaan login) membuat login terasa aman dan nyaman

3. Mengenali aturan dasar penyimpanan **kata sandi** dan **RBAC** (kontrol akses berbasis peran) lewat **middleware**, **Gate**, dan **Policy**

<div class="tip-box">
Slide ini membahas konsep. Implementasi login dan pembatasan peran pada Simple POS dikerjakan di jobsheet praktikum.
</div>

---

<!-- _class: divider -->

# Bagian 1
## Autentikasi: Membuktikan Identitas

---

## Dua Pertanyaan yang Berbeda

<div class="cols">
<div>

**Autentikasi**
- Pertanyaannya: "kamu siapa?"
- Dibuktikan lewat email dan kata sandi
- Hasilnya: identitas pengguna diketahui

</div>
<div>

**Otorisasi**
- Pertanyaannya: "kamu boleh apa?"
- Dicek setelah identitas diketahui
- Hasilnya: halaman atau aksi tertentu diizinkan atau ditolak

</div>
</div>

<div class="tip-box">
Pegawai yang kartunya sah di lobi tetap bisa ditolak di ruang server. Lobi mengecek identitas, ruang server mengecek izin.
</div>

---

## Mengapa HTTP Butuh Sesi

<div class="term-box">
<b>Stateless:</b> setiap request HTTP berdiri sendiri. Server tidak otomatis ingat request sebelumnya, walaupun dari browser yang sama.
</div>

- Tanpa mekanisme tambahan, setiap halaman terlihat seperti dibuka oleh orang asing
- Sesi memberi server cara mengingat pengguna di antara request, tanpa meminta login ulang di setiap halaman

---

## Alur Login dengan Sesi

<div class="flow">
  <div class="box">Form login</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Server cek email dan hash</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Simpan sesi</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Kirim cookie</div>
</div>

- Request berikutnya membawa cookie yang sama, server mencari sesinya, lalu tahu siapa pengguna itu
- Cookie hanya berisi ID sesi, data penggunanya tetap tersimpan di server

---

## Cookie dan ID Sesi

<div class="term-box">
<b>Sesi:</b> data pengguna yang login, disimpan di server dan diidentifikasi oleh satu ID acak yang dikirim lewat cookie.
</div>

- ID sesi harus sulit ditebak, karena siapa pun yang memegangnya bisa berpura-pura menjadi pengguna itu
- Cookie yang sensitif sebaiknya diberi flag `HttpOnly` (tidak bisa dibaca JavaScript) dan `Secure` (hanya lewat HTTPS)

---

## Remember Me: Login yang Bertahan

<div class="term-box">
<b>Remember Me:</b> cookie tambahan berumur panjang (berminggu-minggu) yang membuat pengguna tetap login walau sesinya di server sudah berakhir, misalnya setelah menutup browser.
</div>

- Cookie ini membawa token acak terpisah, bukan sesi biasa dan bukan kata sandi, disimpan di kolom seperti `remember_token` pada tabel pengguna
- Begitu pengguna kembali, server mencocokkan token itu, membuat sesi baru, lalu menggantinya dengan token baru lagi
- Karena umurnya panjang, centang "Remember Me" sebaiknya jadi pilihan pengguna sendiri, bukan perilaku default

---

## Session vs Token

<div class="cols">
<div>

**Sesi (server menyimpan)**
- Server menyimpan status login
- Cabut akses cukup hapus sesinya
- Cocok untuk aplikasi web dengan halaman di browser

</div>
<div>

**Token (klien menyimpan)**
- Klien membawa bukti identitas yang ditandatangani
- Server tidak perlu menyimpan status login
- Cocok untuk API yang dipakai banyak klien, dibahas lebih lanjut nanti

</div>
</div>

---

## Kata Sandi Tidak Pernah Disimpan Mentah

<div class="term-box">
<b>Hash:</b> hasil fungsi satu arah dari kata sandi, ditambah salt acak, sehingga kata sandi asli tidak bisa dibaca kembali dari basis data.
</div>

- Kalau basis data bocor, penyerang hanya mendapat hash, bukan kata sandi yang bisa langsung dipakai
- Saat login, server menghitung hash dari kata sandi yang diketik lalu membandingkannya dengan hash tersimpan

---

## Lupa Kata Sandi

Karena kata sandi disimpan sebagai hash, server sendiri tidak bisa membacanya untuk dikirim ulang lewat email. Solusinya bukan mengirim kata sandi lama, melainkan memberi kesempatan membuat kata sandi baru:

<div class="flow">
  <div class="box">Minta reset</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Token sekali pakai dikirim ke email</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Isi kata sandi baru</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Token diperiksa, hash baru disimpan</div>
</div>

- Token reset harus kedaluwarsa dalam waktu singkat dan hanya bisa dipakai sekali, persis seperti ID sesi yang diregenerasi setelah login
- Link reset dikirim lewat email, bukan ditampilkan langsung di halaman, supaya hanya pemilik email asli yang bisa memakainya

---

## Mengapa Hashing Sengaja Dibuat Lambat

- Hashing yang cepat membuat penyerang bisa mencoba miliaran tebakan per detik
- Algoritma password modern (bcrypt, argon2) sengaja dibuat lambat dan bisa dinaikkan biayanya seiring perangkat makin cepat
- Di Laravel, `Hash::make()` memakai algoritma yang diatur di konfigurasi, dan jangan pernah menulis fungsi hash sendiri

---

## Membatasi Percobaan Login

Hashing yang lambat memperlambat penyerang yang punya salinan basis data. Tapi penyerang yang hanya menebak lewat form login butuh pertahanan lain: membatasi berapa kali percobaan login boleh dilakukan dalam waktu tertentu.

```php
Route::post('/login', [LoginController::class, 'store'])
    ->middleware('throttle:5,1');
```

- Kode di atas membatasi maksimal 5 percobaan per menit dari sumber yang sama, percobaan ke-6 langsung ditolak tanpa mengecek kata sandinya
- Sama seperti hashing yang lambat, tujuannya membuat serangan coba-coba makan waktu sangat lama, bukan mencegahnya sepenuhnya

---

## Session Fixation

<div class="warn-box">
Serangan session fixation: penyerang memberi korban ID sesi yang sudah dia ketahui sebelum login. Begitu korban login, sesi yang sama ikut menjadi milik penyerang.
</div>

- Cara mencegahnya: buat ID sesi baru tepat setelah login berhasil, lalu hapus ID lama
- Di Laravel, ini dilakukan dengan `session()->regenerate()` setelah `Auth::attempt()` berhasil

---

<!-- _class: divider -->

# Bagian 2
## Otorisasi dan RBAC

---

## Otorisasi: Izin Setelah Identitas Terbukti

<div class="term-box">
<b>Otorisasi:</b> keputusan apakah pengguna yang sudah terautentikasi boleh melakukan satu aksi tertentu pada satu sumber daya tertentu.
</div>

- Identitas yang benar belum berarti izin yang benar
- Contoh: editor boleh mengedit artikel, pembaca biasa hanya boleh membacanya

---

## Peran, Bukan Pengguna Satu per Satu

<div class="flow">
  <div class="box">Pengguna</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Peran (admin / editor / pembaca)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Izin</div>
</div>

<div class="term-box" style="margin-top:30px;">
<b>RBAC (Role-Based Access Control):</b> izin dikaitkan ke peran, lalu pengguna mendapat izin lewat peran yang dimilikinya.
</div>

- Menambah pengguna baru cukup memberinya peran, tidak perlu mengatur izin satu per satu

---

## Middleware sebagai Pos Pemeriksaan

<div class="flow">
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">auth: sudah login?</div>
  <div class="arrow">&rarr;</div>
  <div class="box">role: peran sesuai?</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Controller</div>
</div>

- Middleware memeriksa request sebelum sampai ke controller, dipasang pada route atau grup route
- Urutannya penting: pastikan sudah login dulu, baru memeriksa peran

---

## 401 vs 403

<div class="cols">
<div>

**401 Unauthorized**
- Belum ada identitas yang terbukti
- Solusinya: login dulu
- Di browser, Laravel menjawabnya dengan mengarahkan ke halaman login

</div>
<div>

**403 Forbidden**
- Identitas sudah diketahui, tetapi tidak punya izin
- Solusinya: bukan login ulang, melainkan izin yang berbeda

</div>
</div>

---

## Route yang Lupa Dilindungi

<div class="warn-box">
Middleware hanya melindungi route yang benar-benar memakainya. Route admin baru yang ditambahkan di luar grup yang dilindungi bisa diakses siapa pun yang sudah login, tanpa peduli perannya.
</div>

- Kesalahan ini tidak terlihat saat pengujian, kalau yang mengecek selalu login sebagai admin
- Cara mencegahnya: uji juga dengan akun peran lain, bukan hanya akun admin

---

## Gate: Aturan Otorisasi Sederhana

<div class="term-box">
<b>Gate:</b> aturan otorisasi berbentuk closure, didaftarkan dengan nama, dan dipanggil lewat nama itu di mana pun dibutuhkan.
</div>

```php
Gate::define('kelola-produk', function (User $user) {
    return $user->role === 'admin';
});

Gate::authorize('kelola-produk');
```

- Cocok untuk aturan yang tidak terikat ke satu baris data tertentu, misalnya "siapa boleh membuka halaman pengaturan"
- Middleware memeriksa di level route, Gate bisa dipanggil di mana saja di dalam kode, termasuk di tengah controller

---

## Policy: Otorisasi per Model

<div class="term-box">
<b>Policy:</b> class yang mengumpulkan semua aturan otorisasi untuk satu model, satu method per aksi (<code>view</code>, <code>update</code>, <code>delete</code>, dst.).
</div>

```php
class ArticlePolicy
{
    public function update(User $user, Article $article): bool
    {
        return $user->id === $article->author_id;
    }
}
```

- Dibuat lewat `php artisan make:policy ArticlePolicy --model=Article`, lalu dipanggil dengan `Gate::authorize('update', $article)`
- Method menerima baris data yang sebenarnya, jadi aturannya bisa berbeda untuk tiap baris, bukan cuma berdasarkan peran

---

## Middleware vs Policy: Kapan Pakai Apa

<div class="cols">
<div>

**Middleware**
- Pertanyaannya: "boleh masuk ke route ini?"
- Diperiksa sebelum controller, untuk seluruh request
- Cocok untuk aturan berbasis peran, sama untuk semua baris data

</div>
<div>

**Policy**
- Pertanyaannya: "boleh melakukan ini pada baris data ini?"
- Diperiksa di dalam controller, untuk satu baris data tertentu
- Cocok untuk aturan kepemilikan, misalnya "hanya penulis asli yang boleh mengedit"

</div>
</div>

<div class="tip-box">
Middleware <code>role:admin</code> yang kamu buat di jobsheet menjawab pertanyaan pertama. Begitu aplikasi kasir butuh aturan seperti "kasir hanya boleh membatalkan transaksinya sendiri", itu pertanyaan kedua, pekerjaan Policy.
</div>

---

## Memeriksa Izin di Blade: @can dan @cannot

```php
@can('update', $article)
    <a href="{{ route('articles.edit', $article) }}">Edit</a>
@endcan

@cannot('update', $article)
    <p>Kamu tidak bisa mengedit artikel ini.</p>
@endcannot
```

- `@can`/`@cannot` memanggil Gate atau Policy yang sama, jadi aturannya tidak pernah ditulis dua kali
- Sama seperti `@if (auth()->user()?->isAdmin())` yang menyembunyikan menu admin di navigasi, `@can` hanya menyembunyikan tampilan, pemeriksaan sungguhan tetap wajib dilakukan lagi di controller atau route

---

<!-- _class: divider -->

# Bagian 3
## Pilihan Paket dan Perbandingan Lintas Framework

---

## Tiga Pendekatan di Laravel

| Pendekatan | Kompleksitas setup | Cocok untuk |
|---|---|---|
| Middleware kustom | Rendah | Peran sederhana dan tetap, misalnya 2 sampai 3 peran |
| Laravel Breeze | Sedang | Autentikasi siap pakai beserta tampilan login dan register |
| Spatie Permission | Sedang sampai tinggi | Izin sangat rinci per aksi dengan banyak kombinasi peran |

<div class="ref-link">Dokumentasi resmi: <code>laravel.com/docs/authentication</code></div>

---

## Kapan Memilih Apa

- Middleware kustom cukup selama peran sedikit dan jarang berubah
- Breeze menghemat waktu membangun halaman login dan register, tetapi tetap perlu dipahami isinya
- Spatie Permission masuk akal saat izin harus dibagi per cabang, per data, atau per aksi
- Mulai dari yang paling sederhana, lalu naik ke paket yang lebih besar saat kebutuhan nyata muncul

---

## Perbandingan Lintas Framework

| Framework | Autentikasi bawaan | Pendekatan umum untuk otorisasi |
|---|---|---|
| Laravel | Auth, session, middleware | Middleware, Gate/Policy, paket seperti Spatie |
| Django | Auth dengan user, group, dan permission | Permission per model dan group |
| Express (Node.js) | Tidak ada, memakai paket | Passport.js atau JWT, middleware kustom |
| Next.js | Tidak ada, memakai paket | Library seperti Auth.js (NextAuth) |

---

## Rangkuman (1/3)

- Autentikasi menjawab "kamu siapa", otorisasi menjawab "kamu boleh apa"; keduanya dicek terpisah
- Sesi dan cookie membuat HTTP yang stateless bisa mengingat pengguna; cookie hanya membawa ID sesi, remember me memakai cookie terpisah berumur panjang
- Kata sandi disimpan sebagai hash, dan setelah login sesi harus diperbarui (regenerate) untuk mencegah session fixation

---

## Rangkuman (2/3)

- Lupa kata sandi diselesaikan lewat token reset sekali pakai yang dikirim ke email, bukan mengirim ulang kata sandi lama
- Membatasi percobaan login (throttle) memperlambat tebakan brute-force, sama seperti hashing yang sengaja dibuat lambat
- RBAC mengaitkan izin ke peran, dan middleware menjadi pos pemeriksaan di level route sebelum controller

---

## Rangkuman (3/3)

- Gunakan 401 untuk belum login dan 403 untuk sudah login tetapi tidak berwenang
- Gate menjawab aturan sederhana yang tidak terikat satu baris data, Policy menjawab aturan per baris data (misalnya kepemilikan); `@can`/`@cannot` di Blade memanggil aturan yang sama
- Pilih paket sesuai kebutuhan: middleware kustom untuk peran sederhana, Breeze untuk autentikasi siap pakai, Spatie untuk izin yang sangat rinci

---

<!-- _class: lead -->

# Referensi & Diskusi

Dokumentasi resmi Laravel (Authentication, Authorization, Middleware)

Kode lengkap: `github.com/se-polinema/simple-pos-ch07`

**Pertemuan berikutnya:** UTS (Evaluasi Progres Proyek PBL)
