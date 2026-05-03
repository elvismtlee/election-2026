(function () {
  const stamp = document.getElementById("lastUpdated");
  if (!stamp) return;

  // Keep visible timestamp format stable and friendly.
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, "0");
  const d = String(now.getDate()).padStart(2, "0");
  const hh = String(now.getHours()).padStart(2, "0");
  const mm = String(now.getMinutes()).padStart(2, "0");

  stamp.textContent = `${y}-${m}-${d} ${hh}:${mm}（Asia/Taipei）`;
})();
