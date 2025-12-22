<script>
  document.addEventListener("DOMContentLoaded", function() {

  // -----------------------------------------------------------
  // 0. Language Detection & Dictionary
  // -----------------------------------------------------------
  // Wir prüfen das <html lang="de"> Tag. Fallback ist Deutsch.
  const pageLang = document.documentElement.lang || 'de';
    const isEn = pageLang.startsWith('en');

    const t = {
      check: isEn ? "Check" : "Prüfen",
    testKnowledge: isEn ? "Test your knowledge:" : "Testen Sie Ihr Wissen:",
    correct: isEn ? "Correct!" : "Richtig!",
    wrong: isEn ? "Not quite." : "Leider nicht ganz.",

    // Case Study / Reflection
    placeholder: isEn
    ? "Write down your thoughts here before viewing the solution..."
    : "Notieren Sie hier Ihre Gedanken, bevor Sie die Lösung ansehen...",
    reveal: isEn ? "Compare solution" : "Lösung vergleichen",
    hide: isEn ? "Hide solution" : "Lösung wieder ausblenden"
  };

    // -----------------------------------------------------------
    // MODUL 1: Click-to-Select (Gap Text)
    // -----------------------------------------------------------
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

        // HIER: Sprachvariable t.check nutzen
        newHtml += `</div><div class="click-pool"></div><button class="check-btn">${t.check}</button>`;
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


      // -----------------------------------------------------------
      // MODUL 2: Flip-Cards (Sprachneutral, da Symbole)
      // -----------------------------------------------------------
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


      // -----------------------------------------------------------
      // MODUL 3: Quick-Check (Quiz)
      // -----------------------------------------------------------
      try {
        document.querySelectorAll(".quick-check").forEach(qc => {
          const listItems = qc.querySelectorAll("li");
          const explanationBlock = qc.querySelector("blockquote");
          const explanation = explanationBlock ? explanationBlock.innerHTML : "";

          // HIER: Sprachvariable t.testKnowledge als Fallback
          let questionText = t.testKnowledge;

          const firstList = qc.querySelector("ul, ol");
          const paragraphs = Array.from(qc.querySelectorAll("p"));
          const qp = paragraphs.find(p =>
            (!firstList || (p.compareDocumentPosition(firstList) & Node.DOCUMENT_POSITION_FOLLOWING)) &&
            (!explanationBlock || !explanationBlock.contains(p))
          );

          if (qp) {
            questionText = qp.innerHTML;
          } else {
            let node = qc.firstChild;
            let collectedText = "";
            while (node && node !== firstList && node !== explanationBlock) {
              if (node.nodeType === 3) collectedText += node.textContent;
              else if (node.nodeType === 1 && node.tagName !== "UL" && node.tagName !== "OL" && node.tagName !== "BLOCKQUOTE") {
                collectedText += node.innerText;
              }
              node = node.nextSibling;
            }
            if (collectedText.trim().length > 0) questionText = collectedText.trim();
          }

          let html = `<div class="qc-question">${questionText}</div><div class="qc-options">`;

          listItems.forEach(li => {
            const isCorrect = li.querySelector("strong, b") !== null;
            const text = li.textContent.trim();
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
                // HIER: Sprachvariable t.correct
                feedback.innerHTML = `<strong>${t.correct}</strong> ` + feedback.innerHTML;
              } else {
                btn.classList.add("wrong");
                btns.forEach(b => { if (b.dataset.correct === "true") b.classList.add("correct-dimmed"); });
                feedback.classList.add("show-wrong");
                // HIER: Sprachvariable t.wrong
                feedback.innerHTML = `<strong>${t.wrong}</strong> ` + feedback.innerHTML;
              }
              feedback.style.display = "block";
            });
          });
        });
  } catch (e) {console.error("Error in Quiz Module:", e); }


      // -----------------------------------------------------------
      // MODUL 4: Reflection Pattern (Case Study)
      // -----------------------------------------------------------
      try {
    const cases = document.querySelectorAll('.case-study');

    cases.forEach((caseBox) => {
      const solution = caseBox.querySelector('.solution');

      if (solution) {
        // 1. Textfeld
        const inputArea = document.createElement('textarea');
      inputArea.className = 'student-input';
      // HIER: Sprachvariable t.placeholder
      inputArea.placeholder = t.placeholder;

      // 2. Button
      const button = document.createElement('button');
      button.className = 'reveal-btn';
      // HIER: Sprachvariable t.reveal
      button.innerText = t.reveal;

      // 3. Einfügen
      caseBox.insertBefore(inputArea, solution);
      caseBox.insertBefore(button, solution);

      // 4. Klick-Logik
      button.addEventListener('click', function() {
          if (solution.style.display === 'block') {
        solution.style.display = 'none';
      // HIER: Variable t.reveal (wieder zurück)
      button.innerText = t.reveal;
          } else {
        solution.style.display = 'block';
      // HIER: Variable t.hide
      button.innerText = t.hide;
          }
        });
      }
    });
  } catch (e) {console.error("Error in Reflection Module:", e); }

});
    </script>