#import "/template.typ": *

= Pengujian dan Kualitas Aplikasi <ch:pengujian-aplikasi>

#chapterhero("orange", [Baca anatomi test fitur Simple POS yang sudah ada, jalankan sebagai gerbang kualitas, lalu susun checklist milestone sebelum melangkah ke bab berikutnya.], [#icon("vial")#h(1em)13 feature test], [#icon("check-circle")#h(1em)`php artisan test`], [#icon("bug")#h(1em)checklist milestone])

Petugas quality control di pabrik tidak menunggu produk sampai ke tangan
pembeli untuk tahu ada yang cacat. Ia berdiri di ujung jalur produksi,
mengambil sampel dari setiap batch, menjalankan pemeriksaan yang sama
persis setiap kali, dan menahan batch itu di pabrik begitu ada satu saja
yang tidak lolos. Pemeriksaan itu tidak butuh insting atau tebakan;
checklist-nya sudah baku, dan hasilnya selalu berupa jawaban tegas: lolos
atau tidak. Test fitur pada Simple POS bekerja dengan peran yang sama.
Setiap kali kode berubah, entah menambah fitur baru atau memperbaiki bug
lama, menjalankan `php artisan test` memberi jawaban tegas dalam
hitungan detik: perilaku yang sudah ada sebelumnya masih berjalan
sebagaimana mestinya, atau ada yang rusak di suatu tempat yang mungkin
tidak disadari sedang disentuh.

#strong[Yang Akan Kamu Pelajari]

+ menjelaskan cakupan 13 test fitur Simple POS (login/logout, otorisasi peran, transaksi POS, alur token API) dan apa yang divalidasi tiap kelompok test;
+ menjalankan `php artisan test` dan menafsirkan hasil 27 assertion untuk menentukan apakah sebuah perubahan kode memecahkan perilaku yang sudah ada;
+ menyusun checklist milestone untuk memverifikasi bahwa CRUD, autentikasi, dan otorisasi Simple POS berfungsi sebelum lanjut ke bab berikutnya.

== Anatomi Test Fitur Simple POS <sec:pengujian-aplikasi-1>

#istilahpenting[
/ Feature Test: Test yang menjalankan satu alur lengkap aplikasi, dari request HTTP masuk sampai respons keluar, berbeda dari unit test yang menguji satu fungsi terisolasi.
/ Assertion: Satu pernyataan pemeriksaan dalam test, misalnya "status respons harus 200" atau "stok produk harus berkurang 3", yang dinyatakan gagal kalau kenyataannya tidak cocok.
/ RefreshDatabase: Trait PHPUnit/Pest bawaan Laravel yang mengembalikan basis data test ke kondisi bersih sebelum setiap test dijalankan, mencegah satu test memengaruhi hasil test lain lewat data sisa.
/ Regresi: Perilaku lama yang sebelumnya berjalan benar, tapi rusak akibat perubahan kode baru, biasanya tidak disengaja dan tidak disadari sampai test gagal.
]

13 test fitur Simple POS terbagi ke empat kelompok, masing-masing
menguji satu potongan perilaku yang sudah dibahas di bab-bab
sebelumnya: autentikasi (login berhasil, login gagal, logout), otorisasi
berbasis peran (admin bisa mengakses halaman produk, kasir diblokir),
transaksi POS (stok berkurang sesuai qty, total dihitung benar dari
harga produk), dan alur token API (login API mengembalikan token, token
yang salah ditolak).

#listing(file: "tests/Feature/ProductAuthorizationTest.php", ```php
public function test_kasir_cannot_access_admin_pages(): void
{
    $kasir = User::factory()->create(['role' => 'kasir']);

    $response = $this->actingAs($kasir)->get('/products');

    $response->assertForbidden();
}
```)

`actingAs($kasir)` mensimulasikan request seolah dikirim oleh
pengguna `$kasir` yang sudah login, tanpa benar-benar mengisi
form login; ini yang membuat feature test bisa menguji middleware
`role:admin` dari Bab~7 secara langsung.
`assertForbidden()` adalah satu assertion, memeriksa bahwa
respons benar-benar berstatus 403. `RefreshDatabase` yang
dipasang di kelas test memastikan `$kasir` yang baru dibuat
di test ini tidak bocor ke test lain yang berjalan setelahnya.

== Menjalankan dan Menafsirkan Hasil Test <sec:pengujian-aplikasi-2>

#listing(```bash
php artisan test

   PASS  Tests\Feature\AuthenticationTest
  [x] user can login with valid credentials
  [x] user cannot login with invalid credentials

   PASS  Tests\Feature\TransactionTest
  [x] stock decrements after transaction

  Tests:    13 passed (27 assertions)
  Duration: 1.42s
```)

Baris `Tests: 13 passed (27 assertions)` adalah ringkasan yang
paling penting dibaca lebih dulu: 13 adalah jumlah fungsi test yang
dijalankan, 27 adalah jumlah pernyataan pemeriksaan individual di dalam
seluruh test itu (satu fungsi test bisa berisi lebih dari satu
assertion, seperti pada `test_kasir_cannot_access_admin_pages`
di atas kalau ditambah pemeriksaan pesan error). Semua tanda centang
hijau berarti seluruh perilaku yang diuji masih berjalan seperti yang
diharapkan.

#warningbox[
Test yang gagal setelah sebuah perubahan kode bukan gangguan yang harus
dilewati begitu saja; ia adalah tepat sinyal yang seharusnya dicari:
regresi. Kalau
`test_stock_decrements_after_transaction` tiba-tiba gagal
setelah controller transaksi diubah, itu berarti perubahan itu merusak
perilaku pengurangan stok yang sebelumnya benar, terlepas dari apakah
perubahan itu ditujukan untuk fitur lain sama sekali.
]

== Praktik: Checklist Milestone Sebelum Lanjut <sec:pengujian-aplikasi-3>

13 test fitur ini menutup fitur-fitur inti sampai Bab~9, tapi tidak
seluruh perilaku Simple POS punya test otomatis. Checklist manual
mengisi celah itu, terutama untuk hal-hal yang lebih mudah diperiksa
lewat browser daripada ditulis sebagai assertion. Langkah-langkah
berikut menjalankan seluruh test yang sudah ada, sengaja merusak salah
satu untuk melihat kegagalannya, lalu menuntaskan checklist manual.

+ Lihat lokasi test yang sudah ada:
      `tests/Feature/AuthenticationTest.php`,
      `tests/Feature/TransactionTest.php`, dan berkas
      serupa lainnya di `tests/Feature/`. Setiap berkas menguji satu
      kelompok perilaku, sesuai anatomi pada bagian sebelumnya.
+ Jalankan seluruh suite untuk memastikan baseline masih hijau:

  #listing(```bash
  php artisan test
    
  ```)

  #strong[Yang diharapkan]: keluaran seperti pada bagian sebelumnya,
      `13 passed (27 assertions)`.
+ Buka `app/Http/Controllers/TransactionController.php`,
      ubah sengaja baris pengurangan stok (misalnya ganti
      `$product->decrement('stock', $qty)` menjadi
      `$product->increment('stock', $qty)`, kebalikannya).
+ Jalankan ulang `php artisan test`. #strong[Yang
      diharapkan]: baris `Tests: 13 passed` berubah menjadi
      memuat setidaknya `1 failed`, dengan nama
      `test_stock_decrements_after_transaction` muncul
      ditandai gagal, disertai pesan yang membandingkan nilai stok yang
      diharapkan dengan nilai yang benar-benar didapat.
+ Kembalikan baris yang diubah di langkah 3 ke bentuk semula
      (`decrement`), jalankan `php artisan test` sekali
      lagi, dan pastikan kembali ke `13 passed`.
+ Tuntaskan checklist manual berikut satu per satu, langsung di
      browser:

  + Buat, ubah, lalu hapus satu produk lewat `/products`.
            #strong[Yang diharapkan]: ketiga aksi berhasil tanpa galat.
  + Login sebagai admin, logout, login sebagai kasir, logout
            lagi. #strong[Yang diharapkan]: setelah logout, membuka
            halaman yang butuh login (mis. `/dashboard`) langsung
            mengarahkan kembali ke form login.
  + Login sebagai kasir, buka `/products`.
            #strong[Yang diharapkan]: halaman 403, sesuai Bab~7.
  + Catat satu transaksi lewat `/pos`, bandingkan stok
            produk sebelum dan sesudah di `/products`.
            #strong[Yang diharapkan]: stok berkurang persis sebanyak qty
            yang dibeli.
+ #strong[Kalau test di langkah 4 tidak menunjukkan kegagalan
      sama sekali] setelah perubahan sengaja di langkah 3, periksa apakah
      baris yang diubah benar-benar baris yang dieksekusi saat transaksi
      disimpan (bukan baris pada method lain yang serupa, mis. method
      pembatalan transaksi).

#tipbox[
Jalankan `php artisan test` sebelum memulai perubahan signifikan,
bukan hanya sesudahnya. Baseline "semua hijau" sebelum perubahan
membuat kegagalan test setelahnya tidak ambigu; kalau test yang sama
sudah gagal sebelum perubahan apa pun dimulai, kegagalan itu bukan
akibat dari perubahan yang baru saja ditulis.
]

#branchref("chapter-10")

== Rangkuman <sec:pengujian-aplikasi-rangkuman>

- 13 test fitur Simple POS terbagi ke empat kelompok
      (autentikasi, otorisasi peran, transaksi POS, alur token API),
      masing-masing memakai `actingAs()` untuk mensimulasikan
      pengguna login dan `RefreshDatabase` untuk menjaga
      isolasi antar-test.
- `php artisan test` melaporkan 13 test dan 27 assertion;
      test yang gagal setelah perubahan kode adalah sinyal regresi,
      bukan gangguan yang boleh diabaikan.
- Checklist milestone manual, seperti verifikasi CRUD produk dan
      dekremen stok lewat browser langsung, melengkapi cakupan test
      otomatis sebelum melangkah ke bab berikutnya.

== Latihan

+ Jalankan `php artisan test` dan baca hasilnya baris per
      baris, catat kelompok test mana yang menguji perilaku dari Bab~7.
+ Ubah sengaja satu baris logika pada perhitungan total transaksi
      (Bab~6) sampai salah, jalankan test lagi, dan amati test mana yang
      gagal serta pesan error apa yang ditampilkan.
+ Tulis checklist milestone versi sendiri untuk fitur yang belum
      ada test otomatisnya di Simple POS, minimal tiga butir.
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) perbedaan feature test dan unit
      test, (b) mengapa `RefreshDatabase` dibutuhkan, dan (c)
      mengapa test yang gagal setelah perubahan kode disebut sinyal
      regresi. Cocokkan jawabanmu dengan isi bab ini.

#challengebox[
Tulis satu test fitur baru untuk endpoint laporan penjualan pada
Bab~8, memverifikasi bahwa filter rentang tanggal benar-benar
mengecualikan transaksi di luar rentang itu.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel #cite(<laraveldocs>) untuk
feature testing dan `RefreshDatabase`.
