setlocal

set self_dir=%~dp0
set lib_dir=%self_dir:~0,-1%

rem - Dependencies -
set lib_util="%lib_dir%\util.bat"

rem - Constants -
set SC_BLACKLIST=RemoteRegistry TlntSvr TermService Spooler FTPSVC IISADMIN^
                 bthserv Fax mnmsrvc WerSvc cbdhsvc DiagTrack WinRM LanmanServer^
                 ftpsvc msftpsvc SharedAccess lmhosts upnphost WbioSrvc
set WIN_UPD_REG_PATH="HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
set AUTO_UPD_REG_PATH="%WIN_UPD_REG_PATH:~1,-1%\AU"
:dispatch (
  call :%*
  exit /b !ERRORLEVEL!
)

:fix_corrupt_files (
  dism /online /cleanup-image /restorehealth
  rem Perform the scan in the background.
  start sfc /scannow
  exit /b %ERRORLEVEL%
)

:memory_hardening (
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /d 1
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ExecuteOptions /d 1
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /d 1
)

:sync_time (
  SystemSettingsAdminFlows ForceTimeSync 1
  exit /b %ERRORLEVEL%
)

:network_and_sharing (
  rem For private networks
  SystemSettingsAdminFlows EnableNetworkDiscovery 2 0
  SystemSettingsAdminFlows EnableNetworkFileSharing 2 0
  rem For public networks
  SystemSettingsAdminFlows EnableNetworkDiscovery 4 0
  SystemSettingsAdminFlows EnableNetworkFileSharing 4 0

  SystemSettingsAdminFlows EnablePublicFolderSharing 0
  SystemSettingsAdminFlows SetFileSharingMinEncryption 0
  SystemSettingsAdminFlows EnablePasswordProtection 1
)

:config_updates (
  reg add %AUTO_UPD_REG_PATH% /v NoAutoUpdate /d 0 /f
  reg add %AUTO_UPD_REG_PATH% /v AUOptions /d 3 /f
  reg add %WIN_UPD_REG_PATH% /v SetAllowOptionalContent /d 0 /f
  exit /b %ERRORLEVEL%
)

:config_auditpol (
  auditpol /set /category:* /success:enable /failure:enable
)

rem Parameters:
rem %1 - Boolean flag determining whether or not a prompt should be shown per
rem      service. Default is no prompt (0).
:disable_blacklisted_services (
  set prompt=0%1
  for %%i in ( %SC_BLACKLIST% ) do (
    sc query %%i > nul
    if !ERRORLEVEL! EQU 0 (
      if not %prompt% EQU 0 ( choice /m "Disable service %%i" )
      if !ERRORLEVEL! LEQ 1 (
        sc config %%i start=disabled > nul
        sc stop %%i > nul
      )
    ) else (
      echo Service %%i not present.
    )
  )
  exit /b %ERRORLEVEL%
)

rem Parameters:
rem %1 - The service to be disabled.
:sc_disable (
  sc config %1 start=disabled 1> nul 2>&1
  sc stop %1 1> nul 2>&1
  exit /b %ERRORLEVEL%
)
