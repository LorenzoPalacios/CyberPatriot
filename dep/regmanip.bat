@echo off
setlocal

rem - Dependencies -
set err=".\dep\error.bat"

call :%1
call %err% FUNC_INVALID & exit /b %ERRORLEVEL%

:reg_export (
  set tgt_key=%1
  if not defined tgt_key (
    set /p tgt_key="Key location (e.g. HKLM\Software\MyCo\MyApp): "
  )
  call :check_registry_key %tgt_key%
  if not %ERRORLEVEL% EQU %EXIT_SUCCESS% ( exit /b %ERRORLEVEL% )

  set export_dir=%2
  if not defined export_dir (
    set /p export_dir="Save directory (e.g. %UserProfile%): "
  )
  call :check_filename %export_dir%
  if not %ERRORLEVEL% EQU %EXIT_SUCCESS% ( exit /b %ERRORLEVEL% )
  pushd %export_dir%

  set export_filename=%3
  if not defined export_filename (
    set /p export_filename="Save name (e.g. my_registry_key): "
  )
  call :check_filename %export_filename%
  if not %ERRORLEVEL% EQU %EXIT_SUCCESS% ( exit /b %ERRORLEVEL% )
  set export_filename=%export_filename%.reg

  reg export "%tgt_key%" "%export_filename%"
  popd
  call %err% EXIT_SUCCESS | exit /b
)

:reg_import (
  set import_filename=%1
  if not defined import_filename (
    set /p import_filename="Save location (e.g. %UserProfile%\my_registry_key.reg): "
  )
  call :check_filename %import_filename%
  if not %ERRORLEVEL% EQU %EXIT_SUCCESS% ( exit /b %ERRORLEVEL% )
  reg import %import_filename%
  call %err% EXIT_SUCCESS | exit /b
)

rem - Utility -

:check_filename (
  set filename=%1
  if not defined filename ( exit /b %FILE_BAD_NAME% )
  call %err% EXIT_SUCCESS | exit /b
)

:check_registry_key (
  set key=%1
  if not defined key ( exit /b %REG_BAD_KEY% )
  reg query %key% > nul
  if %ERRORLEVEL% EQU 1 ( exit /b %REG_KEY_DOES_NOT_EXIST% )
  call %err% EXIT_SUCCESS | exit /b
)
