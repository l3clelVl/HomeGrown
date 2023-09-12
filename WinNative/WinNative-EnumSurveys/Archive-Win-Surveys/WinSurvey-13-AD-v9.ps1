
# Function to clean up net user and net group output
function CleanOutput {
    param (
        [string[]]$rawOutput,
        [bool]$isGroup = $false
    )
    
    $cleanOutput = $rawOutput[6..($rawOutput.Length - 3)] -join ' '
    
    if ($isGroup) {
        return $cleanOutput -split "\s\*"
    } else {
        return $cleanOutput -split "\s{2,}"
    }
}

# Enumerate Domain Users (from "Users" script)
try {
    $rawUsers = net user /domain
    $domainUsers = CleanOutput -rawOutput $rawUsers

    Write-Host "===== Domain Users ====="

    $count = 1
    foreach ($user in $domainUsers) {
        Write-Host "$count) User: $user"
        $rawUserGroups = net user $user /domain 2>&1 | Select-String "Local Group Memberships" -Context 0,1
        $localGroups = ($rawUserGroups.Context.PostContext[0] -split "\*") | Where-Object { $_ }

        Write-Host "$count.a) Local Group Memberships"
        $groupCount = 1
        foreach ($group in $localGroups) {
            Write-Host "$count.a.$groupCount) $group"
            $groupCount++
        }
        $count++
    }
} catch {
    Write-Host "Error in user enumeration: $_"
}

# Enumerate Domain Groups (from "Groups" script)
try {
    $rawGroups = net group /domain
    $domainGroups = CleanOutput -rawOutput $rawGroups -isGroup $true

    Write-Host "===== Domain Groups ====="
    $groupCount = 1
    foreach ($group in $domainGroups) {
        $group = $group.Trim()
        if ($group) {
            Write-Host "$groupCount) Group: $group"
            
            $membersOutput = net group "$group" /domain
            $start = $false
            $members = @()
            $counterMember = 0
            foreach ($line in $membersOutput) {
                if ($line -match "----") { $start = $true; continue }
                if ($start -and $line -notmatch "The command completed successfully") {
                    $lineMembers = $line.Trim() -split "\s+"
                    $members += $lineMembers
                }
            }
            Write-Host "$groupCount.a) Members:"
            foreach ($member in $members) {
                $counterMember++
                Write-Host "$groupCount.a.$counterMember) $member"
            }
            $groupCount++
        }
    }
} catch {
    Write-Host "Error in group enumeration: $_"
}
