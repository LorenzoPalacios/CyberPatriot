@echo off
endlocal
setlocal enableextensions
setlocal enabledelayedexpansion

set self_dir=%~dp0
set self_filename=%~n0
set lib_dir=%self_dir:~0,-1%

rem - Status Codes -
set /a SUCCESS          = 0
set /a CMD_EXT_DISABLED = 1
set /a NO_STORAGE_VAR   = 2
set /a FILE_EXISTS      = 3
set /a FILE_DNE         = 4
set /a FILE_BAD_NAME    = 5

:dispatch (
  call :%*
  exit /b !ERRORLEVEL!
)

:check_file (
  set filename="%~f1"
  if not defined filename ( exit /b %FILE_BAD_NAME% )
  if not exist %filename% ( exit /b %FILE_DNE% )
  exit /b %FILE_EXISTS%
)

:cmd_extensions_available (
  verify other 2> nul
  setlocal enableextensions
  IF ERRORLEVEL 1 ( exit /b !CMD_EXT_DISABLED! )
  exit /b %SUCCESS%
)

rem This routine suppresses all output of a command and returns its ERRORLEVEL
rem upon completion.
rem Parameters:
rem %* - The command to be run (%1), followed by its arguments, if any.
rem
rem Note:
rem Using this function in a loop that runs many times is inefficient.
rem In such cases, it's better to inline the redirection than call this
rem function.
:no_output (
  ( %* ) 1> nul 2>&1
  exit /b !ERRORLEVEL!
)

rem Parameters:
rem %1 - The variable to which the directory will be stored.
:directory_prompt (
  set dir_storage_var=%1
  set requested_dir=%dir_storage_var%
  if not defined dir_storage_var ( exit /b %NO_STORAGE_VAR% )
  if not defined %requested_dir% (
    set /p requested_dir="Enter a directory (e.g. %UserProfile%): "
  )
  call :check_file %requested_dir%
  if !ERRORLEVEL! EQU %FILE_BAD_NAME% ( exit /b !ERRORLEVEL! )
  if !requested_dir:~-1!=="\" ( set requested_dir=!requested_dir:~0,-1! )
  endlocal & set %1=%requested_dir%
  exit /b %SUCCESS%
)

rem Parameters:
rem %1 - Directory variable identifier
rem %2 - Filename variable identifier
:save_prompt (
  set sv_dir_=%1
  set sv_name_=%2
  if not defined sv_dir_ ( exit /b %NO_IDENT% )
  if not defined sv_name_ ( exit /b %NO_IDENT% )
  set sv_dir_=
  set sv_name_=

  call :directory_prompt sv_dir_
  call :check_file %sv_dir_%
  if !ERRORLEVEL! EQU %FILE_BAD_NAME% ( exit /b !ERRORLEVEL! )

  if not defined sv_name_ (
    set /p sv_name_="Save name (e.g. savefile.sav): "
  )
  call :check_file %sv_name_%
  if !ERRORLEVEL! EQU %FILE_BAD_NAME% ( exit /b !ERRORLEVEL! )
  endlocal & (set %1=%sv_dir_%) & (set %2=%sv_name_%)
  exit /b %SUCCESS%
)
