<script>
  document.addEventListener("DOMContentLoaded", function() {

 // --- 0. KONFIGURATION (Automatische Spracherkennung) ---
  // Wir lesen das "lang"-Attribut aus dem HTML-Tag (das Quarto setzt)
  const currentLang = document.documentElement.lang || 'en';
  const isGerman = currentLang.startsWith('de'); // Erkennt 'de', 'de-DE', 'de-AT'

  const t = isGerman ? {
    // DEUTSCH
    placeholder: "Ihre Überlegungen hier notieren...",
  reveal: "Lösung anzeigen",
  hide: "Lösung verbergen"
  } : {
    // ENGLISCH (Fallback)
    placeholder: "Write your thoughts here...",
  reveal: "Show Solution",
  hide: "Hide Solution"
  };

  // --- MODUL 1: Click-to-Select (Gap Text) ---
  try {
    const dragExercises = document.querySelectorAll(".drag-exercise");
    dragExercises.forEach((ex) => {
      const originalHTML = ex.innerHTML;
  const parts = originalHTML.split(/(<em>.*?<\/em>)/g);

    let newHtml = '<div class="click-text">';
      let words = [];
      let wordIdCounter = 0;
      
      parts.forEach(part => {
        if (part.startsWith("<em>") && part.endsWith("</em>")) {
          const wordText = part.replace("<em>", "").replace("</em>", "");
      words.push({text: wordText, id: wordIdCounter++ });
      newHtml += `<span class="click-gap" data-answer="${wordText}"></span>`;
        } else {
        newHtml += part;
        }
      });

      newHtml += '</div><div class="click-pool"></div><button class="check-btn">Check</button>';
    ex.innerHTML = newHtml;

    let selectedWordBtn = null;
    const pool = ex.querySelector(".click-pool");
      
      words.sort(() => Math.random() - 0.5);

      words.forEach(w => {
        const btn = document.createElement("button");
    btn.textContent = w.text;
    btn.classList.add("pool-word");
    btn.dataset.id = w.id;
        
        btn.addEventListener("click", () => {
          if (btn.classList.contains("used")) return;
    if (selectedWordBtn) selectedWordBtn.classList.remove("selected");
    selectedWordBtn = btn;
    btn.classList.add("selected");
        });
    pool.appendChild(btn);
      });

    const gaps = ex.querySelectorAll(".click-gap");
      gaps.forEach(gap => {
      gap.addEventListener("click", () => {
        if (gap.classList.contains("filled")) {
          const currentId = gap.dataset.currentId;
          const originalBtn = pool.querySelector(`.pool-word[data-id="${currentId}"]`);
          if (originalBtn) originalBtn.classList.remove("used");

          gap.textContent = "";
          gap.classList.remove("filled", "correct", "wrong");
          delete gap.dataset.currentId;
          return;
        }
        if (selectedWordBtn) {
          gap.textContent = selectedWordBtn.textContent;
          gap.classList.add("filled");
          gap.dataset.currentId = selectedWordBtn.dataset.id;

          selectedWordBtn.classList.remove("selected");
          selectedWordBtn.classList.add("used");
          selectedWordBtn = null;
        }
      });
      });

      ex.querySelector(".check-btn").addEventListener("click", () => {
      gaps.forEach(gap => {
        if (!gap.classList.contains("filled")) return;
        if (gap.textContent.trim() === gap.dataset.answer.trim()) {
          gap.classList.add("correct");
          gap.classList.remove("wrong");
        } else {
          gap.classList.add("wrong");
          gap.classList.remove("correct");
        }
      });
      });
    });
  } catch (e) {console.error("Error in Drag Module:", e); }


    // --- MODUL 2: Flip-Cards ---
    try {
    const cards = document.querySelectorAll(".flip-card");
    cards.forEach(card => {
      const title = card.querySelector("h4");
    if(!title) return;

    const content = card.innerHTML.replace(title.outerHTML, "");

    card.innerHTML = `
    <div class="flip-inner">
      <div class="flip-front">
        <div class="flip-content">
          <span class="flip-icon">↻</span>
          <h4>${title.innerHTML}</h4>
        </div>
      </div>
      <div class="flip-back">
        <div class="flip-content">${content}</div>
      </div>
    </div>
    `;
      
      card.addEventListener("click", () => {
      card.classList.toggle("flipped");
      });
    });
  } catch (e) {console.error("Error in Flip-Card Module:", e); }


    // --- MODUL 3: Quick-Check (Quiz) ---
    try {
      document.querySelectorAll(".quick-check").forEach(qc => {
        const listItems = qc.querySelectorAll("li");
        const explanationBlock = qc.querySelector("blockquote");
        const explanation = explanationBlock ? explanationBlock.innerHTML : "";

        let questionText = "Test your knowledge:";
        const p = qc.querySelector("p");
        if (p && p !== explanationBlock) questionText = p.innerHTML;
        else if (qc.firstChild.nodeType === 3) questionText = qc.firstChild.textContent;

        let html = `<div class="qc-question">${questionText}</div><div class="qc-options">`;

        listItems.forEach(li => {
          const isCorrect = li.querySelector("strong") !== null;
          const text = li.textContent;
          html += `<button class="qc-btn" data-correct="${isCorrect}">${text}</button>`;
        });

        html += `</div><div class="qc-feedback" style="display:none;">${explanation}</div>`;
        qc.innerHTML = html;

        const btns = qc.querySelectorAll(".qc-btn");
        const feedback = qc.querySelector(".qc-feedback");

        btns.forEach(btn => {
          btn.addEventListener("click", () => {
            btns.forEach(b => b.disabled = true);

            if (btn.dataset.correct === "true") {
              btn.classList.add("correct");
              feedback.classList.add("show-correct");
              feedback.innerHTML = "<strong>Correct!</strong> " + feedback.innerHTML;
            } else {
              btn.classList.add("wrong");
              btns.forEach(b => { if (b.dataset.correct === "true") b.classList.add("correct-dimmed"); });
              feedback.classList.add("show-wrong");
              feedback.innerHTML = "<strong>Not quite.</strong> " + feedback.innerHTML;
            }
            feedback.style.display = "block";
          });
        });
      });
  } catch (e) {console.error("Error in Quiz Module:", e); }


    // --- MODUL 4: Reflection Pattern (Case Study) ---
    try {
    const cases = document.querySelectorAll('.case-study');

    cases.forEach((caseBox) => {
      const solution = caseBox.querySelector('.solution');

    if (solution) {
        // 1. Textfeld
        const inputArea = document.createElement('textarea');
    inputArea.className = 'student-input';
    inputArea.placeholder = t.placeholder;

    // 2. Button
    const button = document.createElement('button');
    button.className = 'reveal-btn';
    button.innerText = t.reveal;

    // 3. Einfügen
    caseBox.insertBefore(inputArea, solution);
    caseBox.insertBefore(button, solution);

    // 4. Klick-Logik
    button.addEventListener('click', function() {
          if (solution.style.display === 'block') {
      solution.style.display = 'none';
    button.innerText = t.reveal;
          } else {
      solution.style.display = 'block';
    button.innerText = t.hide;
          }
        });
      }
    });
  } catch (e) {console.error("Error in Reflection Module:", e); }

    // WICHTIG: Erst hier endet der Event-Listener für alle Module!

    // --- MODUL 5: Sidebar Logo ---

    try {

const logoData = document.getElementById('logo-data');

    if (logoData) {

const logoSrc = logoData.dataset.logoSrc;

    if (logoSrc) {

const sidebar = document.getElementById('quarto-margin-sidebar');

    const toc = document.getElementById('TOC');



    if (sidebar && toc) {

// Logo-Container erstellen

const logoContainer = document.createElement('div');

    logoContainer.className = 'sidebar-logo';

    logoContainer.innerHTML = `<img src="${logoSrc}" alt="Logo">`;



      // Vor dem TOC einfügen

      sidebar.insertBefore(logoContainer, toc);

}

}

      // Verstecktes Element entfernen (Aufräumen)

      logoData.remove();

}

} catch (e) {console.error("Error in Sidebar Logo Module:", e); }
});
    </script>
