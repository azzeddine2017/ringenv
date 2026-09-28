@echo off
rem ringenv launcher for Windows Command Prompt and PowerShell
setlocal enabledelayedexpansion

rem Capture caller current working directory
set "RINGENV_CALLER_DIR=%CD%"

rem Locate ringenv script directory
if exist "%~dp0..\tools\ringpm\packages\ringenv\main.ring" (
    set "RINGENV_DIR=%~dp0..\tools\ringpm\packages\ringenv"
) else if exist "%~dp0..\tools\ringenv\main.ring" (
    set "RINGENV_DIR=%~dp0..\tools\ringenv"
) else if exist "%~dp0main.ring" (
    set "RINGENV_DIR=%~dp0"
) else if exist "%~dp0..\main.ring" (
    set "RINGENV_DIR=%~dp0.."
) else (
    echo Error: Could not locate ringenv main.ring script.
    exit /b 1
)

rem Switch to ringenv directory so Ring can load relative modules, then restore caller directory
pushd "%RINGENV_DIR%"
ring main.ring %*
set "EXIT_CODE=%ERRORLEVEL%"
popd

exit /b %EXIT_CODE%
