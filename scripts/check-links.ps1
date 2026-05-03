param(
  [string]$RepoPath = "C:\Users\elvis\Documents\Codex\election-2026"
)

$ErrorActionPreference = "Stop"
Set-Location $RepoPath

$htmlFiles = Get-ChildItem -Recurse -File -Include *.html | Where-Object { $_.FullName -notmatch "\\.git\\" }
$issues = @()

foreach ($file in $htmlFiles) {
  $content = Get-Content -Raw -Encoding UTF8 $file.FullName
  $matches = [regex]::Matches($content, 'href="([^"]+)"')

  foreach ($m in $matches) {
    $href = $m.Groups[1].Value
    if ($href -match '^(https?:|mailto:|#|javascript:)') { continue }

    $baseDir = Split-Path -Parent $file.FullName
    if ($href.StartsWith('/')) {
      $target = Join-Path $RepoPath $href.TrimStart('/')
    } else {
      $target = Join-Path $baseDir $href
    }

    $target = $target.Split('#')[0].Split('?')[0]
    if (-not (Test-Path $target)) {
      $issues += [PSCustomObject]@{ File = $file.FullName; Link = $href; Resolved = $target }
    }
  }
}

if ($issues.Count -eq 0) {
  Write-Host "OK: no broken relative links found."
  exit 0
}

Write-Host "Found broken relative links:" -ForegroundColor Yellow
$issues | Format-Table -AutoSize
exit 1
