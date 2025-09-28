@echo off
setlocal enableextensions

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
    exit /b !ERRORLEVEL!
  )
  call %lib_err% FUNC_DNE
  exit /b !ERRORLEVEL!
)

:check_filename (
  set filename=%1
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
  rem reg uses stderr for output, so we use `2>` to redirect stderr to nul.
  reg query %key% 2> nul
  if ERRORLEVEL 1 (
    call %lib_err% REG_KEY_DNE
    exit /b !ERRORLEVEL!
  )
  call %lib_err% SUCCESS
  exit /b !ERRORLEVEL!
)

:cmd_extensions_available (
  verify other 2 > nul
  setlocal enableextensions
  IF ERRORLEVEL 1 (
    call %lib_err% CMD_EXT_DISABLED
    exit /b !ERRORLEVEL!
  )
  call %lib_err% SUCCESS
  exit /b !ERRORLEVEL!
)
