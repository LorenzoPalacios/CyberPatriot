@echo off
setlocal

rem - Dependencies -
set liberr=".\dep\error.bat"
set libregmanip=".\dep\regmanip.bat"

rem - Driver Code -
goto :init

:main (
  call %libregmanip% reg_export
  call %liberr% EXIT_SUCCESS & exit /b %ERRORLEVEL%
)

rem - Setup Routines -

:init (
  call :enable_cmd_extensions
  if not %ERRORLEVEL% EQU 0 exit /b %ERRORLEVEL%
  call :check_libraries
  goto :main
)

:check_libraries (
  if not exist %liberr% echo init: Library %liberr% not found.
  if not exist %libregmanip% echo init: Library %libregmanip% not found.
)

:enable_cmd_extensions (
  verify other 2 > nul
  setlocal enableextensions
  IF %ERRORLEVEL% EQU 1 call %liberr% CMD_EXT_DISABLED & exit /b %ERRORLEVEL%
  exit /b 0
)
