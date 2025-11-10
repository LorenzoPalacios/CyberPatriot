rem - Status Codes -
set /a CMD_EXT_DISABLED = 1
set /a NO_STORAGE_VAR   = 2
set /a FILE_EXISTS      = 3
set /a FILE_DNE         = 4
set /a FILE_BAD_NAME    = 5

:dispatch (
  call :%*
  exit /b !ERRORLEVEL!
)

rem Parameters:
rem %1 - Filename to be checked for validity.
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
  set %1=%requested_dir%
  exit /b
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

  set /p sv_name_="Save name (e.g. savefile.sav): "
  call :check_file %sv_name_%
  if !ERRORLEVEL! EQU %FILE_BAD_NAME% ( exit /b !ERRORLEVEL! )
  (set %1=%sv_dir_%) & (set %2=%sv_name_%)
  exit /b
)

rem Parameters:
rem %1 - Storage variable identifier
rem %2, %3, %4 ... - Arguments
:cnt_args (
  rem cnt is set to -1 to account for %1.
  set storage=%1
  set cnt=-1
  for %%i in ( %* ) do set /a cnt="cnt + 1"
  set %1=%cnt%
  exit /b
)

rem Parameters:
rem %1 - Storage variable identifier
rem %2 - String
:strlen (
  set str=%~2
  set cnt=0
  :str_len_loop (
    if "%str%"=="" ( goto :str_len_loop_end )
    set str=%str:~0,-1%
    set /a cnt="cnt + 1"
    goto :str_len_loop
  )
  :str_len_loop_end
  set %1=%cnt%
  exit /b
)

rem Parameters:
rem %1 - Storage variable identifier
rem %2, %3, %4 ... - Strings
:highest_strlen (
  set strings=%*
  call :strlen svi_len %1
  set strings=!strings:~%svi_len%!
  set hi_len=0
  for %%i in ( %strings% ) do (
    call :strlen cur_len %%i
    if !cur_len! GTR !hi_len! set hi_len=!cur_len!
  )
  set %1=!hi_len!
  exit /b
)

rem Parameters:
rem %1 - Number to be checked.
rem %2 - Lower bound.
rem %3 - Upper bound.
rem %4 - Boolean flag determining whether or not the bounds are exclusive.
rem      Default is false (that is, bounds are exclusive).
:num_is_in_range (
  set exclusive=0%4
  if not %exclusive% EQU 0 (
    if %1 GTR %2 (
      if %1 LSS %3 exit /b 1
    )
  ) else (
    if %1 GEQ %2 (
      if %1 LEQ %3 exit /b 1
    )
  )
  exit /b 0
)
