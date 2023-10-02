# ---------------------------------------------------------------------------
# Script Name: Domain User and Group Enumeration
# Author: DeMzDaRulez
# Date: Sep23
# Description: This script recusively enumerates domain users and groups using 'net user /domain' 
# and 'net group /domain' commands.
# ---------------------------------------------------------------------------

# Function to clean up the output from 'net user' and 'net group' commands
function CleanOutput {
    # Define parameters: $rawOutput is the raw command output; $isGroup specifies if it's a group enumeration
    param (
        [string[]]$rawOutput,
        [bool]$isGroup = $false
    )
    
    # Remove the header and footer lines from the raw output
    $cleanOutput = $rawOutput[6..($rawOutput.Length - 3)] -join ' '
    
    # Split the clean output based on the specified delimiter
    if ($isGroup) {
        return $cleanOutput -split "\s\*"  # Split on '*'
    } else {
        return $cleanOutput -split "\s{2,}"  # Split on two or more spaces
    }
}

# Try block for enumerating domain users
try {
    # Execute 'net user /domain' to get raw domain user list
    $rawUsers = net user /domain
    # Clean up the output
    $domainUsers = CleanOutput -rawOutput $rawUsers

    Write-Host "===== Domain Users ====="

    $count = 1
    # Iterate through each user to enumerate details
    foreach ($user in $domainUsers) {
        Write-Host "$count) User: $user"
        
        # Get the local groups the user is a part of
        $rawUserGroups = net user $user /domain 2>&1 | Select-String "Local Group Memberships" -Context 0,1
        # Parse the output to extract local group memberships
        $localGroups = ($rawUserGroups.Context.PostContext[0] -split "\*") | Where-Object { $_ }

        Write-Host "$count.a) Local Group Memberships"
        
        $groupCount = 1
        # List each local group
        foreach ($group in $localGroups) {
            Write-Host "$count.a.$groupCount) $group"
            $groupCount++
        }
        $count++
    }
} catch {
    Write-Host "Error in user enumeration: $_"  # Error handling
}

# Try block for enumerating domain groups
try {
    # Execute 'net group /domain' to get raw domain group list
    $rawGroups = net group /domain
    # Clean up the output
    $domainGroups = CleanOutput -rawOutput $rawGroups -isGroup $true

    Write-Host "===== Domain Groups ====="
    
    $groupCount = 1
    # Iterate through each group to enumerate details
    foreach ($group in $domainGroups) {
        $group = $group.Trim()
        if ($group) {
            Write-Host "$groupCount) Group: $group"
            
            # Get raw member list of the group
            $membersOutput = net group "$group" /domain
            $start = $false
            $members = @()
            $counterMember = 0
            
            # Parse the raw output to extract member names
            foreach ($line in $membersOutput) {
                if ($line -match "----") { $start = $true; continue }
                if ($start -and $line -notmatch "The command completed successfully") {
                    $lineMembers = $line.Trim() -split "\s+"
                    $members += $lineMembers
                }
            }
            Write-Host "$groupCount.a) Members:"
            
            # List each member of the group
            foreach ($member in $members) {
                $counterMember++
                Write-Host "$groupCount.a.$counterMember) $member"
            }
            $groupCount++
        }
    }
} catch {
    Write-Host "Error in group enumeration: $_"  # Error handling
}
