@echo off
title SmartPrice Mobile - Flutter Runner
echo ========================================================
echo Starting SmartPrice Flutter Mobile App
echo ========================================================
echo.
set ANDROID_HOME=D:\Sdk
set ANDROID_SDK_ROOT=D:\Sdk
set JAVA_HOME=C:\Program Files\Microsoft\jdk-21.0.12.101-hotspot
set PATH=D:\flutter\bin;D:\Sdk\platform-tools;D:\Sdk\emulator;%PATH%

echo Configuring backend reverse port forwarding...
adb reverse tcp:8000 tcp:8000

cd /d "d:\MyProject\smartprice\smartprice_mobile"
flutter run
pause
