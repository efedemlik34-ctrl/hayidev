@echo off
title HayiDev Server
color 0A
cd /d "%~dp0"

echo.
echo ==========================================
echo   HAYIDEV SERVER
echo ==========================================
echo.

where node >nul 2>nul
if errorlevel 1 (
    echo [HATA] Node.js kurulu degil!
    echo.
    echo 1. https://nodejs.org git
    echo 2. LTS surumu indir
    echo 3. Kur ve tekrar dene
    echo.
    pause
    exit /b 1
)

if not exist node_modules (
    echo Paketler yukleniyor (bir kere)...
    echo.
    call npm install
    if errorlevel 1 (
        echo.
        echo [HATA] npm install basarisiz!
        pause
        exit /b 1
    )
)

echo.
echo Server baslatiliyor...
echo.
node index.js

pause
