@echo off
setlocal enableextensions

:dispatch_internal (
  endlocal
  call :%*
  exit /b !ERRORLEVEL!
)

rem Parameters:
rem %1 is the target filename.
rem %2 is the target function.
rem %3, %4, %5 ... are the arguments to the target function (if applicable).
rem Returns:
rem The called function's returned value on success, -7 on dispatch failure.
:func_dispatch (
  set filename="%~f1"
  call :chk_filename %filename%
  if !ERRORLEVEL! EQU 0 (
    call :func_exists %filename% %2
    if !ERRORLEVEL! EQU 0 (
      set args=%*
      set args=%args:%1=%
      rem The following endlocal allows the called function to access the
      rem caller's variable space. This is useful for functions that need to
      rem return multiple (or non-numerical) values to the caller.
      endlocal
      call %filename% %args%
      exit /b !ERRORLEVEL!
    )
  )
  exit /b -7
)

rem Parameters:
rem %1 - Filename.
rem %2 - Target variable.
rem %3 - Storage variable.
rem Returns:
rem 0 on success, -7 on dispatch failure.
:var_dispatch (
  set filename="%~f1"
  call :chk_filename %filename%
  if !ERRORLEVEL! EQU 0 (
    call :var_exists %filename% %2
    if !ERRORLEVEL! EQU 0 (
      endlocal
      call :get_var_value "%~f1" %2 %3
      exit /b !ERRORLEVEL!
    )
  )
  exit /b -7
)

rem Parameters:
rem %1 - Filename
rem %2 - Function name
rem Returns 0 if the function exists, 1 otherwise.
:func_exists (
  findstr /r /i /c:"^ *:%2 * ( *$" "%~f1" > nul
  exit /b %ERRORLEVEL%
)

rem Parameters:
rem %1 - Filename
rem %2 - Variable name
rem Returns 0 if the global variable exists in the file, 1 otherwise.
rem
rem Note:
rem This function can have false positives.
rem Consider the scenario where the target file contains the following line:
rem
rem set f = 3
rem
rem This declares a variable with identifier "f " (f with a trailing space)
rem whose value is " 3" (3 with a leading space).
rem The function will consider this a match for a variable named "f", when in
rem actuality no such variable exists.
:var_exists (
  findstr /r /i /c:"^set */*a* * %2 *= *..*" "%~f1" > nul
  exit /b %ERRORLEVEL%
)

:chk_filename (
  set filename="%~f1"
  if defined filename (
    if exist %filename% ( exit /b 0 )
  )
  exit /b 1
)

rem Parameters:
rem %1 - Filename.
rem %2 - Variable name.
rem %3 - Storage variable.
:get_var_value (
  rem Find the line associated with setting the target variable.
  for /f "delims=" %%i in ('findstr /r /i /c:"^set */*a* * %2 *= *..*" "%~f1"') do (
    set _var=%%i
  )
  for /f "delims== tokens=1*" %%i in ( "!_var!" ) do ( set _var=%%j )
  echo gvv: !_var!
  endlocal & set %3=!_var!
  exit /b 0
)
