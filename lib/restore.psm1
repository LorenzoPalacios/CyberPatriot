function Import-RegistryObject {
  param (
    [Parameter(Mandatory)]
    [string[]]$Path,
    [Parameter(Mandatory)]
    [string]$Destination
  )
  foreach ($p in $Path) {
    [string]$obj_name = (Get-Item -Path "$p").Name
    reg.exe restore $Destination $obj_name
  }
}

function Import-AuditPolicy() {
  param (
    [Parameter(Mandatory)]
    [string]$Path
  )
  auditpol.exe /restore /file:"$Path"
}

function Import-SecurityPolicy() {
  param (
    [Parameter(Mandatory)]
    [string]$Path
  )
  [string]$localSDB = "$env:windir\security\database\secedit.sdb"
  SecEdit.exe /import /db $localSDB /cfg $Path /quiet
}
