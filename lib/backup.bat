@echo off
endlocal
setlocal enableextensions
setlocal enabledelayedexpansion

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_dispatch="%lib_dir%\dispatch.bat"
set lib_util="%lib_dir%\util.bat"

rem - Status Codes -
set /a SUCCESS     = 0
set /a REG_BAD_KEY = 1
set /a REG_KEY_DNE = 2
set /a BAD_SDB     = 3

rem - Security Area Flags -
set /a SECURITY_POLICY = "1 << 0"
set /a GROUP_MGMT      = "1 << 1"
set /a USER_RIGHTS     = "1 << 2"
set /a REGKEYS         = "1 << 3"
set /a FILESTORE       = "1 << 4"
set /a SERVICES        = "1 << 5"
set /a ALL_SEC_AREAS   = "%SECURITY_POLICY% | %GROUP_MGMT% | %USER_RIGHTS% |"^
                         "%REGKEYS% | %FILESTORE% | %SERVICES%"

rem - Security Area Names -
set SEC_AREA_1="SECURITY_POLICY"
set SEC_AREA_2="GROUP_MGMT"
set SEC_AREA_4="USER_RIGHTS"
set SEC_AREA_8="REGKEYS"
set SEC_AREA_16="FILESTORE"
set SEC_AREA_32="SERVICES"

rem - secedit constants -
set SECURITY_DIR="%windir:"=%\security"
set DEF_SDB="%SECURITY_DIR:"=%\database\secedit.sdb"

rem - Service Constants -
set SERV_REG_REPO="hklm\system\currentcontrolset\services"

call :secpol_export
exit /b 0

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
  call %lib_dispatch% %lib_util% save_prompt sv_dir sv_filename
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  rem Redirect only stderr to allow success messages through.
  reg export "%key%" "!sv_dir!\%sv_filename%" 2> nul
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
  call %lib_dispatch% %lib_util% no_output reg query %key%
  if not !ERRORLEVEL! EQU 0 ( exit /b %REG_KEY_DNE% )
  exit /b %SUCCESS%
)

rem - Secedit -

rem Parameters:
rem %1 - Target database (will prompt if not given)
rem %2 - Export directory (will prompt if not given)
rem %3 - Export filename (will prompt if not given)
rem %4 - Security areas to export (defaults to all if not given)
:secpol_export (
  set sdb=%1
  set exp_dir=%2
  set exp_filename=%3
  set areas=%4
  set areas_str=
  if not defined sdb (
    set /p sdb="Enter the location of a security database (e.g. %DEF_SDB%): "
  )
  call %lib_dispatch% %lib_util% check_file %sdb%
  if not !ERRORLEVEL! EQU 3 ( exit /b %SECEDIT_BAD_SDB% )
  call %lib_dispatch% %lib_util% save_prompt exp_dir exp_filename
  if not !ERRORLEVEL! EQU 0 ( exit /b !ERRORLEVEL! )
  if not defined sec_areas (
    for /l %%i in (0,1,5) do (
      set /a flag="1 << %%i"
      set var1=SEC_AREA_!flag!
      set var2=!var1!
      set var3=!var2!
      echo var1 = !var1!
      echo var2 = !var2!
      echo var3 = !var3!
    )
    exit /b
  )
  secedit /export /db %sdb% /cfg "%exp_dir%\%exp_filename%" /areas %areas_str%
  exit /b !ERRORLEVEL!
)

rem - Services -

:backup_all_services (
  call :reg_export %SERV_REG_REPO%
  exit /b !ERRORLEVEL!
)
