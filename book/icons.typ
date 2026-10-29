// Font Awesome Free (Solid) icons used by the book, addressed by the Font Awesome 5
// names that the former LaTeX edition used (fontawesome5 package). The codepoints
// come from Font Awesome 6 Free, bundled in fonts/ (SIL OFL 1.1 for the font,
// see fonts/FONTAWESOME-LICENSE.txt).

#let _codepoints = (
  "bolt": "\u{f0e7}",
  "book-open": "\u{f518}",
  "bug": "\u{f188}",
  "cash-register": "\u{f788}",
  "check-circle": "\u{f058}",
  "check-double": "\u{f560}",
  "chevron-circle-right": "\u{f138}",
  "cloud-upload-alt": "\u{f0ee}",
  "code": "\u{f121}",
  "code-branch": "\u{f126}",
  "database": "\u{f1c0}",
  "exclamation-triangle": "\u{f071}",
  "file-alt": "\u{f15c}",
  "file-csv": "\u{f6dd}",
  "flag-checkered": "\u{f11e}",
  "info-circle": "\u{f05a}",
  "key": "\u{f084}",
  "layer-group": "\u{f5fd}",
  "lightbulb": "\u{f0eb}",
  "link": "\u{f0c1}",
  "lock": "\u{f023}",
  "palette": "\u{f53f}",
  "plug": "\u{f1e6}",
  "rocket": "\u{f135}",
  "route": "\u{f4d7}",
  "server": "\u{f233}",
  "shield-alt": "\u{f3ed}",
  "sitemap": "\u{f0e8}",
  "store": "\u{f54e}",
  "table": "\u{f0ce}",
  "tachometer-alt": "\u{f625}",
  "tasks": "\u{f0ae}",
  "user-shield": "\u{f505}",
  "users-cog": "\u{f509}",
  "vial": "\u{f492}",
)

#let icon(name) = {
  let cp = _codepoints.at(name, default: none)
  assert(cp != none, message: "unknown icon: " + name)
  text(font: "Font Awesome 6 Free Solid", weight: "regular", cp)
}
