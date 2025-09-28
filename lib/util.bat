@echo off
setlocal
setlocal enableextensions

rem Get the directory this file is located in.
set self_dir=%~dp0
rem Remove the last backslash (\) from the self_dir.
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_err="%lib_dir%\error.bat"

:dispatcher (
  set tgt_lib=%~f1
  if defined tgt_lib (
    if exist %tgt_lib% (
      rem Call the target library for the target symbol.
      rem The first argument is the target library.
      rem The second argument is the target symbol.
      rem Any other arguments are assumed to be function parameters.
      rem The target symbol can be a function or variable.
      call :%*
      exit /b %ERRORLEVEL%
    )
    call %lib_err% LIB_DNE
    exit /b %ERRORLEVEL%
  )
  call %lib_err% ERR_BAD_INVOKE
  exit /b %ERRORLEVEL%
)

:check_filename (
  set filename=%1
  if not defined filename (
    call %lib_err% FILE_BAD_NAME
    exit /b %FILE_BAD_NAME%
  )
  call %lib_err% SUCCESS
  exit /b %ERRORLEVEL%
)

:check_registry_key (
  set key=%1
  if not defined key (
    call %lib_err% REG_BAD_KEY
    echo crk: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
  )
  reg query %key% > nul
  if %ERRORLEVEL% EQU 1 (
    call %lib_err% REG_KEY_DNE
    exit /b %ERRORLEVEL%
  )
  call %lib_err% SUCCESS
  exit /b %ERRORLEVEL%
)

:cmd_extensions_available (
  verify other 2 > nul
  setlocal enableextensions
  IF %ERRORLEVEL% EQU 1 (
    call %lib_err% CMD_EXT_DISABLED
    exit /b %ERRORLEVEL%
  )
  exit /b 0
)
