@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0.."
if not exist node_modules (
  echo [1/6] Installing Capacitor packages...
  call npm install || exit /b 1
) else (
  echo [1/6] node_modules already exists.
)
if not exist android (
  echo [2/6] Creating Android platform...
  call npx cap add android || exit /b 1
) else (
  echo [2/6] Android platform already exists.
)
echo [3/6] Syncing web assets and plugins...
call npx cap sync android || exit /b 1

echo [4/6] Installing TITAN PULSE launcher/notification resources...
set "RES=android\app\src\main\res"
for %%D in (mdpi hdpi xhdpi xxhdpi xxxhdpi) do (
  if not exist "%RES%\mipmap-%%D" mkdir "%RES%\mipmap-%%D"
  if not exist "%RES%\drawable-%%D" mkdir "%RES%\drawable-%%D"
  copy /Y "android-res\app\src\main\res\mipmap-%%D\ic_launcher.png" "%RES%\mipmap-%%D\ic_launcher.png" >nul
  copy /Y "android-res\app\src\main\res\mipmap-%%D\ic_launcher_round.png" "%RES%\mipmap-%%D\ic_launcher_round.png" >nul
  copy /Y "android-res\app\src\main\res\mipmap-%%D\ic_launcher_foreground.png" "%RES%\mipmap-%%D\ic_launcher_foreground.png" >nul
  copy /Y "android-res\app\src\main\res\drawable-%%D\ic_notification.png" "%RES%\drawable-%%D\ic_notification.png" >nul
)
if not exist "%RES%\drawable" mkdir "%RES%\drawable"
copy /Y "android-res\app\src\main\res\drawable\ic_notification.png" "%RES%\drawable\ic_notification.png" >nul

if not exist "%RES%\values" mkdir "%RES%\values"
>"%RES%\values\titan_colors.xml" echo ^<?xml version="1.0" encoding="utf-8"?^>
>>"%RES%\values\titan_colors.xml" echo ^<resources^>
>>"%RES%\values\titan_colors.xml" echo     ^<color name="titan_launcher_background"^>#05060A^</color^>
>>"%RES%\values\titan_colors.xml" echo ^</resources^>
if not exist "%RES%\mipmap-anydpi-v26" mkdir "%RES%\mipmap-anydpi-v26"
>"%RES%\mipmap-anydpi-v26\ic_launcher.xml" echo ^<?xml version="1.0" encoding="utf-8"?^>
>>"%RES%\mipmap-anydpi-v26\ic_launcher.xml" echo ^<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"^>
>>"%RES%\mipmap-anydpi-v26\ic_launcher.xml" echo     ^<background android:drawable="@color/titan_launcher_background" /^>
>>"%RES%\mipmap-anydpi-v26\ic_launcher.xml" echo     ^<foreground android:drawable="@mipmap/ic_launcher_foreground" /^>
>>"%RES%\mipmap-anydpi-v26\ic_launcher.xml" echo ^</adaptive-icon^>
copy /Y "%RES%\mipmap-anydpi-v26\ic_launcher.xml" "%RES%\mipmap-anydpi-v26\ic_launcher_round.xml" >nul


echo [5/6] Ensuring Android notification permissions are present...
set "MANIFEST=android\app\src\main\AndroidManifest.xml"
if exist "%MANIFEST%" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='%MANIFEST%'; $s=Get-Content -Raw -LiteralPath $p; $nl=[Environment]::NewLine; $adds=@(); if($s -notmatch 'android.permission.POST_NOTIFICATIONS'){ $adds += '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />' }; if($s -notmatch 'android.permission.SCHEDULE_EXACT_ALARM'){ $adds += '    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />' }; if($adds.Count -gt 0){ $m=[regex]::Match($s,'<manifest\b[^>]*>'); if($m.Success){ $insert=$nl + ($adds -join $nl) + $nl; $s=$s.Insert($m.Index+$m.Length,$insert) } }; Set-Content -LiteralPath $p -Value $s -Encoding UTF8"
)

echo [6/6] Done.
echo.
echo TITAN PULSE Android platform is ready.
echo Debug:   cd android ^&^& gradlew.bat assembleDebug
echo Release: cd android ^&^& gradlew.bat assembleRelease
exit /b 0
