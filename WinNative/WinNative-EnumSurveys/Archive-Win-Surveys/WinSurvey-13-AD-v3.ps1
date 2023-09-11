# Define the output file path
$output_file = "C:\\Users\\$env:USERNAME\\Untitled-AD.txt"

# Function to append output to the file
function Write-ToFile($content) {
    Add-Content -Path $output_file -Value $content
}

# Fetching all users in the domain
Write-ToFile "`n===== Domain Users ====="
$domain_users = net user /domain
$clean_users = $domain_users -split "\r\n" | Where-Object { $_ -match '^[\w\s]+$' }
Write-ToFile ($clean_users -join ", ")


# Fetching all domain groups
Write-ToFile "`n===== Domain Groups ====="
$domain_groups = net group /domain
$clean_groups = $domain_groups -split "\r\n" | Where-Object { $_ -match '^\*[\w\s]+$' }
Write-ToFile ($clean_groups -join ", ")


# Write Users Header
Write-ToFile "===== Domain Users ====="

# Write Users
foreach ($user in $user_lines) {
    $clean_user = ($user -match '^\s*(\w+)')[0]
    Write-ToFile "`nUser: $clean_user"

    # Fetch group memberships for the user
    $user_details = net user $clean_user /domain 2>&1 | Out-String
    $user_groups = $user_details -split "\r\n" | Where-Object { $_ -match '\*.*$' }
    Write-ToFile "Groups: $($user_groups -join ', ')"
}



# Write Groups Header
Write-ToFile "`n===== Domain Groups ====="

# Write Groups
foreach ($group in $group_lines) {
    $clean_group = ($group -match '^\s*(\*\w+)')[0]
    Write-ToFile "`nGroup: $clean_group"

    # Fetch members for the group
    $group_members = net group $clean_group /domain 2>&1 | Out-String
    $members = $group_members -split "\r\n" | Where-Object { $_ -match '^\s*(\w+)' }
    Write-ToFile "Members: $($members -join ', ')"
}
