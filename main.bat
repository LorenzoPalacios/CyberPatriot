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

:init (
  call %lib_util% cmd_extensions_available
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  call :check_libraries
  rem We don't exit upon an error from `check_libraries` since other parts of
  rem the script could still be operational.
  call :check_elevation
  if not !ERRORLEVEL! EQU 0 (
    powershell -Command "& { Start-Process \"cmd.exe\" -ArgumentList \"/c %~f0\" -verb runas }"
    exit /b
  )
)

:main (
  call %lib_backup% reg_save
  exit /b !ERRORLEVEL!
)

:check_libraries (
  if not exist %lib_backup%   echo init: Library %lib_backup% not found.
  if not exist %lib_patches%  echo init: Library %lib_patches% not found.
  if not exist %lib_user%     echo init: Library %lib_user% not found.
  if not exist %lib_util%     echo init: Library %lib_util% not found.
  exit /b 0
)

:check_elevation (
  bcdedit > nul
  exit /b %ERRORLEVEL%
)
