# PowerShell script to gather Active Directory information
# Define the output file path
$output_file = "C:\\Users\\$env:USERNAME\\Untitled-AD.txt"

# Initialize empty array to store errors
$errors = @()

# Function to append output to the file
function Write-ToFile($content) {
    Add-Content -Path $output_file -Value $content
}

# Fetching all domain users and their group memberships
try {
    $domain_users = (net user /domain)
    $userFlag = $false
    $user_lines = @()
    $counter = 1

    foreach ($line in $domain_users) {
        if ($line -match 'The command completed successfully') {
            $userFlag = $false
        }
        if ($userFlag) {
            $user_lines += $line.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
        }
        if ($line -match '---') {
            $userFlag = $true
        }
    }

    Write-ToFile "`n===== Domain Users ====="
    foreach ($user in $user_lines) {
        Write-ToFile "$counter) User: $user"
        try {
            $userDetails = (net user "$user" /domain)
            foreach ($detail in $userDetails) {
                if ($detail -match 'Local Group Memberships') {
                    Write-ToFile "$counter.a) $detail"
                }
                if ($detail -match 'Global Group memberships') {
                    Write-ToFile "$counter.b) $detail"
                }
            }
        } catch {
            Write-ToFile "Error fetching details for user $user: $_"
        }
        $counter++
    }

} catch {
    $errors += "Error fetching domain users: $_"
}

# Fetching all domain groups and their members
try {
    $domain_groups = (net group /domain)
    $groupFlag = $false
    $group_lines = @()
    $counter = 1

    foreach ($line in $domain_groups) {
        if ($line -match 'The command completed successfully') {
            $groupFlag = $false
        }
        if ($groupFlag) {
            $group_lines += $line.Split("`r`n", [StringSplitOptions]::RemoveEmptyEntries)
        }
        if ($line -match '---') {
            $groupFlag = $true
        }
    }

    Write-ToFile "`n===== Domain Groups ====="
    foreach ($group in $group_lines) {
        Write-ToFile "$counter) Group: $group"
        try {
            $groupMembers = (net group "$group" /domain)
            $members = $false
            foreach ($member in $groupMembers) {
                if ($member -match 'The command completed successfully') {
                    $members = $false
                }
                if ($members) {
                    Write-ToFile "$counter.a) Members: $member"
                }
                if ($member -match '---') {
                    $members = $true
                }
            }
        } catch {
            Write-ToFile "Error fetching details for group $group: $_"
        }
        $counter++
    }

} catch {
    $errors += "Error fetching domain groups: $_"
}

# Log errors, if any
if ($errors.Count -gt 0) {
    Write-ToFile "`n===== Errors ====="
    Write-ToFile ($errors -join "`n")
}
