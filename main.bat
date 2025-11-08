@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%\lib

rem - Dependencies -
set lib_backup="%lib_dir%\backup.bat"
set lib_patches="%lib_dir%\patches.bat"
set lib_user="%lib_dir%\user.bat"
set lib_util="%lib_dir%\util.bat"
set lib_menu="%lib_dir%\menu.bat"

:init (
  call %lib_util% cmd_extensions_available
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  call :check_elevation
  if not !ERRORLEVEL! EQU 0 (
    powershell -Command "& { Start-Process \"%~f0\" -verb runas }"
    exit /b
  )
)

:main (
  call %lib_menu% main_menu
  exit /b !ERRORLEVEL!
)

:check_elevation (
  bcdedit > nul
  exit /b %ERRORLEVEL%
)
