# For performance, suppress all progress displays.
$ProgressPreference = 'SilentlyContinue'

function Get-SystemDisk {
    return Get-Disk | Where-Object { $_.IsBoot -and $_.IsSystem }
}

function Get-UnallocatedDiskSize {
    $sysDisk = Get-SystemDisk
    return $sysDisk.Size - $sysDisk.AllocatedSize
}

function Get-BootPartition {
    return Get-Partition | Where-Object { ($_.IsBoot) }
}

function Get-RecoveryPartition {
    [string]$recoveryGPTType = '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}'
    [string]$recoveryMBRType = '39' # Original value: 0x27
    return Get-Partition | Where-Object { ($_.GptType -eq $recoveryGPTType) -or ($_.MbrType -eq $recoveryMBRType) }
}

function Get-MBRStatus {
    $partStyle = (Get-SystemDisk).PartitionStyle
    # 0 for unknown (e.g. RAW), 1 for MBR, 2 for GPT
    return ($partStyle -eq 1) -or ($partStyle -eq 'MBR')
}

function Get-NextDriveLetter {
    [char[]]$inUse = Get-PSDrive -PSProvider FileSystem | ForEach-Object { $_.Name }
    return [char]([char]'C'..[char]'Z' | Where-Object { $inUse -notcontains $_ })[0]
}

function Get-WinreImage {
    $recPart = Get-RecoveryPartition
    [char]$recDriveLetter = $recPart.DriveLetter
    # If no letter is assigned, $recDriveLetter will be some false-y value.
    if (!$recDriveLetter) {
        [char]$recDriveLetter = Get-NextDriveLetter
        $recPart | Set-Partition -NewDriveLetter $recDriveLetter
    }
    [string]$winrePath = "${recDriveLetter}:\recovery\windowsre"
    return Get-Item -LiteralPath "$winrePath\winre.wim" -Force
}

function Remove-RecoveryPartition {
    ReAgentc.exe /disable > $null 2>&1
    Get-RecoveryPartition | Remove-Partition -Confirm:$false
}

function Optimize-RecoveryPartitionOffset {
    $bootPart = Get-BootPartition
    $unallocatedSize = Get-UnallocatedDiskSize
    return $bootPart.Offset + $bootPart.Size + $unallocatedSize
}

function Get-NextPartitionNumber {
    $parts = Get-Partition
    $highestNumber = 1
    foreach ($p in $parts) {
        if ($p.PartitionNumber -gt $highestNumber) {
            $highestNumber = $p.PartitionNumber
        }
    }
    return $highestNumber + 1
}

function New-RecoveryPartition {
    param (
        $Size,
        $Offset
    )
    $recoveryGPTType = 'de94bba4-06d1-4d40-a16a-bfd50179d6ac'
    $recoveryMBRType = '27' # Hexadecimal

    $newPartNumber = Get-NextPartitionNumber

    $sysDiskNumber = (Get-SystemDisk).Number
    $isMBR = Get-MBRStatus

    $recId = if ($isMBR) { $recoveryMBRType } else { $recoveryGPTType }

    $script = New-TemporaryFile
    Write-Output ( `
            "select disk $sysDiskNumber`n" + `
            "create partition primary size=$Size offset=$Offset id=$recId`n"
    ) | Out-File -FilePath $script.FullName -Encoding ascii
    diskpart /s $script.FullName | Out-Null

    $newRecPart = Get-Partition | Where-Object { $_.PartitionNumber -eq $newPartNumber }
    $newRecPart | Format-Volume -FileSystem NTFS -Force -Confirm:$false | Out-Null

    if (!$isMBR) {
        Write-Output ( `
                "select disk $sysDiskNumber`n" + `
                "select partition $newPartNumber`n" + `
                'gpt attributes=0x8000000000000001'
        ) | Out-File -FilePath $script.FullName -Encoding ascii
        diskpart /s $script.FullName | Out-Null
    }
    $script.Delete()
    return $newRecPart
}

function Move-RecoveryPartition {
    $recPart = Get-RecoveryPartition
    $recPartSize = [Math]::Floor($recPart.Size / 1MB) # Diskpart expects sizes in megabytes.
    $recPartIdealOffset = [Math]::Floor((Optimize-RecoveryPartitionOffset) / 1KB) # Diskpart expects offsets in kilobytes.

    $winreImageExportPath = "$env:tmp"
    Get-WinreImage | Copy-Item -Destination $winreImageExportPath
    Remove-RecoveryPartition

    $recDriveLetter = Get-NextDriveLetter
    $recPart = New-RecoveryPartition -Size $recPartSize -Offset $recPartIdealOffset

    $recPart | Set-Partition -NewDriveLetter $recDriveLetter

    $winrePath = "${recDriveLetter}:\recovery\windowsre"
    New-Item $winrePath -ItemType Directory -Force
    Move-Item -Path "$winreImageExportPath\winre.wim" -Destination $winrePath
    ReAgentc.exe /setreimage /path $winrePath > $null 2>&1
    ReAgentc.exe /enable > $null 2>&1

    $recPart | Remove-PartitionAccessPath -AccessPath "${recDriveLetter}:\"
}

function Expand-BootPartition {
    $bootPart = Get-BootPartition
    $expansionSize = $bootPart.Size + (Get-UnallocatedDiskSize)
    if ($expansionSize -ne 0) {
        $bootPart | Resize-Partition -Size $expansionSize
    }
}

function Recovery-IsAfterSystem {
    $bootPart = Get-BootPartition
    $recPart = Get-RecoveryPartition
    return ($recPart.Offset -ge $bootPart.Offset + $bootPart.Size)
}

function Get-RecoveryPartitionMoveCandidacy {
    return (Get-RecoveryPartition -ne $null) -and (Recovery-IsAfterSystem)
}

function Show-Menu() {
    if (Get-RecoveryPartitionMoveCandidacy) {
        $title = '- Safe System Volume Expansion -'
        $desc = 'This script is intended to automate the expansion of the ' + `
                'system partition while providing means for preserving the ' + `
                'recovery partition, which is usually located directly ' + `
                'after the system partition.' + `
                "`n[K]eep or [R]emove the recovery partition? After your choice is made, the script will attempt to expand the system partition."
        $choiceKeepRecovery = 'K'
        $choiceRemoveRecovery = 'R'
        $option = $Host.UI.PromptForChoice($title, $desc, @($choiceKeepRecovery, $choiceRemoveRecovery), 0)
        switch ($option) {
            0 { Move-RecoveryPartition }
            1 { Remove-RecoveryPartition }
        }
    }
    Write-Host 'Total System Partition Space (before expansion): ' ((Get-BootPartition).Size / 1MB) ' MB'
    Expand-BootPartition
    Write-Host 'Total System Partition Space (after expansion): ' ((Get-BootPartition).Size / 1MB) ' MB'
}

function Get-AdminStatus() {
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent()
    return $user.IsInRole($adminRole)
}

Show-Menu
