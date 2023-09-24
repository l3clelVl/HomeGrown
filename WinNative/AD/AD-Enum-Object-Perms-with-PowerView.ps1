######################################################################################
#
# Intent: 
#   1) Use PowerView.ps1 to enumerate for GenericAll, GenericWrite, or WriteOwner (ACE/ACL)
#   2) It has the following prompts
#       2.a) If the script fails to find PowerView loaded: "Please provide the full path to the PowerView.ps1 file:"
#       2.b) "Do you want to search for a specific object (Enter '1') or enumerate the entire system (Enter '2')?:""
#           2.b.1) "Enter the name of the object to search for:"
#       2.c) "Do you want to filter results by PermOwner using your username ({$env:USERPROFILE})? (Enter 'Y' for Yes or 'N' for No):"
#       2.d) "Do you want to save the results to a file? (Enter 'Y' for Yes or 'N' for No):"
#           2.d.i) Results are saved to {[Environment]::GetFolderPath("Desktop")}\AD-Obj-Perm-Enum.txt
# Date: Sep23
# Author: DeMzDaRulez
#
#
#
# FYI
### ObjectDN: The Distinguished Name (DN) of the object to which this ACE applies. In this case, it's "robert" in the "Users" container of the "corp.com" domain.
### ObjectSID: The Security Identifier (SID) of the object to which this ACE applies. It uniquely identifies the object in the domain.
### ActiveDirectoryRights: Specifies the type of access rights or permissions granted by this ACE. In this case, it's "ReadProperty," indicating that the user has permission to read properties of the object.
### ObjectAceFlags: Flags associated with this ACE. "ObjectAceTypePresent" indicates that the ACE includes an object-specific ACE.
### ObjectAceType: Specifies the type of object-specific ACE. The value "4c164200-20c0-11d0-a768-00aa006e0529" represents a specific object type in Active Directory.
### InheritedObjectAceType: If this ACE is inherited from a parent object, it specifies the type of the inherited ACE. In this case, it's "00000000-0000-0000-0000-000000000000," indicating that it's not inherited.
### BinaryLength: The length of the binary representation of the ACE.
### AceQualifier: Specifies whether the ACE allows or denies access. "AccessAllowed" indicates that it allows access.
### IsCallback: Indicates whether this ACE is a callback ACE. In this case, it's "False," meaning it's not a callback ACE.
### OpaqueLength: The length of any opaque data associated with the ACE. It's "0" in this case, indicating there is no opaque data.
### AccessMask: Specifies the specific access permissions granted by this ACE. The value "16" represents a specific permission, but the meaning of the permission depends on the context of the object.
### SecurityIdentifier: The SID of the user or group to which the ACE applies. In this case, it's "S-1-5-21-1987370270-658905905-1781884369-553," which represents a specific user or group.
### AceType: Indicates the type of ACE. "AccessAllowedObject" indicates that it's an ACE that allows access to a specific object.
### AceFlags: Flags associated with this ACE. "None" indicates no specific flags are set.
### IsInherited: Indicates whether this ACE is inherited from a parent object. In this case, it's "False," indicating it's not inherited.
### InheritanceFlags: Specifies how the ACE is inherited. "None" indicates that it's not inherited.
### PropagationFlags: Specifies how the ACE is propagated to child objects. "None" indicates that it's not propagated.
### AuditFlags: Specifies audit settings for this ACE. "None" indicates that no audit settings are applied.
######################################################################################


## Check if PowerView is already imported
$moduleImported = $false
if (-Not (Get-Module -Name 'PowerView' -ListAvailable)) {
    # Attempt to import PowerView
    try {
        Import-Module PowerView.ps1 -ErrorAction Stop
        $moduleImported = $true
    } catch {
        Write-Host "Failed to automatically import PowerView."
        
        # Ask the user for the path to the PowerView module
        $powerViewPath = Read-Host "Please provide the full path to the PowerView.ps1 file"
        
        # Attempt to import PowerView from the user-provided path
        try {
            Import-Module $powerViewPath -ErrorAction Stop
            $moduleImported = $true
        } catch {
            Write-Host "Failed to import PowerView from the provided path. Exiting."
            exit
        }
    }
}

# Define a function to enumerate and filter ACLs
function Get-FilteredACL {
    param (
        [string]$adObjectName
    )

    $results = $null
    try {
        $results = Get-ObjectAcl -Identity $adObjectName | 
            Select-Object ActiveDirectoryRights, SecurityIdentifier, ObjectDN |  # Include ObjectDN
            Where-Object { $_.ActiveDirectoryRights -eq 'GenericAll' -or $_.ActiveDirectoryRights -eq 'GenericWrite' -or $_.ActiveDirectoryRights -eq 'WriteOwner' } | 
            ForEach-Object { 
                $convertedSid = Convert-SidToName $_.SecurityIdentifier
                [PSCustomObject]@{
                    'ActiveDirectoryRights' = $_.ActiveDirectoryRights
                    'PermOwner(ConvertedSID)' = $convertedSid  # Updated column header
                    'PermSubject(ObjectDN)' = $_.ObjectDN   # Include ObjectDN with the updated column header
                }
            } 

        # Prompt user to filter results based on $env:USERNAME
        $filterByUser = Read-Host "Do you want to filter results by PermOwner using your username ($env:USERNAME)? (Enter 'Y' for Yes or 'N' for No)"
        if ($filterByUser -eq 'Y') {
            $results = $results | Where-Object { $_.'PermOwner(ConvertedSID)' -like "*$env:USERNAME*" }
        }
        
        $results = $results | Sort-Object ActiveDirectoryRights, 'PermOwner(ConvertedSID)', 'PermSubject(ObjectDN)' -Descending |  # Sort by updated column headers
            Get-Unique -AsString
    } catch {
        Write-Host "An error occurred while enumerating ACLs: $_"
    }

    return $results
}

# Ask the user whether to search for a specific object or enumerate the entire system
$choice = Read-Host "Do you want to search for a specific object (Enter '1') or enumerate the entire system (Enter '2')?"

if ($choice -eq '1') {
    # User wants to search for a specific object
    $adObjectName = Read-Host "Enter the name of the object to search for"
    
    Write-Host "Enumerating ACLs for '$adObjectName'..."
    
    # Call the function to get filtered ACLs
    $resultOutput = Get-FilteredACL -adObjectName $adObjectName

    if ($resultOutput -ne $null) {
        Write-Host "Enumeration completed. Found $($resultOutput.Count) results:"
        
        # Display the results as a list
        $resultOutput | Format-List | Out-String

        # Ask the user if they want to save the result to a file
        $saveToFile = Read-Host "Do you want to save the results to a file? (Enter 'Y' for Yes or 'N' for No)"
        
        if ($saveToFile -eq 'Y') {
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $filePath = Join-Path -Path $desktopPath -ChildPath "AD-Obj-Perm-Enum.txt"
            
            $resultOutput | Set-Content $filePath
            Write-Host "Results saved to $filePath"
        }
    } else {
        Write-Host "No results found for '$adObjectName'."
    }
}
elseif ($choice -eq '2') {
    # User wants to enumerate the entire system (equivalent to searching for "*")
    $adObjectName = "*"
    
    Write-Host "Enumerating ACLs for the entire system..."
    
    # Call the function to get filtered ACLs
    $resultOutput = Get-FilteredACL -adObjectName $adObjectName

    if ($resultOutput -ne $null) {
        Write-Host "Enumeration completed. Found $($resultOutput.Count) results:"
        
        # Display the results as a list
        $resultOutput | Format-List | Out-String

        # Ask the user if they want to save the result to a file
        $saveToFile = Read-Host "Do you want to save the results to a file? (Enter 'Y' for Yes or 'N' for No)"
        
        if ($saveToFile -eq 'Y') {
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $filePath = Join-Path -Path $desktopPath -ChildPath "AD-Obj-Perm-Enum.txt"
            
            $resultOutput | Set-Content $filePath
            Write-Host "Results saved to $filePath"
        }
    } else {
        Write-Host "No results found for the entire system."
    }
}
else {
    Write-Host "Invalid choice. Please enter '1' to search for a specific object or '2' to enumerate the entire system."
}

