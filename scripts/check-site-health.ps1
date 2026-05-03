param(
  [string]$RepoPath = "C:\Users\elvis\Documents\Codex\election-2026"
)

$ErrorActionPreference = "Stop"
Set-Location $RepoPath

$errors = @()

$mustFiles = @(
  "index.html",
  "styles/v3.css",
  "scripts/v3.js",
  "daily/2026-05-03-report-v3.html",
  "daily/2026-05-03-gallery-v3.html",
  "daily/2026-05-03-video-kit-v3.html",
  "daily/2026-05-03-sources-review-v3.html",
  "assets/daily/2026-05-03/1.png",
  "assets/daily/2026-05-03/2.png",
  "assets/daily/2026-05-03/3.png",
  "assets/daily/2026-05-03/4.png"
)

foreach ($f in $mustFiles) {
  if (-not (Test-Path (Join-Path $RepoPath $f))) {
    $errors += "Missing file: $f"
  }
}

if (Test-Path (Join-Path $RepoPath "index.html")) {
  $index = Get-Content -Raw -Encoding UTF8 (Join-Path $RepoPath "index.html")
  $requiredText = @("今日快訊", "市民實用工具", "今日 3 件可立即行動", "來源與審核狀態")
  foreach ($t in $requiredText) {
    if ($index -notmatch [regex]::Escape($t)) {
      $errors += "Index missing section text: $t"
    }
  }
}

if ($errors.Count -gt 0) {
  Write-Host "Site health check failed:" -ForegroundColor Red
  $errors | ForEach-Object { Write-Host "- $_" }
  exit 1
}

Write-Host "OK: site health check passed."
exit 0
