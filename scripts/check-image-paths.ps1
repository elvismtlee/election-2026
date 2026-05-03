param(
  [string]$RepoPath = "C:\Users\elvis\Documents\Codex\election-2026"
)

$ErrorActionPreference = "Stop"
Set-Location $RepoPath

Write-Host "Scanning image paths in: $RepoPath"

$targets = Get-ChildItem -Recurse -File -Include *.html,*.md | Where-Object {
  $_.FullName -notmatch "\\.git\\"
}

$issues = @()

function Test-RefPath {
  param(
    [string]$File,
    [string]$RawPath
  )

  if ([string]::IsNullOrWhiteSpace($RawPath)) { return }
  if ($RawPath -match '^(https?:|data:|mailto:|#)') { return }

  $baseDir = Split-Path -Parent $File
  $clean = $RawPath.Split('?')[0].Split('#')[0]

  if ($clean.StartsWith('/')) {
    $resolved = Join-Path $RepoPath $clean.TrimStart('/')
  } else {
    $resolved = Join-Path $baseDir $clean
  }

  if (-not (Test-Path $resolved)) {
    $issues += [PSCustomObject]@{
      File = $File
      RefPath = $RawPath
      Resolved = $resolved
    }
  }
}

foreach ($f in $targets) {
  $content = Get-Content -Raw -Encoding UTF8 $f.FullName

  $htmlImgs = [regex]::Matches($content, '<img[^>]+src="([^"]+)"')
  foreach ($m in $htmlImgs) {
    Test-RefPath -File $f.FullName -RawPath $m.Groups[1].Value
  }

  $mdImgs = [regex]::Matches($content, '!\[[^\]]*\]\(([^\)]+)\)')
  foreach ($m in $mdImgs) {
    Test-RefPath -File $f.FullName -RawPath $m.Groups[1].Value
  }
}

if ($issues.Count -eq 0) {
  Write-Host "OK: no broken image links found."
  exit 0
}

Write-Host "Found broken image paths:" -ForegroundColor Yellow
$issues | Sort-Object File, RefPath | Format-Table -AutoSize
exit 1
