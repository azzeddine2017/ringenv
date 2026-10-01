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

rem Locate host Ring compiler binary
if exist "%~dp0ring.exe" (
    set "RING_EXE=%~dp0ring.exe"
    set "HOST_RING_DIR=%~dp0.."
) else (
    set "RING_EXE=ring"
    set "HOST_RING_DIR="
)

rem Temporarily isolate RINGPATH to host Ring so virtual environments don't break ringenv itself
set "_SAVED_RINGPATH=%RINGPATH%"
if defined HOST_RING_DIR (
    set "RINGPATH=%HOST_RING_DIR%"
)

rem Switch to ringenv directory so Ring can load relative modules, then restore caller directory
pushd "%RINGENV_DIR%"
"%RING_EXE%" main.ring %*
set "EXIT_CODE=%ERRORLEVEL%"
popd

rem Restore caller RINGPATH
set "RINGPATH=%_SAVED_RINGPATH%"

exit /b %EXIT_CODE%
