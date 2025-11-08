@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

rem - Dependencies -
set lib_backup=".\lib\backup.bat"
set lib_patches=".\lib\patches.bat"
set lib_user=".\lib\user.bat"
set lib_util=".\lib\util.bat"

rem - Driver Code -

goto :init

:main (
  call %lib_backup% backup_auditpol
  exit /b !ERRORLEVEL!
)

rem - Setup Routines -

:init (
  call %lib_util% cmd_extensions_available
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  call :check_libraries
  goto :main
)

:check_libraries (
  if not exist %lib_backup%   echo init: Library %lib_backup% not found.
  if not exist %lib_patches%  echo init: Library %lib_patches% not found.
  if not exist %lib_user%     echo init: Library %lib_user% not found.
  if not exist %lib_util%     echo init: Library %lib_util% not found.
)
