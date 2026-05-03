param(
  [string]$RepoPath = "C:\Users\elvis\Documents\Codex\election-2026"
)

$ErrorActionPreference = "Stop"
Set-Location $RepoPath

$files = @(
  "daily/2026-05-03-report-v3.html",
  "daily/2026-05-03-gallery-v3.html",
  "daily/2026-05-03-video-kit-v3.html",
  "daily/2026-05-03-sources-review-v3.html"
)

$errors = @()
foreach ($f in $files) {
  if (-not (Test-Path (Join-Path $RepoPath $f))) {
    $errors += "Missing second-level file: $f"
  }
}

foreach ($f in $files) {
  $p = Join-Path $RepoPath $f
  if (-not (Test-Path $p)) { continue }
  $content = Get-Content -Raw -Encoding UTF8 $p
  $matches = [regex]::Matches($content, 'href="([^"]+)"')
  foreach ($m in $matches) {
    $href = $m.Groups[1].Value
    if ($href -match '^(https?:|mailto:|#|javascript:)') { continue }
    $base = Split-Path -Parent $p
    $resolved = Join-Path $base $href
    $resolved = $resolved.Split('#')[0].Split('?')[0]
    if (-not (Test-Path $resolved)) {
      $errors += "Broken link in $f => $href"
    }
  }
}

if ($errors.Count -gt 0) {
  Write-Host "Second-level check failed:" -ForegroundColor Red
  $errors | ForEach-Object { Write-Host "- $_" }
  exit 1
}

Write-Host "OK: second-level pages are complete and links are valid."
exit 0
