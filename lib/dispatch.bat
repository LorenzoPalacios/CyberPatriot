@echo off
setlocal enableextensions

rem %1 is the target filename.
rem %2 is the target function.
rem %3, %4, %5... are the arguments to the target function (if applicable).
rem Returns:
rem * -7 on dispatch failure.
rem * The called function's returned value.
:func_dispatch (
  set filename="%~f1"
  if defined filename (
    if exist %filename% (
      call :func_exists %filename% %2
      if !ERRORLEVEL! EQU 0 (
        rem The following endlocal allows the called function to access the
        rem caller's variable space. This is useful for functions that need to
        rem return multiple (or non-numerical) values to the caller.
        endlocal
        call %*
        exit /b !ERRORLEVEL!
      )
    )
  )
  exit /b -7
)

:var_dispatch (

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
rem %2 - Global variable name
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
:global_var_exists (
  findstr /r /i /c:"^set */*a* * %1 *= *..*" "%~f0" > nul
  exit /b %ERRORLEVEL%
)

:is_valid_filename (
  if not "%~f1"=="" (
    if exist "%~f1" ( exit /b 0 )
  )
  exit /b 1
)
