#import "/template.typ": *

= Protokol HTTP dan Pola MVC <ch:http-dan-mvc>

#chapterhero("blue", [Petakan siklus request/response HTTP ke pola MVC, lalu tulis route dan controller pertama Simple POS.], [#icon("route")#h(1em)siklus HTTP], [#icon("sitemap")#h(1em)MVC vs MVVM], [#icon("code")#h(1em)route & controller])

Sepucuk surat yang dikirim ke sebuah kantor tidak langsung sampai ke meja
orang yang dituju. Ia masuk lewat loket penerimaan, petugas loket membaca
alamat dan jenis suratnya (surat biasa, paket, kilat khusus), lalu
meneruskannya ke bagian yang tepat: bagian keuangan kalau amplopnya
bertuliskan "tagihan", bagian personalia kalau isinya lamaran kerja.
Petugas loket sendiri tidak pernah membuka amplop atau memutuskan isi
balasannya; tugasnya murni menyortir dan meneruskan. Setiap kali Simple POS
menerima permintaan dari browser, entah kasir menekan tombol "Simpan
Transaksi" atau admin membuka halaman laporan, permintaan itu mengalami
proses yang persis sama: masuk lewat satu pintu, disortir berdasarkan
alamat dan jenisnya, diteruskan ke bagian yang tepat untuk diproses. Kalau
proses penyortiran ini keliru, misalnya permintaan hapus produk diteruskan
ke bagian yang tidak memeriksa apakah pengirimnya seorang admin, kios
kehilangan kendali atas siapa yang boleh mengubah apa.

#strong[Yang Akan Kamu Pelajari]

+ menjelaskan siklus request/response HTTP (method, status code, header) dan memetakannya ke potongan kode route Simple POS;
+ membandingkan pola MVC, MVVM, dan Clean Architecture, serta menjelaskan bagaimana Laravel mengimplementasikan MVC pada praktiknya;
+ menulis route dan controller untuk endpoint `/pos` dan `/transactions` pada Simple POS, termasuk pemisahan route web dari middleware group-nya.

== Siklus Request/Response HTTP <sec:http-dan-mvc-1>

#istilahpenting[
/ Request: Permintaan yang dikirim browser ke server, berisi method, alamat (URL), header, dan kadang data (form, JSON).
/ Response: Jawaban yang dikirim server kembali ke browser, berisi status code, header, dan isi (HTML, JSON, redirect).
/ Route: Aturan yang memetakan satu kombinasi method dan alamat URL ke kode yang akan menanganinya.
/ Controller: Class yang berisi method-method penanganan request, dipanggil oleh route yang cocok.
/ Middleware: Lapisan yang memeriksa atau mengubah request sebelum sampai ke controller, misalnya memeriksa apakah pengguna sudah login.
]

Setiap kali sebuah browser meminta halaman atau mengirim form, permintaan
itu berbentuk #term[request] HTTP yang selalu membawa sebuah #emph[method]
yang menyatakan maksud permintaan. Empat method yang paling sering muncul
sepanjang buku ini adalah `GET` (meminta data, tanpa mengubah apa pun di
server), `POST` (mengirim data baru, misalnya menyimpan transaksi
kasir), `PATCH` (mengubah sebagian data yang sudah ada), dan
`DELETE` (menghapus data). Server menjawab permintaan itu dengan
sebuah #term[response] yang selalu membawa #emph[status code], angka tiga
digit yang menyatakan hasil permintaan secara ringkas sebelum satu byte pun
dari isinya dibaca.

#figure(
  table(
    columns: (0.6fr, 1fr, 2fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Kode], [Arti], [Contoh pada Simple POS],
    table.hline(stroke: 0.5pt),
    [200], [OK], [Halaman `/transactions` berhasil ditampilkan],
    [302], [Redirect], [Setelah `/pos` disimpan, browser diarahkan ke halaman detail],
    [404], [Not Found], [Membuka `/transactions/9999` untuk ID yang tidak ada],
    [422], [Unprocessable Entity], [Form transaksi dikirim dengan stok yang tidak mencukupi],
    [500], [Server Error], [Kesalahan tak tertangani di sisi server],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Status code HTTP yang sering muncul pada Simple POS],
) <tab:status-code>

Kode 302 pantas mendapat perhatian khusus karena polanya berulang di hampir
setiap fitur tulis-data Simple POS: setelah `POST /pos` berhasil
menyimpan transaksi, server tidak langsung mengirim halaman HTML sebagai
jawaban, melainkan mengirim response 302 berisi header `Location` yang
memerintahkan browser meminta ulang ke alamat lain, dalam kasus ini halaman
detail transaksi yang baru dibuat. Pola kirim-lalu-redirect ini mencegah
pengguna menekan tombol #emph[refresh] dan tanpa sadar mengirim transaksi
yang sama dua kali.

#notebox[
Header request dan response membawa metadata di luar isi utamanya. Header
`Content-Type` memberi tahu format isi (`text/html`,
`application/json`); header `Authorization` pada Bab~9 akan
membawa token Sanctum untuk permintaan dari aplikasi kasir mobile.
]

== MVC, MVVM, dan Clean Architecture <sec:http-dan-mvc-2>

Menerima request dan mengirim response saja belum cukup untuk menjaga kode
tetap rapi begitu aplikasi tumbuh. #term[Pola MVC] (Model-View-Controller)
menjawab masalah itu dengan membagi tiga tanggung jawab secara tegas: Model
mengurus data dan aturan bisnis (misalnya bagaimana stok produk dihitung
ulang setelah transaksi), View mengurus tampilan yang dilihat pengguna, dan
Controller berdiri di tengah, menerima request, memanggil Model yang
relevan, lalu memilih View mana yang akan ditampilkan sebagai jawaban.
Kembali ke analogi kantor pos, Controller adalah petugas loket yang
menyortir, Model adalah arsip berisi data sesungguhnya, dan View adalah
formulir balasan yang akhirnya diserahkan ke pengirim.

#figure(
  table(
    columns: (0.9fr, 1.3fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Pola], [Pemisahan Utama], [Contoh Pemakaian],
    table.hline(stroke: 0.5pt),
    [MVC], [Model, View, Controller], [Laravel (bawaan)],
    [MVVM], [Model, View, ViewModel], [Aplikasi dengan binding dua arah antara tampilan dan state],
    [Clean Architecture], [Lapisan use case terisolasi dari framework], [Sistem berskala besar dengan banyak aturan bisnis],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Perbandingan MVC, MVVM, dan Clean Architecture],
) <tab:mvc-mvvm-clean>

#term[MVVM] (Model-View-ViewModel), yang populer pada aplikasi antarmuka
reaktif, menyisipkan ViewModel di antara Model dan View: ViewModel menyimpan
state tampilan dan otomatis menyinkronkannya ke View lewat binding dua arah,
sebuah pola yang lebih relevan untuk antarmuka yang berubah terus-menerus
tanpa reload halaman. #term[Clean Architecture] melangkah lebih jauh dengan
mengisolasi aturan bisnis inti (#emph[use case]) sepenuhnya dari framework
yang dipakai, sehingga aturan bisnis itu bisa diuji dan bahkan dipindah ke
framework lain tanpa disentuh. Untuk aplikasi seskala Simple POS, isolasi
seketat itu menambah lapisan abstraksi yang belum sepadan manfaatnya;
MVC bawaan Laravel sudah cukup rapi untuk memisahkan tanggung jawab tanpa
menambah kerumitan yang tidak dibutuhkan.

Pemetaan MVC ke struktur folder Laravel sudah disinggung sekilas di Bab~1:
`routes/web.php` mendaftarkan alamat mana yang ditangani controller
mana, `app/Http/Controllers/` menyimpan class Controller, model
Eloquent di `app/Models/` (dibahas penuh mulai Bab~5) berperan sebagai
Model, dan berkas Blade di `resources/views/` (dibahas mulai Bab~3)
berperan sebagai View.

== Praktik: Routing dan Controller Simple POS <sec:http-dan-mvc-3>

#heading(level: 3, numbering: none, outlined: false)[Praktik 2.1: Membuat Controller Transaksi]

#listing(```bash
php artisan make:controller TransactionController
```)

Perintah ini menghasilkan berkas `TransactionController` kosong di
`app/Http/Controllers/`, siap diisi method-method penanganan request.
Pada Simple POS, controller ini akhirnya memiliki empat method:
`create` menampilkan halaman kasir untuk memilih produk,
`store` menyimpan transaksi baru, `index` menampilkan
daftar transaksi, dan `show` menampilkan detail satu transaksi.

#listing(file: "routes/web.php", ```php
Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])
        ->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])
        ->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])
        ->name('transactions.index');
});
```)

Perhatikan bahwa `GET /pos` dan `POST /pos` adalah dua route
yang berbeda meski alamatnya sama persis: keduanya dibedakan oleh method
HTTP-nya, satu menampilkan formulir kasir, satu lagi memprosesnya. Keempat
route ini juga dibungkus dalam `Route::middleware('auth')->group(...)`,
artinya setiap permintaan ke dalamnya wajib melewati middleware
`auth` terlebih dahulu, sebuah lapisan pemeriksa yang memastikan
pengirim sudah login sebelum permintaannya diteruskan ke
`TransactionController`.

#warningbox[
Mendaftarkan route baru tanpa membungkusnya dalam #emph[middleware group]
yang sesuai adalah kesalahan yang mudah luput dari perhatian dan berakibat
serius: route yang seharusnya hanya bisa diakses admin, misalnya menghapus
kategori produk, akan bisa diakses siapa pun yang tahu alamatnya kalau
lupa dibungkus `Route::middleware('role:admin')->group(...)`. Selalu
periksa route baru berada di dalam group middleware yang benar sebelum
menganggapnya selesai.
]

Untuk memeriksa seluruh route yang sudah terdaftar, termasuk method dan
middleware-nya, Artisan menyediakan perintah yang menampilkan tabel
ringkas tanpa perlu membuka satu per satu berkas route:

#listing(```bash
php artisan route:list
```)

#challengebox[
Tambahkan satu route baru `GET /pos/riwayat` pada
`routes/web.php` yang mengarah ke method `riwayat` pada
`TransactionController`, dibungkus middleware `auth` yang
sama seperti route `/pos` lainnya. Method-nya boleh sementara hanya
mengembalikan teks biasa, misalnya `return "Riwayat kasir";`. Jalankan
`route:list` setelahnya dan pastikan route barumu muncul dengan
method dan middleware yang benar.
]

#branchref("chapter-02")

== Rangkuman <sec:http-dan-mvc-rangkuman>

- Setiap request HTTP membawa method (`GET`, `POST`,
      `PATCH`, `DELETE`) dan setiap response membawa status code tiga
      digit (200, 302, 404, 422, 500) yang menyatakan hasil permintaan
      sebelum isinya dibaca.
- MVC memisahkan Model (data dan aturan bisnis), View (tampilan), dan
      Controller (penyortir request); MVVM cocok untuk antarmuka reaktif,
      Clean Architecture cocok untuk sistem besar dengan aturan bisnis
      kompleks, dan Laravel memetakan MVC langsung ke
      `routes/`, `app/Http/Controllers/`, `app/Models/`, dan
      `resources/views/`.
- Route `/pos` dan `/transactions` pada Simple POS
      didaftarkan di `routes/web.php`, ditangani oleh
      `TransactionController`, dan dibungkus middleware `auth`
      supaya hanya pengguna yang sudah login yang bisa mengaksesnya.

== Latihan

+ Jalankan `route:list` pada proyek Simple POS hasil Bab~1,
      lalu identifikasi method HTTP apa saja yang dipakai untuk route
      `/pos`.
+ Tambahkan satu route baru `GET /pos/cetak-struk` yang untuk
      sementara hanya mengembalikan teks `"Struk"`, lalu verifikasi lewat
      `route:list` bahwa route itu muncul dengan alamat yang benar.
+ Jelaskan dengan kata-katamu sendiri: mengapa `GET /pos` dan
      `POST /pos` dianggap dua route yang berbeda meski alamat
      URL-nya identik.
+ #strong[Evaluasi mandiri:] tanpa membuka kembali isi bab ini, coba
      jelaskan dengan kata-katamu sendiri: (a) perbedaan tanggung jawab
      Model, View, dan Controller, (b) kapan status code 422 muncul pada
      Simple POS, dan (c) fungsi middleware `auth` pada sebuah route.
      Periksa kembali jawabanmu dengan isi bab ini.

== Referensi

Pembahasan pada bab ini merujuk pada dokumentasi resmi Laravel
#cite(<laraveldocs>) untuk konvensi routing dan controller, serta disertasi
Fielding #cite(<fielding2000rest>) untuk landasan semantik method dan status
code HTTP yang menjadi dasar arsitektur REST pada Bab~9.
