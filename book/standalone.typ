// Standalone build of a single chapter or appendix.
// Driven by `typst compile --input lang=id --input kind=chapter --input name=chapter01-...`
// (see the Makefile targets `chapter` and `appendix`).

#import "/template.typ": *

#let lang = sys.inputs.at("lang", default: "id")
#let kind = sys.inputs.at("kind", default: "chapter")
#let name = sys.inputs.at("name")
#let path = (if kind == "appendix" { "/appendices/" } else { "/chapters/" }) + lang + "/" + name + ".typ"

#show: book.with(lang: lang)
#show: mainmatter

#if kind == "appendix" [
  #show: appendices
  #include path
] else [
  #include path
]

#show: backmatter
#bibliography-section("references.bib", full: false)
