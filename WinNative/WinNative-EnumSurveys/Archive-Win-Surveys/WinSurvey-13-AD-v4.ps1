# PowerShell script to gather Active Directory information

# Define the output file path
$output_file = "C:\\Users\\$env:USERNAME\\Untitled-AD.txt"

# Initialize empty array to store errors
$errors = @()

# Function to append output to the file
function Write-ToFile($content) {
    Add-Content -Path $output_file -Value $content
}

# Fetching all domain users
try {
    $domain_users = (net user /domain)
    $userFlag = $false  # Flag to check if we are in the user list section
    $user_lines = @()

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
        Write-ToFile "User: $user"
    }

} catch {
    $errors += "Error fetching domain users: $_"
}

# Fetching all domain groups
try {
    $domain_groups = (net group /domain)
    $groupFlag = $false  # Flag to check if we are in the group list section
    $group_lines = @()

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
        Write-ToFile "Group: $group"
    }

} catch {
    $errors += "Error fetching domain groups: $_"
}

# Log errors, if any
if ($errors.Count -gt 0) {
    Write-ToFile "`n===== Errors ====="
    Write-ToFile ($errors -join "`n")
}
