@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

rem - Dependencies -
set lib_err=".\lib\error.bat"
set lib_regmanip=".\lib\regmanip.bat"
set lib_util=".\lib\util.bat"

rem - Driver Code -
goto :init

:main (
  call %lib_regmanip% reg_export
  echo Status: !ERRORLEVEL!
  call %lib_err% SUCCESS
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
  if not exist %lib_err% echo init: Library %lib_err% not found.
  if not exist %lib_regmanip% echo init: Library %lib_regmanip% not found.
)
