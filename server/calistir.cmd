@echo off
title HayiDev
cd /d "%~dp0"
echo.
echo HayiDev Server baslatiliyor...
echo.
where node >nul 2>nul
if errorlevel 1 goto nonode
if not exist node_modules goto install
goto start

:install
echo Paketler yukleniyor...
call npm install
if errorlevel 1 goto npmfail

:start
echo Server calisiyor...
node index.js
goto end

:nonode
echo HATA: Node.js kurulu degil!
echo.
echo Node.js indir: https://nodejs.org
goto end

:npmfail
echo HATA: npm install basarisiz!
goto end

:end
pause