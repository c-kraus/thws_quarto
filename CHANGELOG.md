# Changelog

## [2.0.4] — 2026-11-04

Patch-Release nur für `tutorial-typst`. `reader` / `handout` bleiben 2.0.3, `moodle-html` 1.0.0.

### tutorial
- **Fix: Apostrophe und Anführungszeichen in Aufgaben-Überschriften.** H2-/H4-Überschriften
  werden für Badge und Punkte-Pille aus dem Klartext neu gesetzt; Pandocs smartquote-Elemente
  fielen dabei weg („The Investors View" statt „The Investor’s View"). Sie bleiben jetzt erhalten
  und werden sprachabhängig typografisch gesetzt (DE „…" ‚…', EN “…” ‘…’, Apostroph ’).
- **Fix: Englische Blätter mit deutschen Beschriftungen.** Bei `lang: en` waren der Meta-Streifen
  (Modul · Dozent · Ausgabe), die QR-Beschriftung („Online-Version") sowie die Defaults für Titel
  und Fakultät deutsch. Jetzt Course · Lecturer · Issued, „Online version", „Worksheet",
  „Faculty of Business and Engineering" (gesetzte Keys `title:` / `faculty:` gewinnen weiterhin).
- Sprachprüfung einheitlich über `lang-de`, damit auch `lang: de-DE` deutsch beschriftet wird.

## [2.0.3] — 2026-08-19

Patch-Release der drei PDF-Formate (`reader` / `handout` / `tutorial`). `moodle-html` unverändert.

### reader / handout / tutorial
- **Fußnoten-Ziffern lesbar vergrößert.** In der Hausschrift (Helvetica) waren die
  Fußnoten-Hochzahlen so klein, dass sie wie fehlende Nummern wirkten. Marker jetzt auf
  `1.9em` (orange, im Text und in der Fußnotenliste gut lesbar).

### Doku
- **Zitate/Literatur (Zotero) dokumentiert.** Für **Fußnoten-Zitierstile** (juristische/Note-CSL)
  verarbeitet das PDF Zitate sonst nativ über Typst → unnummerierte Fußnoten und fehlende
  Verzeichnis-Einträge. Workaround in der README: `citeproc: true` + `reference-section-title`
  erzwingt Pandoc-Zitate (wie im HTML). Außerdem der `faculty:`-Key (Fakultät oben rechts)
  dokumentiert.

### reader
- **Lehr-Vokabular überschreibbar.** Deckblatt-Kicker, Bezeichnung der obersten Gliederungsebene,
  die beiden Meta-Spalten des Deckblatts und die QR-Bildunterschrift waren hartcodiert
  („Vorlesungsskript", „Kapitel", „Modul", „Semester", „Interaktive Übungen & Online-Version").
  Neue optionale Keys: `reader-kicker`, `reader-section-label`, `reader-course-label`,
  `reader-semester-label`, `reader-qr-caption`. Ohne Key unverändertes Verhalten — damit taugt
  `reader-typst` auch für Papiere außerhalb der Lehre (Gremien-, Konzept-, Diskussionspapiere).
- **Box-Label per Attribut.** `::: {.details label="Kommentar"}` (bzw. `title="…"`) überschreibt
  die Standardbeschriftung einer Box, so dass die Box-Looks ohne „Deep Dive"/„Fallstudie"
  nutzbar sind.
- **Fix:** Der Kicker der obersten Gliederungsebene stand auch bei `lang: en` auf Deutsch
  („KAPITEL"); er folgt jetzt der Dokumentsprache („CHAPTER").

## [2.0.2] — 2026-07-23

Patch-Release: Windows-Fix für die drei PDF-Formate `reader` / `handout` / `tutorial`.
`moodle-html` unverändert (bleibt 1.0.0).

### Fixes
- **PDF-Rendern unter Windows repariert** (`reader` / `handout` / `tutorial`). Die automatische
  Logo-Pfad-Auflösung nutzte `pandoc.path.make_relative`, das unter Windows Backslash-Separatoren
  liefert. Zusammen mit dem `.replace("\\","")` in `typst-show.typ` wurden die Separatoren
  verschluckt (`_extensions\c-kraus\reader\thws-logo.svg` → `_extensionsc-krausreaderthws-logo.svg`),
  wodurch Typst die Logo-SVG nicht fand und der Build abbrach. Fix: Separatoren in `logo_rel()` auf
  Forward Slashes normalisieren (`p:gsub("\\", "/")`) — plattformunabhängig, macOS/Linux unberührt.

## [2.0.1] — 2026-06-16

Patch-Release: nur `tutorial`-Layout. `reader`/`handout` unverändert (bleiben funktional 2.0.0).

### tutorial
- Aufgaben-Headings (`#### Task N`): mehr Abstand davor und danach (war zu beengt).
- H2-Aufgabenkopf: Nummern-Badge auf Höhe von Kicker + Titel — „CASE STUDY" oben,
  Titel unten bündig mit den Kästchen-Kanten; Titel sitzt dicht unter dem Kicker.

## [2.0.0] — 2026-06-16

Überarbeitung der drei PDF-Formate `reader` / `handout` / `tutorial`. **`moodle-html` unverändert.**
Wird per `quarto add c-kraus/thws_quarto` ausgeliefert. Rückfall auf v1:
`quarto add c-kraus/thws_quarto@v1.0.0`.

### ⚠️ Breaking
- **Logo nicht mehr über `logo:`.** Der Key ist von Quartos Brand-System reserviert (kam nur als
  `"true"` an → Build-Fehler). **Migration:** `logo:`-Zeile **entfernen** (das THWS-Logo wird
  automatisch eingebunden) oder durch den format-eigenen Key ersetzen:
  `reader-logo:` / `handout-logo:` / `tutorial-logo:` (+ `…-logo-en:` für Englisch).

### Fixes
- **Bibliography unter Quarto ≥ 1.8.** Quarto erzeugt den `#bibliography(...)`-Call jetzt selbst;
  die Templates taten das zusätzlich → Typst-Fehler „multiple bibliographies are not yet supported".
  Behoben in allen drei Formaten: `bib_file` wird nicht mehr ans Template übergeben, ein
  `show bibliography`-Hook fängt Quartos Call ab und stylt ihn (Überschrift, Schrift, Abstände).

### reader / handout
- THWS-Logo **automatisch** aufgelöst (kein Pfad nötig), **horizontal**, per `lang` de/en.
- Robustes Recolor (weiß auf Cover, orange im Kopf), auch bei SVGs mit eigenem `<style>`.
- Box-Labels folgen `lang` (z. B. „Fallstudie" / „Case Study").
- Neue Inline-Boxen `::: {.merksatz}` und `::: {.begriff title="…"}`; `.flip-card`/`.details`
  farbcodiert. Zitate mit Einzelstrich; kurze Boxen brechen nicht über Seiten.
- Cover/Datum: Blocksatz-Fix, sprachabhängiges Datum (de `16.06.2026` / en `June 16, 2026`).
- Inhaltsverzeichnis: H1-Nummerierung in CI-Orange (reader an handout angeglichen).

### tutorial (Übungsblatt) — neu aufgebaut
- **Lösungen nativ** über `::: {.content-visible when-meta="show_solutions"}` (`show_solutions`-
  Schalter) statt Filter — der Filter ist auf Logo-Auto-Resolve eingedampft.
- **Heading-basiert:** `## Label N: Titel` → Nummern-Badge + Kicker + Seitenumbruch;
  `#### Task N: Titel` → Teilaufgabe (Label folgt `lang`); optional Punkte `[N P]`.
  Voraussetzung: erste Zeile `# Titel` (verankert die Level). Siehe `docs/tutorial/README.md`.
- Masthead nur Modul · Dozent · Ausgabe.

### Aufräumen
- Totes Root-`_extensions/_extension.yml` (verwies auf nicht existierende Templates) und leeres
  `_extensions/logo/` entfernt. Entwickler-Docs nach `docs/` ausgelagert (schlanke Auslieferung).

## [1.0.0] — `main` (Tag `v1.0.0`)
Stabiler Ausgangsstand vor dem Redesign.
