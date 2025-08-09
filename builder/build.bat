@echo off
setlocal enabledelayedexpansion

FOR %%A IN ("%~dp0..") DO set "root_path=%%~fA"

if not "%MARKET_OUTPUT_PATH%"=="" (
    set "output=%MARKET_OUTPUT_PATH%\market.lua"
) else (
    set "desktop_path=%USERPROFILE%\Desktop"
    set "output=%desktop_path%\market.lua"
)

set "main_folder=%root_path%"
set "main_module=main"
set "tmp_modules=%~dp0__modules.txt"
del "%tmp_modules%" >nul 2>&1

echo [INFO] Building from: %main_folder%
echo [INFO] Output file: %output%
echo [INFO] Generating module list...

echo %main_module%>>"%tmp_modules%"

for /R "%main_folder%" %%f in (*.lua) do (
    set "filepath=%%~f"
    set "relpath=!filepath:%main_folder%\=!"
    for /f "delims=\ tokens=1" %%p in ("!relpath!") do set "firstfolder=%%p"

    if /I not "!firstfolder!"=="builder" (
        set "modpath=!relpath:.lua=!"
        set "modpath=!modpath:\=.!"
        echo !modpath!>>"%tmp_modules%"
    )
)

set "entrypoints="
for /f "usebackq delims=" %%l in ("%tmp_modules%") do (
    set "entrypoints=!entrypoints! %%l"
)

lua53 "%~dp0luacc.lua" -o "%output%" -i "%main_folder%" !entrypoints!

del "%tmp_modules%" >nul 2>&1

echo [OK] Build finalized: %output%
pause
