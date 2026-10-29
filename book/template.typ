// Template for "Laravel Praktis" / "Practical Laravel" (Typst edition).
// This replaces preamble.tex: page geometry, fonts, headings, running heads, boxes,
// code listings, tables, the chapter hero, the repository callout, the index and
// the table of contents. Strings per language live in i18n.typ.
//
// Usage in an entry file:   #show: book.with(lang: "id")

#import "@preview/in-dexter:0.7.2": index as dex-index, make-index as dex-make-index
#import "i18n.typ": strings
#import "icons.typ": icon

// ----------------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------------

#let repo-owner = "dhanifudin"

#let body-font = ("Times New Roman", "Liberation Serif")
#let sans-font = ("Liberation Sans", "DejaVu Sans")
#let mono-font = ("DejaVu Sans Mono", "Liberation Mono")

// The LaTeX edition used \selectcolormodel{gray} so that it prints safely in
// black and white. Every box color below goes through `to-gray` for the same result;
// set `print-gray` to false for a colored PDF.
#let print-gray = true

#let to-gray(c) = {
  if not print-gray { return c }
  let (r, g, b, ..) = rgb(c).components()
  luma((0.30 * (r / 100%) + 0.59 * (g / 100%) + 0.11 * (b / 100%)) * 100%)
}

#let palette = (
  blue: rgb("#0000ff"),
  red: rgb("#ff0000"),
  green: rgb("#00ff00"),
  orange: rgb("#ff8000"),
  purple: rgb("#bf0040"),
  teal: rgb("#008080"),
  yellow: rgb("#ffff00"),
)

// xcolor "name!pct!other" mixing
#let tint(name, pct, other: white) = to-gray(color.mix(
  (palette.at(name), pct),
  (other, 100% - pct),
  space: rgb,
))

#let S(key) = context strings.at(text.lang).at(key)

// ----------------------------------------------------------------------------
// Inline helpers
// ----------------------------------------------------------------------------

// Cross reference that degrades to "??" when the target is not part of the document
// (standalone chapter and appendix builds refer to chapters that are not included).
#let xref(label) = context {
  if query(label).len() > 0 { ref(label) } else [??]
}

// Package names from Composer/npm are set in sans-serif.
#let pkg(body) = text(font: sans-font, body)

// \term: italic word that also registers an index entry. The key is lowercased so
// uses of a term merge with glossary entries; make-index capitalizes the display.
#let term(body) = {
  emph(body)
  dex-index(lower(body.text))
}

// Glossary term (description list item). Used as `/ #gterm[Name]: definition`.
#let gterm(body) = {
  emph(body)
  dex-index(lower(body.text))
}

// ----------------------------------------------------------------------------
// Boxes (tcolorbox equivalents)
// ----------------------------------------------------------------------------

#let _box(c, title, body) = {
  let frame = tint(c, 75%, other: black)
  let back = tint(c, 5%)
  block(
    width: 100%,
    above: 0.9em,
    below: 0.9em,
    breakable: true,
    stroke: 0.5mm + frame,
    radius: 1.5pt,
    clip: true,
    inset: 0pt,
  )[
    #block(width: 100%, fill: frame, inset: (x: 4pt, y: 3pt), below: 0pt, sticky: true)[
      #set text(fill: white, weight: "bold", font: body-font, size: 10pt)
      #set par(first-line-indent: 0pt)
      #title
    ]
    #block(width: 100%, fill: back, inset: (x: 4pt, y: 3pt), above: 0pt)[
      #set par(first-line-indent: 0pt)
      #body
    ]
  ]
}

#let notebox(body) = _box("blue", [#icon("info-circle")#h(0.7em)#S("note")], body)
#let warningbox(body) = _box("red", [#icon("exclamation-triangle")#h(0.7em)#S("warning")], body)
#let tipbox(body) = _box("green", [#icon("lightbulb")#h(0.7em)#S("tip")], body)
#let examplebox(title: [], body) = _box("orange", [#icon("book-open")#h(0.7em)#S("example")#title], body)
#let exercisebox(title: [], body) = _box("purple", [#S("exercise")#title], body)
#let challengebox(body) = _box("teal", [#icon("chevron-circle-right")#h(0.7em)#S("challenge")], body)
#let istilahpenting(body) = _box("green", [#icon("key")#h(0.7em)#S("key-terms")], body)

// ----------------------------------------------------------------------------
// Code listings
// ----------------------------------------------------------------------------

// A listing is a raw block, optionally labeled with the file path above the frame.
// Listings of up to 10 lines stay on one page (Needspace in the LaTeX edition);
// longer ones may break across pages.
#let listing(file: none, body) = {
  let lines = if body.has("text") { body.text.split("\n").len() } else { 99 }
  if file != none {
    block(above: 0.8em, below: 2pt, sticky: true)[
      #set text(font: mono-font, size: 7pt, fill: luma(115))
      #set par(first-line-indent: 0pt)
      #icon("file-alt")#h(0.4em)#file
    ]
  }
  block(
    width: 100%,
    above: if file == none { 0.8em } else { 0pt },
    below: 0.8em,
    fill: luma(240),
    stroke: 0.5pt + black,
    inset: (x: 0.6em, y: 4pt),
    breakable: lines > 10,
  )[
    #set par(first-line-indent: 0pt, justify: false)
    #body
  ]
}

// ----------------------------------------------------------------------------
// Chapter hero and repository callout
// ----------------------------------------------------------------------------

#let chaptertag(body) = box(
  fill: luma(235),
  radius: 3pt,
  inset: (x: 6pt, y: 3pt),
  baseline: 3pt,
  text(font: sans-font, size: 7pt, weight: "bold", fill: luma(70), body),
)

#let chapterhero(c, focus, ..tags) = {
  let frame = tint(c, 55%, other: black)
  block(
    width: 100%,
    above: 2pt,
    below: 10pt,
    breakable: false,
    fill: tint(c, 8%),
    radius: 2pt,
    stroke: (left: 3pt + frame),
    inset: (left: 14pt, right: 12pt, y: 10pt),
  )[
    #set par(first-line-indent: 0pt, justify: false)
    #text(font: sans-font, weight: "bold", size: 9pt, fill: frame)[#S("chapter-focus")]
    #v(3pt)
    #text(fill: luma(38), size: 11pt)[#focus]
    #v(8pt)
    #for t in tags.pos() { chaptertag(t); h(6pt) }
  ]
}

// \branchref{chapter-08}: callout with the per-chapter template repository.
#let branchref(chapter) = {
  let num = chapter.slice(-2)
  let repo = "simple-pos-ch" + num
  block(
    width: 100%,
    above: 4pt,
    below: 6pt,
    breakable: false,
    fill: luma(247),
    stroke: 0.5pt + luma(115),
    radius: 1.5pt,
    inset: (x: 6pt, y: 3pt),
  )[
    #set text(size: 10pt)
    #set par(first-line-indent: 0pt)
    #icon("code-branch")#h(0.7em)#strong[#S("full-code"):]
    #link("https://github.com/" + repo-owner + "/" + repo)[#raw(repo-owner + "/" + repo)]
    #context strings.at(text.lang).use-template
  ]
}

// ----------------------------------------------------------------------------
// Parts, matter modes, tables of contents
// ----------------------------------------------------------------------------

// A part opener page. It is a figure of kind "part" so it can appear in the table of
// contents without taking over the chapter numbering (chapters continue across parts).
#let part(title, chapters) = page(header: none, footer: none)[
  #v(4cm)
  #figure(
    kind: "part",
    supplement: [Part],
    numbering: "I",
    outlined: true,
    caption: title,
    gap: 0pt,
  )[
    #set par(first-line-indent: 0pt, justify: false)
    #set align(left)
    #text(font: sans-font, size: 28pt, weight: "bold")[
      #context [#strings.at(text.lang).part #counter(figure.where(kind: "part")).display("I")]
    ]
    #v(6pt)
    #text(font: sans-font, size: 22pt, weight: "bold")[#title]
    #v(16pt)
    #text(font: sans-font, size: 13pt, weight: "bold")[#S("chapters-in-part")]
    #v(6pt)
    #for c in chapters [
      - #c
    ]
  ]
]

#let frontmatter(body) = {
  set page(numbering: "i")
  set heading(numbering: none)
  counter(page).update(1)
  body
}

// Like \cleardoublepage: continue on the next odd (right-hand) page.
#let cleardoublepage() = pagebreak(to: "odd", weak: true)

// The main matter starts on an odd (right-hand) page numbered 1, like the LaTeX
// edition, so that header and footer placement keeps the same parity.
#let mainmatter(body) = {
  pagebreak(to: "odd", weak: true)
  set page(numbering: "1")
  set heading(numbering: "1.1", supplement: [Bab])
  counter(page).update(1)
  body
}

#let appendices(body) = {
  counter(heading).update(0)
  state("appendix").update(true)
  set heading(numbering: "A.1", supplement: [Lampiran])
  body
}

#let backmatter(body) = {
  state("appendix").update(false)
  set heading(numbering: none)
  body
}

#let toc() = {
  heading(level: 1, numbering: none, outlined: false, S("contents"))
  outline(
    title: none,
    target: selector(heading.where(outlined: true)).or(figure.where(kind: "part")),
    depth: 2,
  )
}

#let list-of-tables() = {
  heading(level: 1, numbering: none, outlined: false, S("list-of-tables"))
  outline(title: none, target: figure.where(kind: table))
}

// `full: true` lists every entry of the .bib file (the old \nocite{*}); standalone
// chapter builds list only the cited ones.
#let bibliography-section(path, full: true) = {
  context bibliography(
    path,
    title: strings.at(text.lang).bibliography,
    style: "ieee",
    full: full,
  )
}

#let index-section() = {
  heading(level: 1, numbering: none, outlined: true, S("index"))
  columns(2, gutter: 18pt)[
    #set par(first-line-indent: 0pt, justify: false)
    #dex-make-index(
      use-page-counter: true,
      section-title: (letter, counter) => block(above: 12pt, below: 4pt, sticky: true)[
        #text(font: sans-font, size: 13pt, weight: "bold", fill: luma(70))[#letter]
        #v(-6pt)
        #line(length: 100%, stroke: 0.4pt)
      ],
    )
  ]
}

// ----------------------------------------------------------------------------
// Document setup
// ----------------------------------------------------------------------------

#let _fig-number(el) = {
  let loc = el.location()
  let ch = counter(heading).at(loc).first()
  let in-appendix = state("appendix", false).at(loc)
  let n = el.counter.at(loc).first()
  [#if in-appendix { numbering("A", ch) } else { str(ch) }.#n]
}

#let book(lang: "id", body) = {
  let L = strings.at(lang)

  set document(title: "Laravel Praktis", author: ("Dian Hanifudin Subhi", "Ade Ismail"))

  set page(
    width: 15.5cm,
    height: 23cm,
    margin: (x: 2cm, y: 2cm),
    numbering: "1",
    header: context {
      let pg = here().page()
      let marks = query(heading.where(level: 1).or(heading.where(level: 2)))
        .filter(h => h.location().page() <= pg and (h.level == 1 or h.numbering != none))
      let starts-chapter = query(heading.where(level: 1)).any(h => h.location().page() == pg)
      if starts-chapter or marks.len() == 0 or marks.last().level != 2 { return }
      let h = marks.last()
      set text(size: 10pt, style: "italic")
      align(if calc.odd(pg) { right } else { left })[
        #if h.numbering != none [#numbering(h.numbering, ..counter(heading).at(h.location())). ]#h.body
      ]
    },
    footer: context {
      let pg = here().page()
      let num = counter(page).display(here().page-numbering())
      let chapters = query(heading.where(level: 1)).filter(h => h.location().page() <= pg)
      let starts-chapter = query(heading.where(level: 1)).any(h => h.location().page() == pg)
      set text(size: 10pt)
      let chapter-mark = if chapters.len() == 0 or starts-chapter { [] } else {
        let c = chapters.last()
        emph[#if c.numbering != none [#numbering(c.numbering, ..counter(heading).at(c.location())). ]#c.body]
      }
      if calc.odd(pg) { chapter-mark; h(1fr); num } else { num; h(1fr); chapter-mark }
    },
  )

  set text(
    font: body-font,
    size: 11pt,
    lang: lang,
    region: if lang == "id" { "ID" } else { "US" },
    hyphenate: true,
  )
  set par(justify: true, leading: 0.78em, spacing: 0.78em, first-line-indent: 1.2em)

  // Headings: sans-serif bold, KOMA-like sizes, numbers followed by a period.
  set heading(numbering: "1.1", supplement: [Bab])
  show heading: set text(font: sans-font, weight: "bold")
  show heading: set par(first-line-indent: 0pt, justify: false)
  show heading: it => {
    let number = if it.numbering != none {
      [#numbering(it.numbering, ..counter(heading).at(it.location())).#h(0.5em)]
    }
    if it.level == 1 {
      // each chapter restarts figure/table numbering
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      pagebreak(weak: true)
      block(above: 0.6cm, below: 0.4cm, sticky: true)[
        #set text(size: 14pt)
        #number#it.body
      ]
    } else if it.level == 2 {
      block(above: 1.2em, below: 0.6em, sticky: true)[
        #set text(size: 12pt)
        #number#it.body
      ]
    } else {
      block(above: 1em, below: 0.5em, sticky: true)[
        #set text(size: 11pt)
        #number#it.body
      ]
    }
  }

  // Lists
  set list(indent: 1em, body-indent: 0.6em, spacing: 0.55em)
  set enum(indent: 1em, body-indent: 0.6em, spacing: 0.55em)
  set terms(hanging-indent: 0pt, indent: 0pt, tight: true)
  show terms.item: it => {
    block(above: 0.4em, below: 0.3em)[
      #strong(it.term)
      #linebreak()
      #it.description
    ]
  }

  // Code
  show raw: set text(font: mono-font)
  show raw.where(block: false): set text(size: 0.86em)
  show raw.where(block: true): set text(size: 7.4pt)
  show raw.where(block: true): set par(leading: 0.55em)
  set raw(tab-size: 2)

  // Links
  show link: it => if type(it.dest) == str { text(fill: blue, it) } else { it }

  // Figures and tables
  set figure(gap: 0.7em)
  show figure.where(kind: table): set figure(supplement: L.table)
  show figure.where(kind: image): set figure(supplement: L.figure)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: "part"): it => it.body
  show figure.caption: it => {
    set text(size: 10pt)
    set par(first-line-indent: 0pt, justify: false)
    context {
      let loc = it.location()
      let ch = counter(heading).at(loc).first()
      let appendix = state("appendix", false).at(loc)
      let n = it.counter.at(loc).first()
      let prefix = if appendix { numbering("A", ch) } else { str(ch) }
      align(left)[#it.supplement~#prefix.#n: #it.body]
    }
  }
  set table(
    stroke: none,
    inset: (x: 5pt, y: 3.5pt),
  )
  show table: set par(justify: false, first-line-indent: 0pt)
  show figure: set block(above: 1.1em, below: 1.1em)

  // Cross references: "Bab 3", "Bagian 3.2", "Tabel 2.1", "Gambar 1.2", "Lampiran A"
  show ref: it => {
    let el = it.element
    if el == none { return it }
    context {
      if el.func() == heading {
        let target = str(it.target)
        let sup = if el.level > 1 { L.section } else if target.starts-with("app:") { L.appendix } else { L.chapter }
        let num = numbering(el.numbering, ..counter(heading).at(el.location()))
        link(it.target)[#sup~#num]
      } else if el.func() == figure {
        let kind = if el.kind == table { L.table } else { L.figure }
        link(it.target)[#kind~#_fig-number(el)]
      } else {
        it
      }
    }
  }

  // Table of contents entries
  show outline.entry: it => {
    let el = it.element
    context {
      if el.func() == figure and el.kind == "part" {
        let n = numbering("I", ..counter(figure.where(kind: "part")).at(el.location()))
        block(above: 1.4em, below: 0.3em, sticky: true)[
          #set par(first-line-indent: 0pt, justify: false)
          #link(el.location())[
            #strong[#n.#h(1em)#el.caption.body]#box(width: 1fr)#strong[#it.page()]
          ]
        ]
      } else if el.func() == figure {
        let n = _fig-number(el)
        block(above: 0.5em)[
          #set par(first-line-indent: 0pt, justify: false)
          #link(el.location())[#n.#h(0.8em)#el.caption.body#box(width: 1fr, repeat[~.~])#it.page()]
        ]
      } else if el.level == 1 {
        let n = if el.numbering != none {
          [#numbering(el.numbering, ..counter(heading).at(el.location())).#h(0.8em)]
        }
        block(above: 1em, below: 0.2em)[
          #set par(first-line-indent: 0pt, justify: false)
          #link(el.location())[#strong[#n#el.body]#box(width: 1fr)#strong[#it.page()]]
        ]
      } else {
        let n = [#numbering(el.numbering, ..counter(heading).at(el.location())).#h(0.8em)]
        block(above: 0.4em, below: 0pt)[
          #set par(first-line-indent: 0pt, justify: false)
          #set text(size: 10pt)
          #h(1em)#link(el.location())[#n#el.body#box(width: 1fr, repeat[~.~])#it.page()]
        ]
      }
    }
  }

  body
}
