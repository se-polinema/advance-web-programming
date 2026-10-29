#import "/template.typ": *

= Referensi Perintah Artisan dan Composer <app:cli>

Lampiran ini merangkum perintah antarmuka baris perintah (CLI) yang paling
sering dipakai sepanjang buku. Semua perintah dijalankan dari direktori
proyek Simple POS, kecuali disebutkan lain.

== Menyiapkan Proyek

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Perintah]], [#strong[Fungsi]],
    table.hline(stroke: 0.5pt),
    [`composer install`], [Memasang dependensi PHP dari `composer.json`],
    [`php artisan key:generate`], [Membuat kunci enkripsi aplikasi],
    [`php artisan migrate:fresh --seed`], [Menjalankan ulang seluruh migrasi lalu mengisi data seed],
    [`php artisan serve`], [Menjalankan server pengembangan lokal],
    [`composer run dev`], [Menjalankan server pengembangan, Vite, queue listener, dan tail log sekaligus di satu terminal],
    table.hline(stroke: 0.8pt),
  )

== Migrasi dan Basis Data

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Perintah]], [#strong[Fungsi]],
    table.hline(stroke: 0.5pt),
    [`php artisan make:migration create_products_table`], [Membuat berkas migrasi baru],
    [`php artisan migrate`], [Menjalankan migrasi yang belum dieksekusi],
    [`php artisan migrate:rollback`], [Membatalkan batch migrasi terakhir],
    [`php artisan db:seed`], [Menjalankan seeder tanpa mengulang migrasi],
    table.hline(stroke: 0.8pt),
  )

== Membuat Berkas Kerangka

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Perintah]], [#strong[Fungsi]],
    table.hline(stroke: 0.5pt),
    [`php artisan make:model Product -mfs`], [Membuat model beserta migrasi, factory, dan seeder],
    [`php artisan make:controller ProductController`], [Membuat controller baru],
    [`php artisan make:request StoreProductRequest`], [Membuat kelas FormRequest],
    [`php artisan make:middleware EnsureUserHasRole`], [Membuat middleware kustom],
    table.hline(stroke: 0.8pt),
  )

== Pengujian dan Pemeliharaan

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Perintah]], [#strong[Fungsi]],
    table.hline(stroke: 0.5pt),
    [`php artisan test`], [Menjalankan seluruh test fitur dan unit],
    [`php artisan route:list`], [Menampilkan seluruh route terdaftar],
    [`php artisan config:cache`], [Menyimpan konfigurasi ke cache untuk produksi],
    [`php artisan route:cache`], [Menyimpan route ke cache untuk produksi],
    table.hline(stroke: 0.8pt),
  )
