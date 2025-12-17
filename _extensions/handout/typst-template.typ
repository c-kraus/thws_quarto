// ===========================================================
// THWS-Handout-Template (Fixed Centering)
// ===========================================================

#let thws_orange = rgb("#ff6a00")

#let project(
  title: [Handout],
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
    margin: (left: 32mm, right: 20mm, top: 45mm, bottom: 20mm),

    footer: context {
      let page_number = counter(page).display("1")
      align(center, text(thws_orange, size: 7pt, weight: "regular")[ #page_number ])
    },

    header: context {
      let page_number = counter(page).get().first()

      // LOGIK: Auf Seite 1 ist das Logo im Titelblock. Ab Seite 2 im Header.
      if page_number > 1 {
        if logo != none {
          // Logo links oben im Rand (hochgezogen)
          place(top + left, dx: 0mm, dy: -20mm, image(logo, width: 20%))
        }

        // Optional: Kurs-Name rechts oben (ebenfalls hochgezogen)
        if course != none {
          place(top + right, dx: -5mm, dy: -20mm, text(fill: thws_orange, size: 9pt, weight: "regular")[*#course*])
        }
      }
    },
  )

  //----------------------------
  // 3. Typografie
  //----------------------------
  set text(font: "Helvetica", size: 11pt, lang: lang)
  set par(leading: 0.8em, spacing: 1.2em, justify: true)

  show cite: set text(fill: thws_orange)
  set footnote(numbering: n => text(fill: thws_orange, numbering("1", n)))

  set list(
    indent: 1em,
    marker: (text(fill: thws_orange)[•], text(fill: thws_orange)[‣], text(fill: thws_orange)[–]),
  )
  set enum(
    indent: 1em,
    numbering: (..nums) => text(fill: thws_orange, numbering("1.", ..nums)),
  )

  // Tabellen
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

  // Überschriften
  set heading(numbering: (..nums) => text(fill: thws_orange, numbering("1.1 ", ..nums)))
  show heading: set text(fill: thws_orange, weight: "semibold")
  show heading: set block(sticky: true)
  show heading.where(level: 1): set block(above: 2.5em, below: 1.2em)

  //----------------------------
  // 4. TITELBLOCK (Handout-Spezifisch)
  //----------------------------

  // FIX: Explizite Align-Umgebung um den ganzen Block + justify false
  align(center, block(width: 100%)[
    #set par(leading: 0.5em, spacing: 0pt, justify: false)

    // Logo auf der ersten Seite
    #if logo != none {
      align(center, image(logo, width: 30%))
      v(1em)
    }

    #set text(size: 20pt, fill: thws_orange, style: "italic", weight: "regular")
    *#title*

    #if subtitle != none [
      #v(0.5em)
      #set text(size: 12pt, fill: black, style: "normal")
      #subtitle
    ]
  ])

  v(1cm)

  //----------------------------
  // 5. AUTORENBLOCK
  //----------------------------
  align(center, block(width: 100%)[
    #set par(leading: 0.6em, spacing: 4pt, justify: false)
    #set text(size: 11pt, fill: black, style: "normal", weight: "regular")

    #for a in author_list {
      text(weight: "regular")[#a.name]
      linebreak()
      set text(size: 9pt)

      if "role" in a [ #text(style: "italic")[#a.role] #linebreak() ]

      if "email" in a [
        #text(fill: thws_orange)[#a.email]
        #linebreak()
      ]

      v(8pt, weak: true)
    }
  ])
  v(1cm)

  // ABSTRACT
  if abstract != none [
    block(width: 100%, inset: (x: 2em))[#set align(center); #text(style: "italic", size: 11pt)[#abstract]]
    v(1.5cm)
  ] else [ #v(1cm) ]

  // Inhaltsübersicht
  if show_outline {
    let outline_title = if lang == "de" { "Inhaltsübersicht" } else { "Contents" }
    outline(title: outline_title, depth: outline_depth)
    v(2em)
  }

  // BODY
  body

  // BIBLIOGRAPHIE
  if bib_file != none [
    #v(2em)
    #line(length: 100%, stroke: 0.5pt + gray)
    #set par(spacing: 8pt, leading: 0.65em)
    #set text(size: 0.9em)

    // Sicherer Regex Fix
    #show regex("\\[\\d+\\]"): set text(fill: thws_orange)

    #if citation_style != none { bibliography(bib_file, style: citation_style) } else { bibliography(bib_file) }
  ]
}
