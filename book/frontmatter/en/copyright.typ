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
    #text(font: sans-font, size: 9pt, weight: "bold", tracking: 0.2em)[COPYRIGHT AND IMPRINT]
  #v(0.3cm)
  #text(size: 14pt, weight: "bold")[Practical Laravel]
  #linebreak()
  Building a Point-of-Sale App from Scratch
  #v(0.5cm)
  #card([Author], [Dian Hanifudin Subhi and Ade Ismail], fill: luma(247))
  #v(0.3cm)
  #card([Copyright Notice], [
    Copyright © #datetime.today().year() Dian Hanifudin Subhi and Ade Ismail. All rights reserved.
    #v(0.25cm)
    No part of this book may be reproduced, printed, distributed, or published in any form or by any means, mechanical or electronic, including photocopying, recording, scanning, or any information storage and retrieval system, without written permission from the publisher, except for brief quotations in scholarly writing, reviews, or reasonable academic use.
  ], fill: white)
  #v(0.3cm)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 0.4cm,
    card([Publisher], [
      Polinema Press#linebreak()
      Politeknik Negeri Malang#linebreak()
      Jalan Soekarno-Hatta No.~9#linebreak()Malang 65141, East Java, Indonesia
      #v(0.2cm)
      Phone: (0341) 404424#linebreak()
      Website: #link("https://www.polinema.ac.id")#linebreak()
      Email: info\@polinema.ac.id
    ], fill: luma(250), height: auto),
    card([Publication Metadata], [
      ISBN: 978-623-XXXX-XX-X\
    Edition: I (First)\
    Printing: 1st, #datetime.today().year()\
    Book Size: 15,5 cm × 23 cm\
    Page Count: -- (draft)\
    Cover Design: ---\
    Editor: ---\
    Layout: ---
    ], fill: luma(250), height: auto),
  )
  #v(0.3cm)
  #card([Cataloging in Publication], [
    Dian Hanifudin Subhi and Ade Ismail\
    #h(1em)Practical Laravel: Building a Point-of-Sale App from Scratch / Dian Hanifudin Subhi and Ade Ismail.\
    #h(1em)-- Edition I. -- Malang: Politeknik Negeri Malang, #datetime.today().year().\
    #h(1em)xiv, -- pp.; 23 cm.
    #v(0.2cm)
    ISBN 978-623-XXXX-XX-X
    #v(0.2cm)
    1.~Web Application Programming.#h(1em)2.~Laravel.#h(1em)3.~PHP.#linebreak()
    I.~Title.#h(1fr)005.276
  ], fill: white)
  #v(1fr)
  #text(size: 9pt, style: "italic")[Printed and published in Indonesia]
]
