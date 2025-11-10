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
  setlocal
  set items="Apply Common Patches"^
            "Backup Security Policy"^
            "Backup Audit Policy"^
            "Backup Services"
  call %lib_util% cnt_args item_cnt %items%
  call :display_selection %items%
  call :selection_prompt
  exit /b
)

:mm_1 (
  echo 1
  exit /b
)

:mm_2 (
  echo 2
  exit /b
)

rem Parameters:
rem %* - Selection items.
:display_selection (
  set args=%*
  set cnt=1
  for %%i in ( %args% ) do (
    set output=!output!!NEWLINE!!cnt!. %%i
    set /a cnt+=1
  )
  echo !output!
  exit /b
)

rem Parameters:
rem %1 - Storage variable identifier
rem %2 - Selection upper bound
:selection_prompt (
  set /p selection="Enter your selection: "
  call %lib_util% num_is_in_range %1 %2
  if !ERRORLEVEL! EQU 1 (
    set %1=!selection!
  ) else (
    echo %0
  )
  exit /b
)
