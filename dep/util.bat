@echo off
setlocal

rem - Dependencies -
set lib_err=".\error.bat"

:dispatcher (
  set tgt_lib=%1
  set tgt_symbol=%2
  if defined tgt_lib (
    if defined tgt_symbol (
      call %*
      exit /b %ERRORLEVEL%
    )
    call %lib_err% LIB_DNE
    exit %ERRORLEVEL%
  )
  call %lib_err% ERR_BAD_INVOKE
  exit /b %ERRORLEVEL%
)

:driver (
  set request=%1
  if defined request call :%request%
  call %lib_err% FUNC_DNE
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

:enable_cmd_extensions (
  verify other 2 > nul
  setlocal enableextensions
  IF %ERRORLEVEL% EQU 1 (
    call %lib_err% CMD_EXT_DISABLED
    exit /b %ERRORLEVEL%
  )
  exit /b 0
)
