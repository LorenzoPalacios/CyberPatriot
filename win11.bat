@echo off

setlocal

rem - Exit Codes -
set /a EXIT_SUCCESS=0

set /a CMD_EXT_DISABLED=1

set /a REG_BAD_KEY=2
set /a REG_KEY_DOES_NOT_EXIST=3

set /a FILE_BAD_NAME=4
set /a FILE_DOES_NOT_EXIST=5

rem - Driver Code -
goto :init

:main (
  call :reg_export
  exit /b %EXIT_SUCCESS%
)

:init (
  call :enable_cmd_extensions
  if %ERRORLEVEL% EQU %CMD_EXT_DISABLED% ( exit /b %CMD_EXT_DISABLED% )
  goto :main
)

rem - Setup Routines -

:enable_cmd_extensions (
  verify other 2 > nul
  setlocal enableextensions
  IF %ERRORLEVEL% EQU 1 exit /b %CMD_EXT_DISABLED%
  exit /b 0
)

rem - Registry Export/Import -

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
  exit /b %EXIT_SUCCESS%
)

:reg_import (
  set import_filename=%1
  if not defined import_filename (
    set /p import_filename="Save location (e.g. %UserProfile%\my_registry_key.reg): "
  )
  call :check_filename %import_filename%
  if not %ERRORLEVEL% EQU %EXIT_SUCCESS% ( exit /b %ERRORLEVEL% )
  reg import %import_filename%
  exit /b %EXIT_SUCCESS%
)

rem - Utility -

:check_filename (
  set filename=%1
  if not defined filename ( exit /b %FILE_BAD_NAME% )
  exit /b %EXIT_SUCCESS%
)

:check_registry_key (
  set key=%1
  if not defined key ( exit /b %REG_BAD_KEY% )
  reg query %key% > nul
  if %ERRORLEVEL% EQU 1 ( exit /b %REG_KEY_DOES_NOT_EXIST% )
  exit /b %EXIT_SUCCESS%
)
