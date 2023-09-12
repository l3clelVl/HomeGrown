# Function to clean up net user and net group output
function CleanOutput($rawOutput, $isGroup = $false) {
    if ($isGroup) {
        $cleanOutput = $rawOutput[6..($rawOutput.Length - 3)] -join ' '
        return $cleanOutput -split "\s\*"
    } else {
        $cleanOutput = $rawOutput[6..($rawOutput.Length - 3)] -join ' ' 
        return $cleanOutput -split "\s{2,}"
    }
}


try {
    # Fetch all domain users
    $usersOutput = net user /domain
    $domainUsers = CleanOutput $usersOutput

    # Output User Information
    Write-Host "===== Domain Users ====="
    foreach ($user in $domainUsers) {
        $user = $user.Trim()
        if ($user) {
            $userDetail = net user $user /domain
            Write-Host "User: $user"

            # Local and Global Group Memberships
            $groups = $userDetail | Select-String "\*.*" -AllMatches | % { $_.Matches } | % { $_.Value }
            Write-Host "Local Group Memberships: $groups"
        }
    }
} catch {
    Write-Host "Error in user enumeration: $_"
}

try {
    $groupsOutput = net group /domain
    $domainGroups = $groupsOutput[6..($groupsOutput.Length - 3)] -join ' ' -split "\s\*"

    Write-Host "===== Domain Groups ====="
    foreach ($group in $domainGroups) {
        $group = $group.Trim()
        if ($group) {
            Write-Host "Group: $group"

            $membersOutput = net group "$group" /domain
            $start = $false
            $members = @()
            foreach ($line in $membersOutput) {
                if ($line -match "----") { $start = $true; continue }
                if ($start -and $line -notmatch "The command completed successfully") {
                    $members += $line.Trim() -split "\s+"
                }
            }
            $members = $members -join ','
            Write-Host "Members: $members"
        }
    }
} catch {
    Write-Host "Error in group enumeration: $_"
}
