@echo off
rem ringenv local installer for Windows
setlocal enabledelayedexpansion

echo =================================================
echo Installing ringenv CLI to active Ring environment
echo =================================================

rem Locate ring.exe in PATH
for /f "delims=" %%I in ('where ring.exe 2^>nul') do (
    set "RING_EXE=%%I"
    goto :FoundRing
)

:FoundRing
if not defined RING_EXE (
    echo Error: ring.exe was not found in system PATH.
    echo Please make sure Ring is installed and added to PATH.
    exit /b 1
)

for %%I in ("%RING_EXE%") do set "RING_BIN=%%~dpI"
set "RING_ROOT=%RING_BIN%..\"
set "TARGET_PKG=%RING_ROOT%tools\ringpm\packages\ringenv"

echo Found Ring binary directory: %RING_BIN%
echo Target package directory:    %TARGET_PKG%

rem Ensure target package directories exist
if not exist "%TARGET_PKG%\src\core" mkdir "%TARGET_PKG%\src\core"
if not exist "%TARGET_PKG%\src\commands" mkdir "%TARGET_PKG%\src\commands"
if not exist "%TARGET_PKG%\bin" mkdir "%TARGET_PKG%\bin"
if not exist "%TARGET_PKG%\docs" mkdir "%TARGET_PKG%\docs"

rem Copy project files
copy /y "%~dp0main.ring" "%TARGET_PKG%\" >nul
copy /y "%~dp0package.ring" "%TARGET_PKG%\" >nul
copy /y "%~dp0README.md" "%TARGET_PKG%\" >nul
copy /y "%~dp0src\core\*.ring" "%TARGET_PKG%\src\core\" >nul
copy /y "%~dp0src\commands\*.ring" "%TARGET_PKG%\src\commands\" >nul
copy /y "%~dp0bin\ringenv.bat" "%TARGET_PKG%\bin\" >nul
copy /y "%~dp0bin\ringenv" "%TARGET_PKG%\bin\" >nul
copy /y "%~dp0docs\*.md" "%TARGET_PKG%\docs\" >nul

rem Install launcher in Ring bin directory
copy /y "%~dp0bin\ringenv.bat" "%RING_BIN%ringenv.bat" >nul

echo =================================================
echo ringenv successfully installed!
echo You can now use 'ringenv' from any directory:
echo   ringenv --version
echo   ringenv list
echo   ringenv install 1.27
echo   ringenv venv create .rvenv --version 1.27
echo =================================================
endlocal
