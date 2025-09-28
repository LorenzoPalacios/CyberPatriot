@echo off
setlocal
setlocal enabledelayedexpansion
setlocal enableextensions

rem set /a ignores whitespace around the variable name and assignment.

set /a SUCCESS          = 0
set /a CMD_EXT_DISABLED = 1
set /a REG_BAD_KEY      = 2
set /a REG_KEY_DNE      = 3
set /a FILE_BAD_NAME    = 4
set /a FILE_DNE         = 5
set /a FUNC_DNE         = 6
set /a VALUE_DNE        = 7
set /a ERR_BAD_INVOKE   = 8
set /a LIB_DNE          = 9

:dispatch (
  set request=%1
  if defined request (
    rem Check if the requested symbol is a variable local to this file and
    rem return its value.
    if defined %request% exit /b !!request!!
    rem Otherwise, assume it is a function.
    goto :%*
    exit /b %ERR_BAD_INVOKE%
  )
  call :exception_msg %~nx0 driver "Attempt to invoke non-existent object."
  exit /b %ERR_BAD_INVOKE%
)


rem Parameters:
rem %1 = Filename
rem %2 = Function Name
rem %3 = Exception Message (optional)
:exception_msg (
  set msg=%3
  echo (Exception) Function %2 in file "%1"
  if defined msg echo %3
  exit /b
)
