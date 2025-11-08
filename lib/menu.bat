@echo off

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_util="%lib_dir%\util.bat"
(
  set NEWLINE=^

)

:dispatch (
  call :%*
  exit /b !ERRORLEVEL!
)

rem - Main Menu -

:main_menu (
  set items="Backup Security Policy"^
            "Backup Audit Policy"^
            "Backup Services"^
            "Apply Common Patches"
  call %lib_util% highest_strlen le hello worlds
  exit /b
)

rem Parameters:
rem %1 - Columns to be used in display. Must be greater than 0.
rem %2, %3, %4 ... - Selection items.
:display_selection (
  set args=%*
  set cnt=0
  set rows=
  call %lib_util% cnt_args rows
  for %%i in ( %items% ) do (
    echo !cnt!. %%i
    set /a cnt="cnt + 1"
  )
)
