######################################################################################
#
# Intent: Single lookup of a user/group for GenericAll, GenericWrite, or WriteOwner (ACE/ACL)
# Date: Sep23
# Author: DeMzDaRulez
#
######################################################################################



# Check if PowerView is already imported
if (-Not (Get-Module -Name 'PowerView' -ListAvailable)) {
    # Attempt to import PowerView
    try {
        Import-Module PowerView.ps1 -ErrorAction Stop
    } catch {
        Write-Host "Failed to automatically import PowerView."
        
        # Ask the user for the path to the PowerView module
        $powerViewPath = Read-Host "Please provide the full path to the PowerView.ps1 file"
        
        # Attempt to import PowerView from user-provided path
        try {
            Import-Module $powerViewPath -ErrorAction Stop
        } catch {
            Write-Host "Failed to import PowerView from the provided path. Exiting."
            exit
        }
    }
}

# Prompt for the name of the Active Directory object
$adObjectName = Read-Host "Enter the name of the Active Directory object (e.g., Management Department)"

# If the user doesn't provide any name, exit the script
if ([string]::IsNullOrEmpty($adObjectName)) {
    Write-Host "No Active Directory object name provided. Exiting."
    exit
}

# Enumerate and filter ACLs, then output unique combinations of ActiveDirectoryRights and ConvertedSID
Get-ObjectAcl -Identity $adObjectName | 
    Select-Object ActiveDirectoryRights, SecurityIdentifier | 
    Where-Object { $_.ActiveDirectoryRights -like 'Generic*' -or $_.ActiveDirectoryRights -eq 'WriteOwner' } | 
    ForEach-Object { 
        $convertedSid = Convert-SidToName $_.SecurityIdentifier
        [PSCustomObject]@{
            'ActiveDirectoryRights' = $_.ActiveDirectoryRights
            'ConvertedSID' = $convertedSid
        }
    } |
    Sort-Object ActiveDirectoryRights, ConvertedSID -Descending | 
    Get-Unique -AsString
