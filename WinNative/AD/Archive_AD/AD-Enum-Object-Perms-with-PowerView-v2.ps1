######################################################################################
#
# Intent: Single or all, lookup of a user/group for GenericAll, GenericWrite, or WriteOwner (ACE/ACL)
# Date: Sep23
# Author: DeMzDaRulez
#
#
#
#
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

# Enumerate and filter ACLs, then output unique combinations of ActiveDirectoryRights, ConvertedSID, and ObjectDN
Get-ObjectAcl -Identity $adObjectName | 
    Select-Object ActiveDirectoryRights, SecurityIdentifier, ObjectDN |  # Include ObjectDN
    Where-Object { $_.ActiveDirectoryRights -like 'Generic*' -or $_.ActiveDirectoryRights -eq 'WriteOwner' } | 
    ForEach-Object { 
        $convertedSid = Convert-SidToName $_.SecurityIdentifier
        [PSCustomObject]@{
            'ActiveDirectoryRights' = $_.ActiveDirectoryRights
            'ConvertedSID' = $convertedSid
            'ObjectDN' = $_.ObjectDN  # Include ObjectDN
        }
    } |
    Sort-Object ActiveDirectoryRights, ConvertedSID, ObjectDN -Descending |  # Sort by ObjectDN
    Get-Unique -AsString

