@echo off
setlocal enableextensions

set self_dir=%~dp0
set self_filename=%~n0
set lib_dir=%self_dir:~0,-1%

rem - Status Codes -
set /a SUCCESS          = 0
set /a CMD_EXT_DISABLED = 1
set /a BAD_FILENAME     = 2
set /a NO_STORAGE_VAR   = 3

:dispatch (
  endlocal
  call :%*
  exit /b !ERRORLEVEL!
)

:is_valid_filename (
  set filename="%~f1"
  if not defined filename ( exit /b %BAD_FILENAME% )
  exit /b %SUCCESS%
)

:file_exists (
  set filename="%~f1"
  if exist %filename% ( exit /b %SUCCESS% )
  exit /b 1
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
:no_output (
  ( %* ) 1> nul 2>&1
  exit /b !ERRORLEVEL!
)

rem Parameters:
rem %1 - The variable to which the directory will be stored.
:directory_prompt (
  set requested_dir=%1
  if not defined requested_dir ( exit /b %NO_STORAGE_VAR% )
  set /p requested_dir="Enter a directory (e.g. %UserProfile%): "
  call :is_valid_filename !requested_dir!
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  if !requested_dir:~-1!=="\" ( set requested_dir=!requested_dir:~0,-1! )
  endlocal & set %1=%requested_dir%
  exit /b %SUCCESS%
)

rem Parameters:
rem %1 - Directory variable identifier
rem %2 - Filename variable identifier
:save_file_prompt (
  set sv_dir_=%1
  set sv_name_=%2
  if not defined sv_dir_ ( exit /b %NO_IDENT% )
  if not defined sv_name_ ( exit /b %NO_IDENT% )

  call :directory_prompt sv_dir_
  call :is_valid_filename %sv_dir_%
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )

  if not defined %sv_name_% (
    set /p sv_name_="Save name (e.g. savefile.sav): "
  )
  call :is_valid_filename !sv_name_!
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  endlocal & (set %1=%sv_dir_%) & (set %2=%sv_name_%)
  exit /b %SUCCESS%
)
