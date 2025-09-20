@echo off
setlocal
setlocal enabledelayedexpansion

rem set /a ignores whitespace around the variable name.

set /a SUCCESS          = 0

set /a CMD_EXT_DISABLED = 1

set /a REG_BAD_KEY      = 2
set /a REG_KEY_INVALID  = 3

set /a FILE_BAD_NAME    = 4
set /a FILE_INVALID     = 5

set /a FUNC_INVALID     = 6

:driver (
  call :%1 > nul
  if not %ERRORLEVEL% EQU 0 exit /b !%1!
)

rem Parameters:
rem Filename, function name, (optional) exception message
:exception_msg (
  set msg=%3
  echo (Exception) Function %2 in file "%1"
  if defined msg echo %3
  exit /b
)
