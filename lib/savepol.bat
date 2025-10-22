@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%

rem - Status Codes -
set /a SUCCESS     = 0
set /a REG_BAD_KEY = 2
set /a REG_KEY_DNE = 3

rem - Security Area Flags -
set /a SECURITY_POLICY = "1 << 0"
set /a GROUP_MGMT      = "1 << 1"
set /a USER_RIGHTS     = "1 << 2"
set /a REGKEYS         = "1 << 3"
set /a FILESTORE       = "1 << 4"
set /a SERVICES        = "1 << 5"

rem - secedit constants -
set SECURITY_DIR="%windir%\security"
set DEF_SDB="%SECURITY_DIR%\database\secedit.sdb"

rem - Dependencies -
set lib_util="%lib_dir%\util.bat"

:dispatch (
  endlocal
  call :%*
  exit /b !ERRORLEVEL!
)

rem - Registry IO -

rem Parameters:
rem %1 - Target key (will prompt if not given)
rem %2 - Export directory (will prompt if not given)
rem %3 - Export filename (will prompt if not given)
:reg_export (
  set key=%1
  set sv_dir=%2
  set sv_filename=%3
  if not defined key (
    set /p key="Key location (e.g. HKLM\Software\MyCo\MyApp): "
  )
  call :check_registry_key %key%
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  call %lib_dispatch% func_dispatch %lib_util% save_file_prompt sv_dir sv_filename
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  reg export "%key%" "!sv_dir!\%sv_filename%" 2> nul
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
  exit /b %SUCCESS%
)

rem - Registry Status -

:check_registry_key (
  set key=%1
  if not defined key ( exit /b %REG_BAD_KEY% )
  call %lib_dispatch% func_dispatch %lib_util% no_output reg query %key%
  if not !ERRORLEVEL! EQU 0 ( exit /b %REG_KEY_DNE% )
  exit /b %SUCCESS%
)

rem - Secedit -

rem Parameters:
rem %1 - Target database (will assume secedit.sdb if not given)
rem %2 - Export directory (will prompt if not given)
rem %3 - Export filename (will prompt if not given)
rem %4 - Security areas to export (defaults to all if not given)
:secpol_export (
  set db=%1
  set exp_dir=%2
  set exp_filename=%3
  set sec_areas=%4
  if not defined db ( set db="%DEF_SDB%" )
  call %lib_dispatch% func_dispatch %lib_util% save_file_prompt exp_dir exp_filename
  


  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  call %lib_dispatch% func_dispatch %lib_util% save_file_prompt sv_dir sv_filename
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  reg export "%key%" "!sv_dir!\%sv_filename%" 2> nul
  exit /b !ERRORLEVEL!
)
