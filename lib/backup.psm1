function Export-RegistryObject {
  param (
    [Parameter(Mandatory)]
    [string]$Path,
    [string]$Destination = '.',
    [bool]$Force = $false
  )
  $reg_arg_force = if ($Force) { '/y' }
  [string]$obj_name = (Get-Item -Path "$Path").Name
  [string]$save_name = "$Destination\" + $obj_name.Replace('\', '-') + '.hiv'
  reg.exe save $obj_name $save_name $reg_arg_force > nul 2>&1
}

function Export-SecurityPolicy {
  param (
    [string]$Destination = '.'
  )
  SecEdit.exe /export /cfg "$Destination\secedit.inf" > nul 2>&1
}

function Export-Services() {
  param (
    [string]$Destination = '.'
  )
  $servicesRegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services'
  Export-RegistryObject -Path $servicesRegPath -Destination $Destination
}

function Export-AuditPolicy() {
  param (
    [string]$Destination = '.'
  )
  $expFilename = 'auditpol.csv'
  # Todo: Enumerate an array of file objects instead of testing each candidate path
  for ([Uint64]$i = 0; (Test-Path -Path "$Destination\$expFilename"); $i++) {
    $expFilename = "auditpol ($i).csv"
  }
  auditpol.exe /backup /file:"$Destination\$expFilename"
}

Export-ModuleMember -Function *
