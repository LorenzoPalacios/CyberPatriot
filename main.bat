@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

rem - Dependencies -
set lib_dispatch=".\lib\dispatch.bat"
set lib_regmanip=".\lib\regmanip.bat"
set lib_user=".\lib\user.bat"
set lib_util=".\lib\util.bat"

rem - Driver Code -

goto :init

:user_mgmt_prompt (
  set options=^
    Delete User,^
    Save Registry State,
  
  set options=%options:  =%
  echo %options%
  exit /b
  for /l "tokens=1 delims=," %%i in ("!options!") do (

  )
)

:main (
  call :user_mgmt_prompt
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
  if not exist %lib_regmanip% echo init: Library %lib_regmanip% not found.
  if not exist %lib_util%     echo init: Library %lib_regmanip% not found.
)
