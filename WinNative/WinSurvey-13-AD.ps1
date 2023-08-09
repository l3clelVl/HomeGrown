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

# Fetching all domain groups
Write-ToFile "`n===== Domain Groups ====="
$domain_groups = net group /domain
Write-ToFile $domain_groups

# Fetching group membership for each domain group
foreach ($group in ($domain_groups -split "\r\n" | Where-Object { $_ -and $_ -notmatch "The command completed successfully." })) {
    Write-ToFile "`n===== Group Membership for $group ====="
    $group_members = net group "$group" /domain
    Write-ToFile $group_members
}

# Additional Active Directory information can be added as needed
