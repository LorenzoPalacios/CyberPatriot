@echo off
setlocal enableextensions

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_err="%lib_dir%\error.bat"
set lib_util="%lib_dir%\util.bat"

:dispatch (
  set request=%1
  if defined request (
    call :%*
    exit /b !ERRORLEVEL!
  )
  call %lib_err% FUNC_DNE
  exit /b !ERRORLEVEL!
)

:reg_export (
  set tgt_key=%1
  set export_dir=%2
  set export_filename=%3
  if not defined tgt_key (
    set /p tgt_key="Key location (e.g. HKLM\Software\MyCo\MyApp): "
  )
  call %lib_util% check_registry_key !tgt_key!
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  call %lib_util% save_file_prepper export_dir export_filename
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  ( call %lib_util% suppress_output reg export "!tgt_key!" "!export_filename!" )
  exit /b !ERRORLEVEL!
)

:reg_import (
  set import_filename=%1
  if not defined import_filename (
    set /p import_filename="Save location (e.g. %UserProfile%\my_registry_key.reg): "
  )
  call %lib_util% check_filename !import_filename!
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  reg import !import_filename!
  call %lib_err% SUCCESS
  exit /b !ERRORLEVEL!
)
