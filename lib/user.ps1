function Remove-User() {
  param (
    [Parameter(Mandatory)]
    [string]$Username,
    [bool]$EraseData = $false
  )
  if ($EraseData) {
    $usr = Get-LocalUser | Where-Object { $_.Name -eq $Username }
    $SID = $usr.SID.Value
    Remove-Item -Path @("Registry::HKU\$SID", "Registry::HKU\${SID}_Classes") -Force
    Remove-Item -Path "$env:USERPROFILE\..\$Username"
  }
  Remove-LocalUser -Name $Username
}

function Add-User() {
  param (
    [Parameter(Mandatory)]
    [string]$Username,
    [string[]]$Groups
  )
  $password = ConvertTo-SecureString -String 'Th1s1s4S3cr3t!' -AsPlainText -Force
  $usr = New-LocalUser -Name $Username `
    -PasswordNeverExpires:$false `
    -AccountNeverExpires:$true `
    -UserMayNotChangePassword:$false `
    -Password $password
  foreach ($grp in $Groups) {
    $usr | Add-LocalGroupMember -Group $grp
  }
  return $usr
}

function Remove-SpecialGroupMembership {
  param (
    [Parameter(Mandatory)]
    [string]$Name
  )
  $usersSID = 'S-1-5-32-545'
  $groups = Get-LocalGroup
  foreach ($grp in $groups) {
    if ($grp.SID.Value -ne $usersSID) {
      $membership = $grp | Get-LocalGroupMember -Member $Name -ErrorAction Ignore
      if ($null -ne $membership) {
        Remove-LocalGroupMember -Group $grp -Member $Name
      }
    }
  }
}
Remove-SpecialGroupMembership
#Export-ModuleMember -Function *
