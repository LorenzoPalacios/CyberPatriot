$lib = '.\lib'
$backupModule = "$lib\backup.psm1"
$restoreModule = "$lib\restore.psm1"

Import-Module -Name "$backupModule" -Function *
Import-Module -Name "$restoreModule" -Function *

Export-AuditPolicy -
