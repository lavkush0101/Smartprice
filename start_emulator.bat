@echo off
title Android Emulator - Pixel 10a
echo ========================================================
echo Starting Android Emulator (Pixel 10a)...
echo ========================================================
echo.
set ANDROID_HOME=D:\Sdk
set ANDROID_SDK_ROOT=D:\Sdk
set PATH=D:\flutter\bin;D:\Sdk\platform-tools;D:\Sdk\emulator;%PATH%

"D:\Sdk\emulator\emulator.exe" -avd Pixel_10a -netdelay none -netspeed full
pause
