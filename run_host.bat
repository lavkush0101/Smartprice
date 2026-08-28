@echo off
title SmartPrice - Host Runner (Web / Chrome)
echo ========================================================
echo Starting SmartPrice on Host (Chrome Web)
echo ========================================================
echo.
set PATH=D:\flutter\bin;%PATH%

cd /d "d:\MyProject\smartprice\smartprice_mobile"
flutter run -d chrome
pause
