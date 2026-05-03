(function () {
  const input = document.getElementById("searchInput");
  const chips = Array.from(document.querySelectorAll(".chip"));
  const cards = Array.from(document.querySelectorAll(".news-card"));

  let activeFilter = "all";

  function applyFilters() {
    const q = (input.value || "").trim().toLowerCase();

    cards.forEach((card) => {
      const category = card.dataset.category || "";
      const text = (card.textContent || "").toLowerCase();
      const keywords = (card.dataset.keywords || "").toLowerCase();

      const matchFilter = activeFilter === "all" || category === activeFilter;
      const matchSearch = !q || text.includes(q) || keywords.includes(q);

      card.style.display = matchFilter && matchSearch ? "block" : "none";
    });
  }

  chips.forEach((chip) => {
    chip.addEventListener("click", () => {
      chips.forEach((c) => c.classList.remove("active"));
      chip.classList.add("active");
      activeFilter = chip.dataset.filter || "all";
      applyFilters();
    });
  });

  input.addEventListener("input", applyFilters);
  applyFilters();
})();
