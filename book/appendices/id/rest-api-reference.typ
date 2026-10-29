#import "/template.typ": *

= Referensi REST API <app:rest-api>

Lampiran ini merangkum endpoint REST API Simple POS yang dipakai oleh klien
kasir mobile, sebagaimana dibahas pada #xref(<ch:membangun-rest-api>). Seluruh
endpoint diawali dengan Sanctum sebagai lapisan autentikasi berbasis token.

== Autentikasi

#table(
    columns: (0.4fr, 1.4fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Method]], [#strong[Endpoint]], [#strong[Keterangan]],
    table.hline(stroke: 0.5pt),
    [POST], [`/api/login`], [Mengirim email dan password, mengembalikan token Sanctum],
    [POST], [`/api/logout`], [Mencabut token yang sedang dipakai (memerlukan header `Authorization`)],
    table.hline(stroke: 0.8pt),
  )

#notebox[
Setiap permintaan ke endpoint yang dilindungi wajib menyertakan header
`Authorization: Bearer <token>`, dengan `<token>` adalah nilai
yang dikembalikan oleh `POST /api/login`.
]

== Produk

#table(
    columns: (0.4fr, 1.4fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Method]], [#strong[Endpoint]], [#strong[Keterangan]],
    table.hline(stroke: 0.5pt),
    [GET], [`/api/products`], [Mengambil daftar produk beserta stok dan harga],
    table.hline(stroke: 0.8pt),
  )

== Transaksi

#table(
    columns: (0.4fr, 1.4fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Method]], [#strong[Endpoint]], [#strong[Keterangan]],
    table.hline(stroke: 0.5pt),
    [POST], [`/api/transactions`], [Membuat transaksi baru; total dihitung server-side],
    [GET], [`/api/transactions`], [Mengambil daftar transaksi milik pengguna yang sedang masuk],
    [GET], [`/api/transactions/{id}`], [Mengambil detail satu transaksi],
    table.hline(stroke: 0.8pt),
  )

#warningbox[
Sama seperti pada versi web, `POST /api/transactions` tidak pernah
menerima nilai total dari klien. Total tetap dihitung ulang di server dari
harga produk dan kuantitas, mengikuti prinsip yang sama seperti pada
#xref(<ch:validasi-input>).
]
