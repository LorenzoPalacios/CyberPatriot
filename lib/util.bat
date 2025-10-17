@echo off
setlocal enableextensions

rem Gets the name of this batchfile (useful for exceptions).
set self_filename=%~n0
rem Gets the directory this file is located in.
set self_dir=%~dp0
rem Removes the last backslash (\) from the self_dir.
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_err="%lib_dir%\error.bat"

:dispatch (
  set request=%1
  if defined request (
    call :%*
    echo - dispatch -
    set e
    exit /b !ERRORLEVEL!
  )
  call %lib_err% FUNC_DNE
  exit /b !ERRORLEVEL!
)

:check_filename (
  set filename=%~f1
  if not defined filename (
    call %lib_err% FILE_BAD_NAME
    exit /b !ERRORLEVEL!
  )
  call %lib_err% SUCCESS
  exit /b !ERRORLEVEL!
)

:check_registry_key (
  set key=%1
  if not defined key (
    call %lib_err% REG_BAD_KEY
    exit /b !ERRORLEVEL!
  )
  call :suppress_output reg query %key%
  if !ERRORLEVEL! EQU 1 (
    call %lib_err% REG_KEY_DNE
    exit /b !ERRORLEVEL!
  )
  call %lib_err% SUCCESS
  exit /b !ERRORLEVEL!
)

:cmd_extensions_available (
  verify other 2> nul
  setlocal enableextensions
  IF ERRORLEVEL 1 (
    call %lib_err% CMD_EXT_DISABLED
    exit /b !ERRORLEVEL!
  )
  call %lib_err% SUCCESS
  exit /b !ERRORLEVEL!
)

rem This routine suppresses all output of a command and returns its ERRORLEVEL
rem upon completion.
rem Parameters:
rem %* = The command to be run (%1), followed by its arguments, if any.
:suppress_output (
  %* 1> nul 2>&1
  exit /b %ERRORLEVEL%
)

rem Parameters:
rem %1 = callee save directory variable name
rem %2 = callee save file variable name
rem
rem Example usage (from outside this batchfile):
rem set save_dir="%USERPROFILE%\saves"
rem set save_name="save.sav"
rem call %lib_util% save_file_prompt save_dir save_name
:save_file_prepper (
  set sv_dir_=%1
  set sv_name_=%2
  if not defined sv_dir_ (
    call %lib_err% exception_msg %self_filename% %0 "Identifier for save directory not specified." NO_VAR_NAME
  )
  if not defined sv_name_ (
    call %lib_err% exception_msg %self_filename% %0 "Identifier for save name not specified." NO_VAR_NAME
  )

  if not defined %sv_dir_% (
    set /p sv_dir_="Save directory (e.g. %UserProfile%): "
  )
  call :check_filename !sv_dir_!
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )

  if not defined %sv_name_% (
    set /p sv_name_="Save name (e.g. savefile.sav): "
  )
  call :check_filename !sv_name_!
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  rem The parentheses surrounding the below line defer variable expansion until
  rem execution reaches this point. This is necessary so that sv_dir_ and
  rem sv_name_ can be replaced during parsing, but before the execution of endlocal,
  rem allowing us to enter the caller's variable space to modify the specified
  rem variables.
  rem
  rem %1 and %2 will still correspond to the save directory and save name
  rem identifiers after endlocal.
  ( endlocal & set %1=%sv_dir_% & set %2=%sv_name_% )
  exit /b
)
