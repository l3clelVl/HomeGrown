<#
    Script Name: Advanced_AD_GroupQuery.ps1
    Author: DeMzDaRulez
    Date: Sep23
    Version: 2.0

    Description:
    This script interacts with an Active Directory (AD) environment to recursively find all 
    groups an object is a member of, including nested and abstract groupings.

    Capabilities:
    - Accepts the Distinguished Name (DN) of the target object as a command-line argument.
    - Utilizes modular functions for better code reusability and maintainability.
    - Includes basic error handling and logging mechanisms.
    
    Usage:
    .\Advanced_AD_GroupQuery.ps1 -objectDN "CN=Some User,OU=Users,DC=example,DC=com"

    Note: Please test thoroughly before using in a production environment.
#>

# Command-line parameter for object DN
param (
    [string]$objectDN
)

# Function to get the Primary Domain Controller (PDC)
function Get-PDC {
    try {
        return [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
    }
    catch {
        Write-Host "Failed to get PDC: $_"
        exit 1
    }
}

# Function to get the Distinguished Name (DN) of the domain's root object
function Get-DN {
    try {
        return ([adsi]'').distinguishedName
    }
    catch {
        Write-Host "Failed to get DN: $_"
        exit 1
    }
}

# Function to recursively find all groups an object is a member of
function Get-ADGroupMembership {
    param (
        [string]$distinguishedName,
        [System.DirectoryServices.DirectorySearcher]$searcher
    )

    $groups = @()
    $searcher.Filter = "(member=$distinguishedName)"
    
    try {
        $results = $searcher.FindAll()

        foreach ($result in $results) {
            $groupDN = $result.Properties["distinguishedname"][0]
            $groups += $groupDN
            $groups += Get-ADGroupMembership -distinguishedName $groupDN -searcher $searcher
        }
    }
    catch {
        Write-Host "An error occurred during the search: $_"
    }

    return $groups
}

# Validate the object DN parameter
if (!$objectDN) {
    Write-Host "Please provide the Distinguished Name (DN) as an argument."
    exit 1
}

# Initialize DirectoryEntry and DirectorySearcher objects
try {
    $PDC = Get-PDC
    $DN = Get-DN
    $LDAP = "LDAP://$PDC/$DN"
    $direntry = New-Object System.DirectoryServices.DirectoryEntry($LDAP)
    $dirsearcher = New-Object System.DirectoryServices.DirectorySearcher($direntry)
}
catch {
    Write-Host "Initialization failed: $_"
    exit 1
}

# Get and output all the groups the object is a member of
$allGroups = Get-ADGroupMembership -distinguishedName $objectDN -searcher $dirsearcher
Write-Host "Groups the object is a member of:"
$allGroups
