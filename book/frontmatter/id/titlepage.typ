#import "/template.typ": *

// Title page. The decoration (gray band, rules, frame) replaces the TikZ overlay.
#page(
  header: none,
  footer: none,
  background: {
    place(top + left, rect(width: 100%, height: 4.2cm, fill: luma(235), stroke: none))
    place(top + left, dx: 1.4cm, dy: 1.1cm, line(length: 15.5cm - 2.8cm, stroke: 1.2pt + luma(77)))
    place(top + left, dx: 1.4cm, dy: 1.45cm, line(length: 15.5cm - 2.8cm, stroke: 0.6pt + luma(153)))
    place(top + left, dx: 1.6cm, dy: 1.6cm, rect(width: 15.5cm - 3.2cm, height: 23cm - 3.2cm, stroke: 1pt + luma(115)))
  },
)[
  #set par(first-line-indent: 0pt, justify: false)
  #v(1.8cm)
  #align(center)[
    #text(font: sans-font, size: 9pt, weight: "bold", tracking: 0.25em)[POLINEMA PRESS]
    #v(1.25cm)
    #text(font: sans-font, size: 26pt, weight: "bold")[Laravel Praktis]
    #v(0.45cm)
    #text(font: sans-font, size: 15pt)[Membangun Aplikasi Kasir dari Nol]
    #v(0.7cm)
    #text(size: 11pt, style: "italic")[Membangun aplikasi kasir langkah demi langkah, dari routing dan basis data hingga otentikasi dan API]
  ]
  #v(1.5cm)
  #block(width: 100%, fill: luma(247), stroke: 0.7pt + luma(115), radius: 2pt, inset: 0pt)[
    #block(width: 100%, fill: luma(115), inset: (x: 10pt, y: 3pt))[
      #align(center, text(font: sans-font, weight: "bold", fill: white)[Penulis])
    ]
    #block(width: 100%, inset: 10pt)[
      #align(center, text(size: 14pt, weight: "bold")[Dian Hanifudin Subhi dan Ade Ismail])
    ]
  ]
  #v(1fr)
  #align(center)[
    #line(length: 25%, stroke: 0.6pt)
    #v(0.35cm)
    #text(font: sans-font, size: 9pt)[Buku referensi praktis untuk pengembangan aplikasi web#linebreak()dengan Laravel]
    #v(0.75cm)
    #text(weight: "bold")[Polinema Press]
    #linebreak()
    Malang • #datetime.today().year()
  ]
]
