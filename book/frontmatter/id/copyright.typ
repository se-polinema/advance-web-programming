#import "/template.typ": *

// Copyright and imprint page (Katalog Dalam Terbitan, ISBN data).
#let card(title, body, fill: luma(250), height: auto) = block(
  width: 100%,
  height: height,
  fill: fill,
  stroke: 0.5pt + luma(115),
  radius: 1.5pt,
  inset: 7pt,
  breakable: false,
)[
  #set par(first-line-indent: 0pt, justify: false)
  #text(font: sans-font, weight: "bold")[#title]
  #v(0.25cm)
  #body
]

#page(
  margin: (x: 2cm, y: 1.8cm),
  header: none,
  footer: none,
  background: {
    place(top + left, dx: 1.3cm, dy: 1.3cm, rect(width: 15.5cm - 2.6cm, height: 2.7cm, fill: luma(245), stroke: none))
    place(top + left, dx: 1.5cm, dy: 1.5cm, rect(width: 15.5cm - 3cm, height: 23cm - 3cm, stroke: 0.9pt + luma(115)))
  },
)[
  #set par(first-line-indent: 0pt, justify: false)
  #set text(size: 9pt)
    #text(font: sans-font, size: 9pt, weight: "bold", tracking: 0.2em)[HAK CIPTA DAN IMPRINT]
  #v(0.3cm)
  #text(size: 14pt, weight: "bold")[Laravel Praktis]
  #linebreak()
  Membangun Aplikasi Kasir dari Nol
  #v(0.5cm)
  #card([Penulis], [Dian Hanifudin Subhi dan Ade Ismail], fill: luma(247))
  #v(0.3cm)
  #card([Pernyataan Hak Cipta], [
    Copyright © #datetime.today().year() Dian Hanifudin Subhi dan Ade Ismail. Hak cipta dilindungi undang-undang.
    #v(0.25cm)
    Dilarang memperbanyak, mencetak, mendistribusikan, atau menerbitkan sebagian maupun seluruh isi buku ini dalam bentuk dan dengan cara apa pun, baik mekanis maupun elektronis, termasuk fotokopi, rekaman, pemindaian, atau sistem penyimpanan dan temu kembali informasi, tanpa izin tertulis dari penerbit, kecuali untuk kutipan singkat dalam penulisan ilmiah, ulasan, atau kepentingan akademik yang wajar.
  ], fill: white)
  #v(0.3cm)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 0.4cm,
    card([Data Penerbit], [
      Polinema Press#linebreak()
      Politeknik Negeri Malang#linebreak()
      Jalan Soekarno-Hatta No.~9#linebreak()Malang 65141, Jawa Timur, Indonesia
      #v(0.2cm)
      Telepon: (0341) 404424#linebreak()
      Website: #link("https://www.polinema.ac.id")#linebreak()
      Email: info\@polinema.ac.id
    ], fill: luma(250), height: auto),
    card([Metadata Penerbitan], [
      ISBN: 978-623-XXXX-XX-X\
    Edisi: I (Pertama)\
    Cetakan: Ke-1, #datetime.today().year()\
    Ukuran Buku: 15,5 cm × 23 cm\
    Jumlah Halaman: -- (draft)\
    Desain Sampul: ---\
    Editor: ---\
    Tata Letak: ---
    ], fill: luma(250), height: auto),
  )
  #v(0.3cm)
  #card([Katalog Dalam Terbitan (KDT)], [
    Dian Hanifudin Subhi dan Ade Ismail\
    #h(1em)Laravel Praktis: Membangun Aplikasi Kasir dari Nol / Dian Hanifudin Subhi dan Ade Ismail.\
    #h(1em)-- Edisi I. -- Malang: Politeknik Negeri Malang, #datetime.today().year().\
    #h(1em)xiv, -- hlm.; 23 cm.
    #v(0.2cm)
    ISBN 978-623-XXXX-XX-X
    #v(0.2cm)
    1.~Pemrograman Aplikasi Web.#h(1em)2.~Laravel.#h(1em)3.~PHP.#linebreak()
    I.~Judul.#h(1fr)005.276
  ], fill: white)
  #v(1fr)
  #text(size: 9pt, style: "italic")[Dicetak dan diterbitkan di Indonesia]
]
