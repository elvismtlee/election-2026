$ErrorActionPreference = "Stop"
Set-Location "C:\Users\elvis\Documents\Codex\election-2026"

$reports = Get-ChildItem -File -Filter "chiayi-daily-report-????-??-??.md"
if (-not $reports) { Write-Host "找不到日報檔"; exit 0 }

$latest = $reports |
  ForEach-Object {
    if ($_.BaseName -match "^chiayi-daily-report-(\d{4}-\d{2}-\d{2})$") {
      [PSCustomObject]@{
        File = $_.Name
        Date = [datetime]::ParseExact($Matches[1], "yyyy-MM-dd", $null)
      }
    }
  } |
  Sort-Object Date -Descending |
  Select-Object -First 1

if (-not $latest) { Write-Host "檔名格式不符"; exit 1 }

$latestFile = $latest.File
$latestDate = $latest.Date.ToString("yyyy-MM-dd")
$indexPath = "index.html"

$html = Get-Content -Raw -Encoding UTF8 $indexPath
$html = [regex]::Replace($html, '(<a class="btn btn-primary" href="\./)([^"]+)(">)', "`$1$latestFile`$3")
$html = [regex]::Replace($html, 'chiayi-daily-(news|report)-\d{4}-\d{2}-\d{2}\.md', $latestFile)
$html = [regex]::Replace($html, '更新時間：\d{4}-\d{2}-\d{2}（Asia/Taipei）', "更新時間：$latestDate（Asia/Taipei）")
Set-Content -Encoding UTF8 -Path $indexPath -Value $html

git add $indexPath
$staged = git diff --cached --name-only
if ([string]::IsNullOrWhiteSpace($staged)) {
  Write-Host "首頁無需更新，未提交。"
  exit 0
}

git commit -m "auto: set homepage latest report $latestDate"
git push origin main
Write-Host "完成：首頁已更新為 $latestFile 並推送。"
