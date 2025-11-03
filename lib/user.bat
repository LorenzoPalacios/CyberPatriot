@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

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
rem %1 - Username (will prompt if not supplied)
rem %2 - Boolean value (0 or 1) specifying whether to erase the user's data
rem      or simply remove their account (will prompt if not supplied).
:delete_user (
  set username=%1
  set should_erase=%2
  if not defined usr ( set /p username=Enter a username: )
  call :chk_username %username%
  if not !ERRORLEVEL! EQU 0 ( exit /b %USR_NOT_FOUND% )
  net user /delete %usr%

  if not defined should_erase (
    choice /m "Erase user data for %username%?"
    if %ERRORLEVEL% EQU 1
  )
  if not %should_erase% EQU 0 (
    rem TODO: get the user's SID to delete their registry keys
    rd "%SYSTEMDRIVE%\Users\%usr%" /s /q
  )
  exit /b %SUCCESS%
)

:remove_user_from_group (

)

rem Parameters:
rem %1 - The username to be checked.
rem Returns 0 if the username corresponds to an account, 1 otherwise.
:chk_username (
  call %lib_dispatch% %lib_util% no_output net user "%~1"
  if !ERRORLEVEL! EQU 0 ( exit /b 0 )
  exit /b 1
)
