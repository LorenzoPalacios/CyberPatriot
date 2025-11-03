@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

rem - Dependencies -
set lib_dispatch=".\lib\dispatch.bat"
set lib_patches=".\lib\patches.bat"
set lib_savepol=".\lib\savepol.bat"
set lib_user=".\lib\user.bat"
set lib_util=".\lib\util.bat"

rem - Driver Code -

goto :init

:main (
  call %lib_dispatch% %lib_patches% disable_blacklisted_services
  exit /b !ERRORLEVEL!
)

rem - Setup Routines -

:init (
  call %lib_util% cmd_extensions_available
  if not %ERRORLEVEL% EQU 0 exit /b !ERRORLEVEL!
  call :check_libraries
  goto :main
)

:check_libraries (
  if not exist %lib_dispatch% echo init: Library %lib_dispatch% not found.
  if not exist %lib_savepol% echo init: Library %lib_savepol% not found.
  if not exist %lib_util%     echo init: Library %lib_savepol% not found.
)
