@echo off

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_util="%lib_dir%\util.bat"

rem - Status Codes -
set /a SUCCESS     = 0
set /a REG_BAD_KEY = 1
set /a REG_KEY_DNE = 2
set /a BAD_SDB     = 3

rem - secedit constants -
set SECURITY_DIR="%windir:"=%\security"
set DEFAULT_SDB="%SECURITY_DIR:"=%\database\secedit.sdb"

rem - Service Constants -
set SERV_REG_REPO="hklm\system\currentcontrolset\services"

:dispatch (
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
  call %lib_util% save_prompt sv_dir sv_filename
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  rem Redirect only stderr to allow success messages through.
  reg export "%key%" "!sv_dir!\!sv_filename!"
  rem 2> nul
  echo !sv_dir!!sv_filename!
  exit /b !ERRORLEVEL!
)

rem Parameters:
rem %1 - Target key (will prompt if not given)
rem %2 - Export directory (will prompt if not given)
rem %3 - Export filename (will prompt if not given)
:reg_import (
  set import_path=%1
  if not defined import_path (
    set /p import_path="Save location (e.g. %UserProfile%\my_registry_key.reg): "
  )
  call %lib_util% check_file !import_path!
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  reg import !import_path!
  exit /b %SUCCESS%
)

rem - Registry Status -

:check_registry_key (
  set key=%1
  if not defined key ( exit /b %REG_BAD_KEY% )
  call %lib_util% no_output reg query %key%
  if not !ERRORLEVEL! EQU 0 ( exit /b %REG_KEY_DNE% )
  exit /b %SUCCESS%
)

rem - Secedit -

rem Parameters:
rem %1 - Target database (will assume system's current if not given)
rem %2 - Export directory (will prompt if not given)
rem %3 - Export filename (will prompt if not given)
rem %4 - Security areas to export (defaults to all if not given)
:secpol_export (
  set sdb=%1
  set exp_dir=%2
  set exp_filename=%3
  set areas=%4
  if defined areas (
    set areas_str=/areas %areas%
  )
  if defined sdb (
    call %lib_util% check_file %sdb%
    if not !ERRORLEVEL! EQU 3 ( exit /b %SECEDIT_BAD_SDB% )
  )
  call %lib_util% save_prompt exp_dir exp_filename
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )

  if not defined sdb (
    secedit /export /cfg "%exp_dir%\%exp_filename%" %areas_str%
  )
  secedit /export /db %sdb% /cfg "%exp_dir%\%exp_filename%" %areas_str%
  exit /b !ERRORLEVEL!
)

rem - Services -

:backup_all_services (
  call :reg_export %SERV_REG_REPO%
  exit /b !ERRORLEVEL!
)

rem - Audit Policy -

rem Parameters:
rem %1 - Directory to save into (will prompt if not supplied).
rem %2 - Filename of the save (will prompt if not supplied).
:backup_auditpol (
  set save_dir=%1
  set filename=%2
  call %lib_util% save_prompt save_dir filename
  echo "%save_dir%\%filename%"
  auditpol /backup /file:"%save_dir%\%filename%"
  exit /b %ERRORLEVEL%
)

rem Parameters:
rem %1 - Path to the backup (will prompt if not supplied).
:restore_auditpol (
  set /p backup_path=Audit policy backup location:
  if defined backup_path (
    call %lib_util% check_file %backup_path%
    if !ERRORLEVEL! EQU 0 ( auditpol /restore /file:"%backup_path%" )
  )
  exit /b %ERRORLEVEL%
)
