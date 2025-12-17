// ===========================================================
// THWS-Tutorial-Template (Unified & Fixed)
// ===========================================================

#let thws_orange = rgb("#ff6a00")

#let project(
  title: [Übungsblatt],
  subtitle: none, // ehemals topic
  abstract: none,
  authors: (),
  course: none, // ehemals subject
  semester: none,
  faculty: [Fakultät Wirtschaftsingenieurwesen], // ehemals department
  university: [Technische Hochschule Würzburg-Schweinfurt],
  date: none,
  version: none,
  lang: "de",
  // NEU: Logo Parameter
  logo: none,
  // Bib & Struktur
  bib_file: none,
  citation_style: none,
  show_outline: false,
  outline_depth: 2,
  body,
) = {
  //----------------------------
  // 1. Metadaten & Helper
  //----------------------------
  let author_list = if type(authors) == array { authors } else if type(authors) == dictionary { (authors,) } else { () }

  // Helper für den Footer-String (Tutorial-Spezifisch: "Name, Name")
  let author_names = author_list.map(a => a.name)
  let author_string = author_names.join(", ")
  if author_string == "" { author_string = "THWS" }

  let date-string = if date != none { date } else { datetime.today().display("[day].[month].[year]") }

  set document(title: title, author: author_names)

  //----------------------------
  // 2. Seite / Header / Footer
  //----------------------------
  set page(
    paper: "a4",
    // Einheitliche Ränder mit Reader/Handout (45mm oben für Header)
    margin: (left: 32mm, right: 20mm, top: 45mm, bottom: 35mm),

    header: context {
      // LOGIK: Header auf JEDER Seite (Tutorial Standard)

      // 1. Logo Links (hochgezogen)
      if logo != none {
        place(top + left, dx: 0mm, dy: -20mm, image(logo, width: 20%))
      }

      // 2. Kurs Rechts (hochgezogen)
      if course != none {
        place(top + right, dx: 0mm, dy: -20mm, text(fill: thws_orange, size: 10pt, weight: "semibold")[#course])
      }
    },

    footer: context {
      let page-num = counter(page).get().first()

      // TUTORIAL SPEZIAL FOOTER
      pad(bottom: 10mm)[
        #if page-num == 1 {
          // Seite 1: Detaillierte Infos unten
          align(bottom)[
            #block(width: 100%)[
              #line(length: 100%, stroke: 0.5pt + thws_orange)
              #v(0.5em)
              #set text(size: 8pt, fill: rgb("#666666"))
              #grid(
                columns: (1fr, auto),
                column-gutter: 1em,
                align: (left + top, right + top),
                [
                  #if faculty != "" {
                    text(weight: "semibold")[#faculty]
                    h(0.5em)
                    text(fill: thws_orange)[|]
                    h(0.5em)
                  }
                  #author_string
                ],
                [#date-string],
              )
            ]
          ]
        } else {
          // Ab Seite 2: Nur Seitenzahl
          align(center + bottom)[
            #text(size: 9pt, fill: thws_orange)[ #page-num]
          ]
        }
      ]
    },
  )

  //----------------------------
  // 3. Typografie
  //----------------------------
  set text(font: "Helvetica", size: 10pt, lang: lang)
  set par(leading: 0.65em, spacing: 1.2em, justify: true)

  // Farben & Listen
  show cite: set text(fill: thws_orange)
  set footnote(numbering: n => text(fill: thws_orange, numbering("1", n)))
  set list(marker: (text(fill: thws_orange)[•], text(fill: thws_orange)[–], text(fill: thws_orange)[◦]))
  set enum(numbering: (..nums) => text(fill: thws_orange, numbering("1.", ..nums)))

  // Überschriften
  set heading(numbering: "1.1 ")
  show heading: set text(fill: thws_orange, weight: "regular")
  show heading.where(level: 2): it => {
    set text(fill: thws_orange, weight: "regular", size: 11pt)
    pad(left: 0cm, it)
  }

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

  //----------------------------
  // 4. TITELBLOCK
  //----------------------------
  v(1.5cm)

  // FIX: Zentrierung sicherstellen mit width 100% und justify false
  align(center, block(width: 100%)[
    #set par(justify: false)

    #if subtitle != none {
      block(text(fill: thws_orange, weight: 700, size: 1.75em)[#subtitle])
    }
    #if title != "" {
      v(4pt)
      text(fill: thws_orange, size: 15pt, weight: "semibold")[#title]
    }
  ])

  v(1cm)

  if abstract != none {
    block(width: 100%, inset: (x: 2em))[#text(style: "italic")[#abstract]]
    v(1cm)
  }

  body

  // Bibliographie
  if bib_file != none [
    #v(2em)
    #line(length: 100%, stroke: 0.5pt + gray)

    // Sicherer Regex Fix
    #show regex("\\[\\d+\\]"): set text(fill: thws_orange)

    #if citation_style != none { bibliography(bib_file, style: citation_style) } else { bibliography(bib_file) }
  ]
}
