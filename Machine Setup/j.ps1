function Get-NextDriveLetter {
    [char[]]$letters = [char]'C'..[char]'Z'
    [char[]]$inUse = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Name
    return ($letters | Where-Object { $inUse -notcontains $_ })[0]
}

function Get-SystemDisk {
    (Get-Disk | Where-Object { $_.IsSystem -and $_.IsBoot })[0]
}

function Test-DiskRaw {
    param (
        [parameter(Mandatory)]
        $Disk
    )
    return ($Disk.PartitionStyle -eq 0) -or ($Disk.PartitionStyle -eq 'RAW')
}

function Set-CommonCredentials {
    cmdkey.exe /add:'europa' /user:'tech' /pass:'13onfire'
    cmdkey.exe /add:'venus' /user:'tech' /pass:'13onfire'
}

function Set-GenericConfiguration {
    powercfg.exe /h off
    reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' /v SetAllowOptionalContent /d 0 /f
    reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' /v NoAutoUpdate /d 0 /f
    reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' /v AUOptions /d 3 /f
}

function Initialize-Disks {
    param (
        [string]$PartitionStyle = (Get-SystemDisk).PartitionStyle
    )
    $disks = Get-Disk
    foreach ($d in $disks) {
        if (Test-DiskRaw -Disk $d) {
            $d | Initialize-Disk -PartitionStyle $PartitionStyle
        }
        if ($d.LargestFreeExtent -ne 0) {
            $d | New-Partition -AsJob -DriveLetter (Get-NextDriveLetter) -UseMaximumSize
        }
    }
}
