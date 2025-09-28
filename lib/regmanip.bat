@echo off
setlocal
setlocal enableextensions

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_err="%lib_dir%\error.bat"
set lib_util="%lib_dir%\util.bat"

:driver (
  set request=%1
  if defined request call :%request%
  call %lib_err% FUNC_DNE
  exit /b %ERRORLEVEL%
)

:reg_export (
  (
    set tgt_key=%1
    if not defined tgt_key (
      set /p tgt_key="Key location (e.g. HKLM\Software\MyCo\MyApp): "
    )
    call %lib_util% check_registry_key %tgt_key%
    if not %ERRORLEVEL% EQU 0 ( exit /b %ERRORLEVEL% )
  )
  (
    set export_dir=%2
    if not defined export_dir (
      set /p export_dir="Save directory (e.g. %UserProfile%): "
    )
    call :check_filename %export_dir%
    if not %ERRORLEVEL% EQU %SUCCESS% ( exit /b %ERRORLEVEL% )
    pushd %export_dir%
  )
  (
    set export_filename=%3
    if not defined export_filename (
      set /p export_filename="Save name (e.g. my_registry_key): "
    )
    call :check_filename %export_filename%
    if not %ERRORLEVEL% EQU %SUCCESS% ( exit /b %ERRORLEVEL% )
    set export_filename=%export_filename%.reg
  )
  reg export "%tgt_key%" "%export_filename%"
  popd
  call %lib_err% SUCCESS | exit /b
)

:reg_import (
  set import_filename=%1
  if not defined import_filename (
    set /p import_filename="Save location (e.g. %UserProfile%\my_registry_key.reg): "
  )
  call :check_filename %import_filename%
  if not %ERRORLEVEL% EQU %SUCCESS% ( exit /b %ERRORLEVEL% )
  reg import %import_filename%
  call %lib_err% SUCCESS | exit /b
)

rem - Utility -
