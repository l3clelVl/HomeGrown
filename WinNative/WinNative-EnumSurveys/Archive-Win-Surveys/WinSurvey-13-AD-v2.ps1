# PowerShell script to gather Active Directory information

# Define the output file path
$output_file = "C:\\Users\\$env:USERNAME\\Untitled-AD.txt"

# Function to append output to the file
function Write-ToFile($content) {
    Add-Content -Path $output_file -Value $content
}

# Fetching a list of domains
Write-ToFile "===== Domain Information ====="
$domains = net view /domain
Write-ToFile $domains

# Fetching all users in the domain
Write-ToFile "`n===== Domain Users ====="
$domain_users = net user /domain
Write-ToFile $domain_users

# Fetching all domain users
$domain_users = net user /domain
$user_lines = $domain_users -split "\r\n" | Where-Object { $_ -and $_ -notmatch "The command completed successfully." -and $_ -notmatch "User accounts for" -and $_ -notmatch "-----" }

# Fetching user group memberships for each user
foreach ($user in $user_lines) {
    $clean_user = $user.Trim()  # Remove any extra spaces

    # Sanitize user names
    if ($clean_user -notmatch '^[a-zA-Z0-9]+$') {
        Write-ToFile "`n===== User $clean_user contains invalid characters ====="
        continue  # Skip to the next iteration of the loop
    }

    Write-ToFile "`n===== Group Membership for User $clean_user ====="
    $user_details = net user "$clean_user" /domain 2>&1  # Redirect stderr to stdout to capture errors
    $user_groups = $user_details -split "\r\n" | Where-Object { $_ -match "Local Group Memberships" -or $_ -match "Global Group memberships" }
    Write-ToFile $user_groups
}

# Fetching all domain groups
Write-ToFile "`n===== Domain Groups ====="
$domain_groups = net group /domain
Write-ToFile $domain_groups

# Fetching group membership for each domain group
$group_lines = $domain_groups -split "\r\n" | Where-Object { $_ -and $_ -notmatch "The command completed successfully." -and $_ -notmatch "Group Accounts for" -and $_ -notmatch "-----" }
foreach ($group in $group_lines) {
    $clean_group = $group.Trim() -replace "^\*",""  # Remove the asterisk prefix and any extra spaces

    # Sanitize group names
    if ($clean_group -notmatch '^[a-zA-Z0-9]+$') {
        Write-ToFile "`n===== Group $clean_group contains invalid characters ====="
        continue  # Skip to the next iteration of the loop
    }

    Write-ToFile "`n===== Group Membership for $clean_group ====="
    $group_members = net group "$clean_group" /domain 2>&1  # Redirect stderr to stdout to capture errors
    Write-ToFile $group_members
}


# Additional Active Directory information can be added as needed
