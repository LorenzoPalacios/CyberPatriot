@echo off
setlocal enabledelayedexpansion
setlocal enableextensions

rem Note:
rem When calling this batch file for a status code, you MUST use !ERRORLEVEL!
rem to access the returned status code.
rem Regular expansion (%ERRORLEVEL%) and if-expansion (if ERRORLEVEL n) will NOT
rem work.
rem
rem Dysfunctional Examples:
rem call error.bat SUCCESS
rem exit /b %ERRORLEVEL%
rem - The above snippet will return whatever preceded `call` and set ERRORLEVEL.
rem
rem call error.bat FUNC_DNE
rem if not ERRORLEVEL 0 ( echo Function does not exist. )
rem - The above snippet is not guaranteed to emit any message.
rem - This is because ERRORLEVEL functions identically to `%ERRORLEVEL%`.
rem
rem Working Examples:
rem call error.bat SUCCESS
rem exit /b !ERRORLEVEL!
rem - The expansion of ERRORLEVEL is delayed until after the run-time retrieval
rem - of `SUCCESS`.
rem
rem call error.bat CMD_EXT_DISABLED
rem if not !ERRORLEVEL! EQU 0 ( echo Extensions are disabled. )
rem - Again, the expansion of ERRORLEVEL is delayed until after retrieval, so
rem - the message will be emitted.

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
set /a NO_IDENT         = 10

:dispatch (
  set request=%1
  if defined request (
    rem Check if the requested symbol is a variable local to this file and
    rem return its value.
    if defined %request% ( exit /b !%request%! )
    rem Otherwise, assume it is a function.
    goto :%*
    exit /b %ERR_BAD_INVOKE%
  )
  call :exception %~nx0 driver "Attempt to invoke non-existent object." ERR_BAD_INVOKE
  exit /b !ERRORLEVEL!
)


rem Parameters:
rem %1 = Filename
rem %2 = Function Name
rem %3 = Exception Message (optional)
rem %4 = Returned status code (optional, default is 0)
:exception (
  set msg=%3
  echo ^
  echo (Exception) Function %2 in file "%1"
  if defined msg echo %3
  exit /b 0%4
)
