function Disable-Services {
    $serviceNames = [String[]](
        'RemoteRegistry', 'RemoteAccess', 'TlntSvr', 'ScDeviceEnum',
        'SCPolicySvc', 'TermService', 'Spooler', 'FTPSVC', 'IISADMIN',
        'shpamsvc', 'SensorService', 'bthserv', 'fax', 'mnmsrvc', 'WerSvc',
        'cbdhsvc', 'seclogon', 'RetailDemo', 'DiagTrack', 'WinRM', 'msftpsvc',
        'PlugPlay', 'MSiSCSI', 'SharedAccess', 'upnphost', 'WbioSrvc', 'dcsvc',
        'CDPSvc', 'ALG', 'WebClient', 'Themes', 'ssdpsrv', 'SCardSvr',
        'NetTcpPortSharing', 'WMPNetworkSvc')
    
    $riskyServiceNames = [String[]](
        'FDResPub', 'TrkWks', 'LanmanServer', 'LanmanWorkstation'
    )
    foreach ($name in $serviceNames) {
        $srv = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($srv -ne $null) {
            Set-Service $name -StartupType Disabled
            Stop-Service $name -Force -NoWait
        }
    }
}

function Enable-Services {
    $serviceNames = [string[]](
        'BFE', 'EventSystem', 'COMSysApp', 'CoreMessagingRegistrar', 'VaultSvc',
        'CryptSvc', 'DcomLaunch', 'gpsvc', 'MDCoreSvc', 'WinDefend', 'WdNisSvc',
        'webthreatdefsvc', 'mpssvc', 'EventLog', 'Winmgmt',
        'SecurityHealthService', 'wuauserv'
    )
    foreach ($name in $serviceNames) {
        $srv = Get-Service $name -ErrorAction SilentlyContinue
        if ($srv -ne $null) {
            Set-Service $name -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service $name -ErrorAction SilentlyContinue
        }
    }
}

function Restore-Windows {
    Repair-WindowsImage -Online -RestoreHealth
    Start-Job -ScriptBlock {
        sfc.exe /scannow
    }
}

function Harden-Sharing {
    # For private networks
    SystemSettingsAdminFlows.exe EnableNetworkDiscovery 2 0
    SystemSettingsAdminFlows.exe EnableNetworkFileSharing 2 0
    # For public networks
    SystemSettingsAdminFlows.exe EnableNetworkDiscovery 4 0
    SystemSettingsAdminFlows.exe EnableNetworkFileSharing 4 0

    SystemSettingsAdminFlows.exe EnablePublicFolderSharing 0
    SystemSettingsAdminFlows.exe SetFileSharingMinEncryption 0
    SystemSettingsAdminFlows.exe EnablePasswordProtection 1
}

