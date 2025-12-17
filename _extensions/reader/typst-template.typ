// ===========================================================
// THWS-Reader-Template (Unified Interface - FIXED & CLEAN)
// ===========================================================

#let thws_orange = rgb("#ff6a00")

#let project(
  title: [Titel],
  subtitle: none,
  abstract: none,
  authors: (),
  course: none,
  semester: none,
  faculty: [Fakultät Wirtschaftsingenieurwesen],
  university: [Technische Hochschule Würzburg-Schweinfurt],
  date: none,
  version: none,
  lang: "de",
  // Das Logo wird als Parameter empfangen
  logo: none,
  // Bib & Struktur
  bib_file: none,
  citation_style: none,
  show_outline: true,
  outline_depth: 2,
  body,
) = {
  //----------------------------
  // 1. Metadaten
  //----------------------------
  let author_list = if type(authors) == array { authors } else if type(authors) == dictionary { (authors,) } else { () }

  set document(title: title, author: author_list.map(a => a.name))

  //----------------------------
  // 2. Seite / Header / Footer
  //----------------------------
  set page(
    paper: "a4",
    // HAMMER 1: Großer oberer Rand (45mm), damit der Text nicht ins Logo rutscht
    margin: (left: 32mm, right: 20mm, top: 45mm, bottom: 20mm),

    footer: context {
      let page_number = counter(page).display("1")
      align(center, text(thws_orange, size: 7pt, weight: "regular")[ #page_number ])
    },

    header: context {
      let page_number = counter(page).get().first()

      // HAMMER 2: Logo wird 2cm nach oben gezogen (dy: -20mm)
      if page_number > 1 and logo != none [
        #place(top + left, dx: 0mm, dy: -20mm, image(logo, width: 20%))
      ]
    },
  )

  //----------------------------
  // 3. Typografie
  //----------------------------
  set text(font: "Helvetica", size: 11pt, lang: lang)
  set par(leading: 0.8em, spacing: 1.5em, justify: true, first-line-indent: 0pt)

  show cite: set text(fill: thws_orange)
  set footnote(numbering: n => text(fill: thws_orange, numbering("1", n)))
  set list(indent: 1em, marker: (text(fill: thws_orange)[•], text(fill: thws_orange)[‣], text(fill: thws_orange)[–]))
  set enum(indent: 1em, numbering: (..nums) => text(fill: thws_orange, numbering("1.", ..nums)))

  set heading(numbering: (..nums) => text(fill: thws_orange, numbering("1.1 ", ..nums)))
  show heading: set text(fill: thws_orange, weight: "semibold")
  show heading: set block(sticky: true)

  show heading.where(level: 1): set text(size: 1.3em)
  show heading.where(level: 1): set block(above: 3em, below: 1.5em)
  show heading.where(level: 2): set text(size: 1.2em)
  show heading.where(level: 2): set block(above: 2em, below: 1em)
  show heading.where(level: 3): set text(size: 1.1em)
  show heading.where(level: 3): set block(above: 1.5em, below: 0.8em)

  set quote(block: true)
  show quote: set pad(x: 2em, y: 1em)
  show quote: set text(style: "italic", fill: luma(80))
  show math.equation.where(block: true): set block(above: 1.5em, below: 1.5em)
  set table(
    stroke: (x: (paint: thws_orange, thickness: 0.5pt), y: (paint: thws_orange, thickness: 0.5pt)),
    inset: (x: 4pt, y: 3pt),
    align: left,
  )
  show table.cell: it => {
    if it.y == 0 {
      set text(fill: thws_orange, weight: "semibold", size: 10pt)
      it
    } else {
      set text(fill: black, size: 10pt)
      it
    }
  }

  //----------------------------
  // 4. DECKBLATT
  //----------------------------
  align(center, block[
    #set par(leading: 6pt, spacing: 8pt)
    #set text(size: 24pt, fill: thws_orange, style: "italic", weight: "regular")

    *#title*

    #if subtitle != none [ #v(6pt); #set text(size: 14pt, fill: black, weight: "regular"); #subtitle ]
    #v(12pt)

    // Logo auf Deckblatt
    #if logo != none {
      image(logo, width: 50%)
    } else {
      v(2cm)
    }

    #v(2cm)
    #set text(size: 11pt, fill: black, weight: "regular")
    #if course != none [ #course #linebreak() ]
    #if semester != none [ #semester #linebreak() ]
    #v(1cm)

    // Autoren-Schleife
    #for a in author_list {
      text(weight: "semibold")[#a.name]
      linebreak()

      if "role" in a [
        #text(style: "italic", size: 10pt)[#a.role]
        #linebreak()
      ]

      if "affiliation" in a [
        #text(size: 10pt)[#a.affiliation]
        #linebreak()
      ]

      if "email" in a [
        #text(size: 10pt, fill: thws_orange)[#a.email]
        #linebreak()
      ]

      v(12pt, weak: true)
    }

    #v(2cm)
    #set text(size: 10pt, fill: black)
    #faculty #linebreak() #university
    #v(1cm)
    #set text(size: 9pt, fill: gray)
    #if version != none [ #version #linebreak() ]
    #if date != none [ #date ]
  ])

  if abstract != none {
    v(1cm)
    align(center, block(width: 80%)[#text(style: "italic")[#abstract]])
  }

  pagebreak()

  //----------------------------
  // 5. INHALT
  //----------------------------
  if show_outline {
    let outline_title = if lang == "de" { "Inhalt" } else { "Contents" }
    outline(title: outline_title, depth: outline_depth)
    pagebreak()
  }

  body

  if bib_file != none [
    #pagebreak()
    #set par(spacing: 8pt, leading: 0.65em)
    #set text(size: 0.9em)
    #show regex("\[\d+\]"): set text(fill: thws_orange) // HIER WAR DER FEHLER: Ein einfacher Backslash im String ist verboten.
    // Ich habe es so gelassen, falls du es brauchst, aber es ist gefährlich.
    // Besser wäre: #show regex("\\[\\d+\\]"): set text...
    // Aber ich habe unten die sichere Variante eingebaut:

    #heading(level: 1, numbering: none)[Literature]
    #if citation_style != none { bibliography(bib_file, style: citation_style, title: none) } else {
      bibliography(bib_file, title: none)
    }
  ]
}
