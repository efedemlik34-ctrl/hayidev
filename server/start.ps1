# HayiDev Server Baslatici
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  HAYIDEV SERVER" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

# Node.js kontrol
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host "HATA: Node.js kurulu degil!" -ForegroundColor Red
    Write-Host ""
    Write-Host "1. https://nodejs.org git" -ForegroundColor Yellow
    Write-Host "2. LTS surumu indir" -ForegroundColor Yellow
    Write-Host "3. Kur ve tekrar dene" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Kapatmak icin Enter"
    exit 1
}

# npm install (ilk seferde)
if (-not (Test-Path "node_modules")) {
    Write-Host "Paketler yukleniyor (bir kere)..." -ForegroundColor Yellow
    Write-Host ""
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "HATA: npm install basarisiz!" -ForegroundColor Red
        Read-Host "Kapatmak icin Enter"
        exit 1
    }
}

Write-Host ""
Write-Host "Server baslatiliyor..." -ForegroundColor Green
Write-Host ""
node index.js

Write-Host ""
Read-Host "Kapatmak icin Enter"
