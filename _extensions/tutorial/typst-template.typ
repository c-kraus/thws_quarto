// ===========================================================
// THWS Tutorial / Übungsblatt — Typst-Template (Redesign)
// -----------------------------------------------------------
// Palette : CI-Orange #EC6500 (Lead) · Teal #005564 (Akzent)
// Schrift : Helvetica / Arial
// Aufbau  : kein Deckblatt · Masthead oben · Kopf auf jeder Seite
//           Aufgaben mit Nummern-Badge · Lösungs-Callouts (ausblendbar)
// ===========================================================
#import "@preview/cades:0.3.1": qr-code

// ---- THWS-Palette ----
#let thws-orange      = rgb("#EC6500")
#let thws-orange-600  = rgb("#D25400")
#let thws-orange-tint = rgb("#FFF4EB")
#let thws-teal        = rgb("#005564")
#let thws-teal-600    = rgb("#00424F")
#let thws-teal-tint   = rgb("#EAF1F2")
#let thws-ink         = rgb("#1F1D1A")
#let thws-ink-soft    = rgb("#3A3733")
#let thws-muted       = rgb("#6B655D")
#let thws-faint       = rgb("#9A938A")
#let thws-line        = rgb("#E4E0DA")

#let body-font = ("Helvetica Neue", "Helvetica", "Arial", "Liberation Sans")

// ---- Logo-Recolor (einfarbige THWS-Wortmarke) ----
#let thws-logo(path, hex: "#EC6500", width: auto, height: auto) = {
  if path == none { return }
  let ext = lower(path.split(".").last())
  if ext == "svg" {
    let data = read(path)
    // Vorhandene Füllfarben überschreiben — CSS (.st0{fill:#…}) ODER Inline
    // (fill="#…"); funktioniert auch, wenn das SVG einen eigenen <style> mitbringt.
    data = data.replace(regex("fill\\s*:\\s*#[0-9A-Fa-f]{3,8}"), "fill:" + hex)
    data = data.replace(regex("fill\\s*=\\s*\"#[0-9A-Fa-f]{3,8}\""), "fill=\"" + hex + "\"")
    let css = "<style>.st0,.st1,path{fill:" + hex + "}</style>"
    data = data.replace("</svg>", css + "</svg>")
    image(bytes(data), format: "svg", width: width, height: height)
  } else {
    image(path, width: width, height: height)
  }
}

// Hinweis: Die Lösungssichtbarkeit macht Quarto nativ über
// ::: {.content-visible when-meta="show_solutions"} — kein Filter/Template-Code nötig.

// Zähler für große Aufgaben → Seitenumbruch vor jeder neuen (außer der ersten).
#let thws-case-counter = counter("thws-case")

// Klartext aus Content ziehen (für die Aufgaben-Nummer in der H4-Überschrift).
#let to-string(c) = {
  if c == none { "" }
  else if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(to-string).join() }
  else if c.has("body") { to-string(c.body) }
  // Apostroph/Anführungszeichen: Pandoc liefert sie als smartquote-Elemente
  // (kein .text) — ohne diesen Zweig fielen sie still weg ("Investors View").
  else if c.func() == smartquote { if c.at("double", default: true) { "\"" } else { "'" } }
  else if c == [ ] { " " }
  else { "" }
}

// Gerade Anführungszeichen aus to-string() wieder typografisch setzen — als
// String ausgegeben macht Typst das nicht selbst. Öffnend nach Wortgrenze,
// Apostroph innerhalb eines Worts, sonst schließend; DE „…“ ‚…‘, EN “…” ‘…’.
#let typo-quotes(s, de: true) = {
  let cs = s.clusters()
  let out = ""
  let open-single = false
  for (i, ch) in cs.enumerate() {
    let prev = if i > 0 { cs.at(i - 1) } else { none }
    let next = if i + 1 < cs.len() { cs.at(i + 1) } else { none }
    let opening = prev == none or prev.match(regex("[\\s(\\[{/\\-–—]")) != none
    if ch == "\"" {
      out += if opening { if de { "\u{201E}" } else { "\u{201C}" } } else { if de { "\u{201C}" } else { "\u{201D}" } }
    } else if ch == "'" {
      if opening {
        open-single = true
        out += if de { "\u{201A}" } else { "\u{2018}" }
      } else if open-single and (next == none or next.match(regex("[\\p{L}\\p{N}]")) == none) {
        open-single = false
        out += if de { "\u{2018}" } else { "\u{2019}" }
      } else {
        out += "\u{2019}"
      }
    } else {
      out += ch
    }
  }
  out
}

// ===========================================================================
// HAUPT-TEMPLATE
// ===========================================================================
#let project(
  title: none,
  subtitle: none,
  abstract: none,
  authors: (),
  course: none,
  semester: none,
  faculty: none,
  university: [Technische Hochschule Würzburg-Schweinfurt],
  date: none,
  version: none,
  lang: "de",
  logo: none,
  logo_en: none,
  sheet_no: none,
  worktime: none,
  points_total: none,
  web_url: none,
  github_url: none,
  bib_file: none,
  citation_style: none,
  show_outline: false,
  outline_depth: 2,
  body,
) = {
  let author_list = if type(authors) == array { authors } else if type(authors) == dictionary { (authors,) } else { () }
  let author_names = author_list.map(a => a.name)
  let author_string = author_names.join(", ")
  if author_string == "" { author_string = "THWS" }

  // Sprachweiche fürs Logo: bei englischer Dokumentsprache das EN-Logo nutzen.
  let active-logo = if lang != none and lang.starts-with("en") and logo_en != none {
    logo_en
  } else {
    logo
  }

  // Datumsformat sprachabhängig: DE → 16.06.2026, EN → June 16, 2026.
  // Quarto liefert ISO unabhängig von lang — daher parsen und neu formatieren.
  // (Regex-Endanker als $$ — typst-template.typ ist ein Pandoc-Template.)
  let lang-de = lang == none or lang.starts-with("de")
  // Defaults sprachabhängig (gesetzte Keys gewinnen).
  if title == none { title = if lang-de { [Übungsblatt] } else { [Worksheet] } }
  if faculty == none { faculty = if lang-de { [Fakultät Wirtschaftsingenieurwesen] } else { [Faculty of Business and Engineering] } }
  let date-fmt = if lang-de { "[day].[month].[year]" } else { "[month repr:long] [day], [year]" }
  let parse-iso(d) = {
    if type(d) == str and d.match(regex("^\\d{4}-\\d{2}-\\d{2}$$")) != none {
      let p = d.split("-")
      datetime(year: int(p.at(0)), month: int(p.at(1)), day: int(p.at(2)))
    } else { none }
  }
  let date-disp = if date != none {
    let dt = parse-iso(date)
    if dt != none { dt.display(date-fmt) } else { date }
  } else {
    datetime.today().display(date-fmt)
  }

  set document(title: title, author: author_names)

  let course-disp = if course != none { course } else { title }

  // -------------------------------------------------------------------------
  // SEITE — Kopf auf jeder Seite; Fuß: S.1 detailliert, ab S.2 Seitenzahl
  // -------------------------------------------------------------------------
  set page(
    paper: "a4",
    margin: (left: 24mm, right: 22mm, top: 30mm, bottom: 28mm),
    header-ascent: 40%,
    footer-descent: 30%,
    header: context {
      grid(
        columns: (auto, 1fr, auto),
        align: (left + horizon, center + horizon, right + horizon),
        thws-logo(active-logo, hex: "#EC6500", height: 11mm),
        [],
        text(size: 8pt, tracking: 0.12em, fill: thws-muted)[
          #upper(course-disp) #h(4pt) · #h(4pt) #text(fill: thws-orange, weight: "bold")[#upper(if semester != none { semester } else { [ ] })]
        ],
      )
      v(3pt)
      line(length: 100%, stroke: 0.5pt + thws-line)
    },
    footer: context {
      let pg = counter(page).get().first()
      if pg == 1 {
        line(length: 100%, stroke: 0.5pt + thws-line)
        v(4pt)
        grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
          text(size: 8pt, fill: thws-faint)[
            #text(weight: "bold", fill: thws-ink-soft)[#faculty] #h(0.5em) #text(fill: thws-orange)[|] #h(0.5em) #author_string
          ],
          text(size: 8pt, fill: thws-faint)[#date-disp],
        )
      } else {
        align(center)[#text(size: 9pt, weight: "bold", fill: thws-orange)[#counter(page).display()]]
      }
    },
  )

  // -------------------------------------------------------------------------
  // TYPOGRAFIE
  // -------------------------------------------------------------------------
  set text(font: body-font, size: 10pt, lang: lang, fill: thws-ink-soft)
  set par(leading: 0.66em, spacing: 1em, justify: true, first-line-indent: 0pt)

  show cite: set text(fill: thws-orange)
  // Bibliography: Quarto (>= 1.8) erzeugt den #bibliography(...)-Call selbst.
  // Nicht mehr im Template aufrufen, sondern Quartos Call abfangen und stylen.
  // (Level-1-Headings sind hier ausgeblendet → eigenes Bold-Label statt heading.)
  set bibliography(title: none)
  show bibliography: it => {
    v(1.4em)
    line(length: 100%, stroke: 0.5pt + thws-line)
    v(0.6em)
    text(weight: "bold", fill: thws-ink, size: 10.5pt)[#if lang-de { "Literatur" } else { "Literature" }]
    v(0.5em)
    set text(size: 9pt)
    set par(leading: 0.62em, spacing: 8pt)
    it
  }
  set footnote(numbering: n => text(size: 1.9em, fill: thws-orange, numbering("1", n)))
  set list(indent: 1em, marker: (text(fill: thws-orange)[•], text(fill: thws-orange)[–], text(fill: thws-orange)[◦]))
  set enum(indent: 0.6em, numbering: (..nums) => text(fill: thws-orange, weight: "bold", numbering("1.", ..nums)))

  // Untergeordnete Überschriften (innerhalb von Aufgaben) — schlicht
  set heading(numbering: none)
  // Überschrift klebt am folgenden Inhalt → kein verwaistes H2-Badge am Seitenende
  // (z. B. „Case Study 2" unten auf Seite 1, Rest erst auf Seite 2).
  show heading: set block(sticky: true)
  // H1 = Dokumenttitel. Der steht bereits im Masthead → im Fließtext unterdrücken.
  // (Ein H1 muss aber vorhanden sein, damit Quarto die Level NICHT um eins
  //  hochschiebt: nur so bleibt ## = Level 2 = große Aufgabe, #### = Level 4 = Task.)
  show heading.where(level: 1): it => none
  // H2 — die großen Aufgaben (z. B. "## Case Study 1: …") als dickes Nummern-Badge
  // im Mockup-Stil. Label/Nummer/Titel werden aus der Überschrift geparst; passt
  // keine "Wort N:"-Form, bleibt es eine schlichte Teal-Überschrift.
  // Regex-Endanker als $$ (Pandoc-Template).
  show heading.where(level: 2): it => {
    let s = to-string(it.body)
    let m = s.match(regex("^\\s*(.+?)\\s+(\\d+)\\s*[:.)]\\s*(.*)$$"))
    if m != none {
      let label = typo-quotes(m.captures.at(0), de: lang-de)
      let num = m.captures.at(1)
      let rest = typo-quotes(m.captures.at(2), de: lang-de)
      // Jede große Aufgabe auf eine neue Seite — außer der ersten.
      thws-case-counter.step()
      context { if thws-case-counter.get().first() > 1 { pagebreak(weak: true) } }
      // Kästchenhöhe = Höhe von Kicker + Titel (gemessen), damit der Kicker oben
      // und der Titel unten bündig mit den Kästchen-Kanten abschließen.
      block(above: 1.7em, below: 0.7em, breakable: false, width: 100%)[
        #context {
          let col = stack(dir: ttb, spacing: 4pt,
            text(size: 8.5pt, tracking: 0.18em, weight: "bold", fill: thws-teal)[#upper(label)],
            text(size: 15pt, weight: "bold", fill: thws-ink)[#rest],
          )
          let h = measure(col).height
          grid(columns: (auto, 1fr), column-gutter: 14pt, align: (top, top),
            box(width: 30pt, height: h, fill: thws-orange, radius: 6pt)[
              #align(center + horizon)[#text(fill: white, weight: "bold", size: 16pt)[#num]]
            ],
            col,
          )
        }
      ]
    } else {
      block(above: 1.6em, below: 0.6em)[#text(size: 14.5pt, weight: "bold", fill: thws-teal)[#it.body]]
    }
  }
  show heading.where(level: 3): it => block(above: 0.9em, below: 0.3em)[#text(size: 10.5pt, weight: "bold", fill: thws-ink)[#it.body]]
  // H4 — die kleinen Tasks (z. B. "#### Task 1: …"): schlicht und klar untergeordnet.
  // Label+Nummer in Orange, Titel in Tinte; kein Badge. Regex-Endanker als $$ (Pandoc).
  show heading.where(level: 4): it => {
    let s = to-string(it.body)
    let m = s.match(regex("^\\s*(?:Task|Aufgabe)\\s+(\\d+)\\s*[:.)]?\\s*(.*)$$"))
    if m != none {
      let num = m.captures.at(0)
      let rest = typo-quotes(m.captures.at(1), de: lang-de)
      let label = if lang-de { "Aufgabe" } else { "Task" }   // Label folgt lang, nicht dem Quelltext
      // Punkte am Ende der Überschrift: "[3 P]" / "[3 Punkte]" / "[3]" → Pille rechts.
      let pts = none
      let pm = rest.match(regex("\\s*\\[\\s*(\\d+)\\s*(?:P|Punkte?|points?|pts)?\\s*\\]\\s*$$"))
      if pm != none { pts = pm.captures.at(0); rest = rest.slice(0, pm.start).trim() }
      block(above: 1.6em, below: 1.0em, width: 100%)[
        #grid(columns: (1fr, auto), column-gutter: 10pt, align: (left + horizon, right + horizon),
          text(size: 10.5pt, weight: "bold")[
            #text(fill: thws-orange-600)[#label #num] #h(6pt) #text(fill: thws-ink)[#rest]
          ],
          if pts != none {
            box(stroke: 1pt + thws-orange, radius: 999pt, inset: (x: 8pt, y: 2.5pt))[
              #text(size: 7.5pt, weight: "bold", fill: thws-orange-600)[#pts #if lang-de { "P" } else { "pts" }]
            ]
          } else { [] },
        )
      ]
    } else {
      block(above: 0.8em, below: 0.25em)[#text(size: 10.5pt, weight: "bold", fill: thws-ink)[#it.body]]
    }
  }

  // Blockzitat: eigenes Rendering — ein Block, eine linke Kante (kein Doppelstrich).
  set quote(block: true)
  show quote.where(block: true): it => block(
    width: 100%,
    above: 1em, below: 1em,
    inset: (left: 14pt),
    stroke: (left: 2.5pt + thws-orange),
    text(style: "italic", fill: thws-ink-soft, it.body),
  )

  set table(
    inset: (x: 8pt, y: 6pt), align: left,
    stroke: (x, y) => if y == 0 { none } else { (bottom: 0.5pt + thws-line) },
    fill: (x, y) => if y == 0 { thws-teal } else if calc.odd(y) { white } else { rgb("#F7F5F2") },
  )
  show table.cell.where(y: 0): set text(fill: white, weight: "bold", size: 9.5pt)
  show table.cell: set text(size: 9.5pt)

  // -------------------------------------------------------------------------
  // MASTHEAD (statt Deckblatt)
  // -------------------------------------------------------------------------
  // Im Masthead kein Blocksatz (sonst streckt der globale justify:true den Titel).
  set par(justify: false)
  v(6pt)
  text(size: 11pt, tracking: 0.26em, fill: thws-orange, weight: "bold")[
    #upper(if lang-de { "Übungsblatt" } else { "Worksheet" })
    #if sheet_no != none [ #h(2pt) #text(fill: thws-teal)[ · #(if lang-de { "Nr." } else { "No." }) #sheet_no] ]
  ]
  v(12pt)
  text(size: 30pt, weight: "bold", fill: thws-ink, hyphenate: false)[#title]
  if subtitle != none { v(8pt); text(size: 14pt, fill: thws-muted)[#subtitle] }
  v(14pt)
  box(width: 56pt, height: 3pt, fill: thws-orange)
  v(12pt)

  // Meta-Streifen
  {
    // Bewusst nur Modul · Dozent · Ausgabe — Zeit und Punkte sind raus, damit
    // der Dozentenname nicht umbricht.
    let metas = (
      (if course != none { (if lang-de { "Modul" } else { "Course" }, course) }),
      (if author_string != "THWS" { (if lang-de { "Dozent" } else { "Lecturer" }, author_string) }),
      (if date-disp != none { (if lang-de { "Ausgabe" } else { "Issued" }, date-disp) }),
    ).filter(x => x != none)

    block(width: 100%, stroke: (top: 0.5pt + thws-line, bottom: 0.5pt + thws-line), inset: (y: 10pt))[
      // auto-Spalten: jede so breit wie ihr Inhalt → der Dozentenname bricht nicht um.
      #grid(
        columns: metas.map(_ => auto),
        column-gutter: 20pt,
        ..metas.map(m => stack(spacing: 4pt,
          text(size: 7pt, tracking: 0.16em, fill: thws-faint)[#upper(m.at(0))],
          text(size: 10pt, weight: "bold", fill: thws-ink)[#m.at(1)],
        )),
      )
    ]
  }

  // QR-Code dezent in den rechten Rand
  let qr_target = if web_url != none { web_url } else { github_url }
  if qr_target != none {
    place(top + right, dx: 16mm, dy: 2mm)[
      #align(center)[
        #box(fill: white, inset: 3pt, radius: 3pt)[#qr-code(qr_target, width: 15mm)]
        #v(2pt)
        #text(size: 5.5pt, fill: thws-muted)[#if lang-de { "Online-Version" } else { "Online version" }]
      ]
    ]
  }

  v(6pt)

  // -------------------------------------------------------------------------
  // INHALT
  // -------------------------------------------------------------------------
  set par(justify: true)
  body

  // Literatur (optional): erzeugt von Quartos #bibliography(...)-Call, gestylt
  // vom `show bibliography`-Hook oben (Label, Schrift, Abstände).
}
