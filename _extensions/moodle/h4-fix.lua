-- ============================================

-- LOGO-HEADER LOGIK

-- ============================================

-- Fügt das Logo aus den Metadaten ein (falls vorhanden)

  

function Pandoc(doc)

-- Nur für HTML-Output

if not quarto.doc.is_format("html") then

return nil

end

  

-- Logo-Pfad aus Metadaten lesen

local logo_path = nil

if doc.meta.logo then

logo_path = pandoc.utils.stringify(doc.meta.logo)

end

  

-- Wenn kein Logo definiert, nichts ändern

if not logo_path or logo_path == "" then

return nil

end

  

-- Verstecktes Element mit Logo-Pfad für JavaScript

-- JavaScript fügt das Logo dann in die Sidebar ein

local logo_html = string.format([[

<div id="logo-data" data-logo-src="%s" style="display:none;"></div>

]], logo_path)

  

-- Logo-Data-Block am Anfang des Dokuments einfügen

local logo_block = pandoc.RawBlock("html", logo_html)

table.insert(doc.blocks, 1, logo_block)

  

return doc

end

-- Hilfsfunktion: Trennt Titel (H4) vom Inhalt
local function split_title_content(el)
  local title_text = "Hinweis" -- Fallback
  local content_blocks = pandoc.Blocks({})

  for _, block in ipairs(el.content) do
    if block.t == "Header" and block.level == 4 then
      title_text = pandoc.utils.stringify(block.content)
    else
      content_blocks:insert(block)
    end
  end
  return title_text, content_blocks
end

-- 1. HEADER LOGIK: H4 wird in diesen Boxen ausgeblendet
function Header(el)
  if el.level == 4 then
    el.classes:insert('unnumbered')
    el.classes:insert('unlisted')
  end
  return el
end

-- 2. DIV LOGIK: Die Weiche für Hybrid-Publishing
function Div(el)
  -- Prüfen, ob es eine unserer Spezial-Boxen ist
  local is_card = el.classes:includes("flip-card")
  local is_details = el.classes:includes("details")

  if not (is_card or is_details) then
    return nil
  end

  -- A) FÜR PDF (TYPST)
  -- Wir verwandeln BEIDES in statische Boxen via #flashcard
  if quarto.doc.is_format("typst") then
    local title, content = split_title_content(el)
    local result = pandoc.Blocks({})

    -- Sandwich-Methode für Typst
    result:insert(pandoc.RawBlock("typst", "#flashcard(title: [" .. title .. "])[\n"))
    result:extend(content)
    result:insert(pandoc.RawBlock("typst", "\n]"))

    return result
  end

  -- B) FÜR WEB (HTML)
  -- Flipcards lassen wir in Ruhe (macht Ihr JS).
  -- Aber "details" müssen wir in echte HTML-Tags wandeln.
  if quarto.doc.is_format("html") then
    if is_details then
      local title, content = split_title_content(el)
      local result = pandoc.Blocks({})

      result:insert(pandoc.RawBlock("html", "<details><summary>" .. title .. "</summary>"))
      result:extend(content)
      result:insert(pandoc.RawBlock("html", "</details>"))

      return result
    end
  end
end
