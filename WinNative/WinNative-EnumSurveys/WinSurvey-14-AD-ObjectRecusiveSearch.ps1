<#
.SYNOPSIS
    This script performs a recursive LDAP search based on the provided ObjectCategory and CN, starting from the initial input and following member relationships until no more members are found.

    I have aspirations to make it more modular for users and their membership. I will consider this script to be complete when the chain of all members in relation to the group searched (ultimately be "Domain Admins", if "Enterprise Admins" don't exist) are revealed.

.DESCRIPTION
    This script first loads the LDAPSearch function from a separate script file (function.ps1). It then prompts for a usage example to illustrate how to use the script. After that, it prompts the user for ObjectCategory and CN and initiates the recursive search.

.NOTES
    File Name      : RecursiveLDAPSearch.ps1
    Author         : DeMzDaRulez
    Prerequisite   : Ensure that the LDAPSearch function is defined in function.ps1.
	GNU Copyright 2023

#>

# Define the LDAPSearch function for performing LDAP queries.
function LDAPSearch {
    param (
        [string]$LDAPQuery
    )
    
    # Get the Primary Domain Controller (PDC) name for the current domain.
    $PDC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name

    # Get the Distinguished Name (DN) of the current user.
    $DistinguishedName = ([adsi]'').distinguishedName
    
    # Create a DirectoryEntry object for the LDAP query.
    $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$PDC/$DistinguishedName")
    
    # Create a DirectorySearcher object with the provided LDAP query.
    $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher($DirectoryEntry, $LDAPQuery)
    
    # Perform the LDAP search and return the results.
    return $DirectorySearcher.FindAll()
}

# Prompt for a usage example to illustrate how to use the script.
Write-Host "Usage Example:"
Write-Host "----------------"
Write-Host "To start the search, you can use an example like this:"
Write-Host "> RecursivelySearchMembers -ObjectCategory 'group' -CN 'Service Personnel'"
Write-Host "This will initiate the search for 'Service Personnel' within 'group'."

# Prompt the user for ObjectCategory and CN.
$ObjectCategory = Read-Host "Enter ObjectCategory"
$CN = Read-Host "Enter CN"

# Define the RecursivelySearchMembers function for recursive member search.
function RecursivelySearchMembers {
    param (
        [string]$ObjectCategory,
        [string]$CN
    )

    # Construct the LDAP query with the provided ObjectCategory and CN.
    $query = "(&(objectCategory=$ObjectCategory)(cn=$CN))"
    
    # Perform an LDAP search using the LDAPSearch function.
    $service = LDAPSearch -LDAPQuery $query

    if ($service) {
        # Iterate through each member in the search results.
        $service.Properties.member | ForEach-Object {
            Write-Host $_

            # Extract CN from the DN for recursion.
            $memberCN = ($_ -split ',')[0] -replace 'CN=', ''

            # Recursively call the function with the member's ObjectCategory and CN.
            RecursivelySearchMembers -ObjectCategory $ObjectCategory -CN $memberCN
        }
    }
}

# Start the recursive search by calling the RecursivelySearchMembers function with user-provided ObjectCategory and CN.
RecursivelySearchMembers -ObjectCategory $ObjectCategory -CN $CN
