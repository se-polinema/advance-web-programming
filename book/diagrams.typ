// Chapter 1 diagrams, ported from TikZ to CeTZ. The visual language matches the LaTeX
// edition: gray "diagbox" nodes for secondary elements, accented nodes for the main
// elements, and thick stealth arrows (see \tikzset in the old preamble.tex).

#import "@preview/cetz:0.3.4": canvas, draw
#import "template.typ": tint, to-gray, sans-font

#let _frame(accent) = if accent { tint("blue", 55%, other: black) } else { to-gray(luma(115)) }
#let _fill(accent) = if accent { tint("blue", 8%) } else { luma(245) }

// A diagram node: rounded box with centered text. `w` is its width in cm.
#let _node(pos, label, name, w: 2.1, h: 0.9, accent: false, anchor: "center") = {
  draw.content(
    pos,
    box(
      width: w * 1cm,
      height: h * 1cm,
      fill: _fill(accent),
      stroke: 0.8pt + _frame(accent),
      radius: 2pt,
      align(center + horizon, text(size: 10pt, label)),
    ),
    name: name,
    anchor: anchor,
  )
}

#let _arrow(a, b, both: false) = {
  let m = (end: "stealth", fill: luma(90), scale: 0.7)
  if both { m.insert("start", "stealth") }
  draw.line(a, b, stroke: 0.8pt + luma(90), mark: m)
}

// Monolith (three layers in one unit) versus microservices (independent services).
#let diagram-monolith() = context {
  let id = text.lang == "id"
  let ui = if id { "Antarmuka (UI)" } else { "Interface (UI)" }
  let logic = if id { "Logika Bisnis" } else { "Business Logic" }
  let data = if id { "Akses Data" } else { "Data Access" }
  let s1 = if id { "Layanan Produk" } else { "Product Service" }
  let s2 = if id { "Layanan Pembayaran" } else { "Payment Service" }
  let s3 = if id { "Layanan Pengguna" } else { "User Service" }
  scale(84%, reflow: true, canvas(length: 1cm, {
    _node((0, 0), ui, "ui", w: 3.2, accent: true)
    _node((0, -1.2), logic, "logic", w: 3.2, accent: true)
    _node((0, -2.4), data, "data", w: 3.2, accent: true)
    draw.rect(
      (-1.85, 0.7),
      (1.85, -3.12),
      stroke: 0.8pt + to-gray(luma(115)),
      radius: 3pt,
    )
    draw.content((0, 0.85), text(weight: "bold", size: 10pt)[Monolith], anchor: "south")

    _node((6.25, -0.3), s1, "s1", w: 2.5)
    _node((6.25, -2.6), s2, "s2", w: 3.2)
    _node((10.55, -1.0), s3, "s3", w: 2.9)
    draw.content((6.25, 0.5), text(weight: "bold", size: 10pt)[Microservices], anchor: "south")

    _arrow("s1.south", "s2.north", both: true)
    _arrow("s2.east", "s3.south", both: true)
    _arrow("s3.west", "s1.east", both: true)
  }))
}

// One Laravel request: Request, Router, Controller, Model, View/Response.
#let diagram-lifecycle() = context {
  scale(88%, reflow: true, canvas(length: 1cm, {
    let xs = (1.05, 3.65, 6.45, 9.25, 11.85)
    let w = (2.1, 2.1, 2.5, 2.1, 2.1)
    let labels = ("Request", "Router", "Controller", "Model", [View /#linebreak()Response])
    let names = ("req", "router", "ctrl", "model", "view")
    for i in range(5) {
      _node((xs.at(i), 0), labels.at(i), names.at(i), w: w.at(i), h: if i == 4 { 1.1 } else { 0.9 }, accent: true)
    }
    for i in range(4) {
      _arrow(names.at(i) + ".east", names.at(i + 1) + ".west")
    }
  }))
}
