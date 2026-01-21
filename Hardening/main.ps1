$lib = "$PSScriptRoot\lib"
$backupModule = "$lib\backup.psm1"
$patchesModule = "$lib\patches.psm1"
$restoreModule = "$lib\restore.psm1"
$userModule = "$lib\user.psm1"

Import-Module -Name "$backupModule" -Function *
Import-Module -Name "$restoreModule" -Function *
Import-Module -Name "$userModule" -Function *

Add-User -Name efddt
