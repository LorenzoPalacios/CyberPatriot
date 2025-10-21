@echo off
setlocal enableextensions enabledelayedexpansion

set self_dir=%~dp0
set self_filename=%~n0
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_dispatch="%lib_dir%\dispatch.bat"
set lib_util="%lib_dir%\util.bat"

rem - Status Codes -
set /a SUCCESS          = 0
set /a USR_NOT_FOUND    = 1
set /a ARG_NOT_SUPPLIED = 2

rem Parameters:
rem %1 - Username
rem %2 - Boolean value (0 or 1) specifying whether to erase the user's data
rem      or simply remove their account. Default is 0.
:remove_usr (
  set usr=%1
  set should_erase=0%2
  if not defined usr ( exit /b %ARG_NOT_SUPPLIED% )
  call %lib_dispatch% func_dispatch no_output net user %usr%
  if not !ERRORLEVEL! EQU 0 ( exit /b %USR_NOT_FOUND% )
  net user /delete %usr%
  if %should_erase% EQU 1 (
    rem TODO: get the user's SID to delete their registry keys
    rd "%SYSTEMDRIVE%\Users\%usr%" /s /q
  )
  exit /b %SUCCESS%
)

:remove_elevated_usr_priv (

)
