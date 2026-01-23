#show: doc => project(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$

// FIX: Reihenfolge gedreht & 'it.role' in der Schleife benutzt
$if(by-author)$
  authors: (
    $for(by-author)$
    (
      // 1. Name: Tilden weg
      name: "$it.name.literal$".replace("~", " "),
      
      // 2. Email: Backslashes weg
      $if(it.email)$ email: "$it.email$".replace("\\", ""), $endif$

      // 3. Rolle
      // Wir prüfen ZUERST auf den einfachen String 'role'. 
      // Das verhindert, dass "Program Lead" zerhackt wird.
      $if(it.role)$
        role: "$it.role$".replace("\\", ""),
      $else$
        // Falls keine einzelne Rolle da ist, schauen wir in die Liste.
        // WICHTIG: Hier '$it.role$' nutzen, nicht '$it$'!
        $if(it.roles)$
          role: "$for(it.roles)$$it.role$$sep$ $endfor$".replace("\\", ""),
        $endif$
      $endif$

      // 4. Affiliation
      $if(it.affiliations)$
        affiliation: "$for(it.affiliations)$$it.name$$sep$, $endfor$".replace("\\", ""),
      $endif$
    ),
    $endfor$
  ),
$endif$

$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$

// Optionale Overrides
$if(course)$ course: [$course$], $endif$
$if(semester)$ semester: [$semester$], $endif$
$if(faculty)$ faculty: [$faculty$], $endif$
$if(university)$ university: [$university$], $endif$
$if(version)$ version: [$version$], $endif$

// Layout-Steuerung
$if(outline-depth)$ outline_depth: $outline-depth$, $endif$
$if(show-outline)$ show_outline: $show-outline$, $endif$

// Bibliographie
//$if(bibliography)$ bib_file: "$bibliography$", $endif$
//$if(biblio-style)$ citation_style: "$biblio-style$", $endif$
  doc,
)