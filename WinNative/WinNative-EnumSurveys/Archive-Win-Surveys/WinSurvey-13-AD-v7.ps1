# WinSurvey-13-AD.ps1
# PowerShell Script to Enumerate User and Group Information from Active Directory

# Initialize empty arrays to store the gathered information
$domain_users = @()
$domain_groups = @()

# Function to execute a command and capture its output as a string
Function Execute-Command ($command) {
    $output = & $command 2>&1 | Out-String
    return $output.Trim()
}

# Enumerate Domain Users
$net_users_output = Execute-Command "net users /domain"
$users_block = $net_users_output -split "\r\n" | Select-String "----" -Context 0, 1000

if ($users_block -ne $null) {
    $domain_users = $users_block.Context.PostContext -split '\s+' | Where-Object { $_ }
}

# Enumerate Domain Groups
$net_groups_output = Execute-Command "net group /domain"
$groups_block = $net_groups_output -split "\r\n" | Select-String "----" -Context 0, 1000

if ($groups_block -ne $null) {
    $domain_groups = $groups_block.Context.PostContext -split '\s+' | Where-Object { $_ }
}

# Output Domain Users
Write-Host "===== Domain Users ====="
foreach ($user in $domain_users) {
    Write-Host "User: $user"
    
    # Local and Global Group Memberships
    $local_groups = Execute-Command "net user $user /domain | Select-String 'Local Group Memberships'"
    $global_groups = Execute-Command "net user $user /domain | Select-String 'Global Group memberships'"

    Write-Host "$user.a) Local Group Memberships: $local_groups"
    Write-Host "$user.b) Global Group Memberships: $global_groups"
}

# Output Domain Groups
Write-Host "===== Domain Groups ====="
foreach ($group in $domain_groups) {
    Write-Host "Group: $group"
    
    $group_details = Execute-Command "net group $group /domain"
    Write-Host "$group.a) Members: $group_details"
}

# Save gathered data to a text file
$all_data = @"
===== Domain Users =====
$($domain_users -join "`r`n")

===== Domain Groups =====
$($domain_groups -join "`r`n")
"@

Set-Content -Path "C:\Path\To\Save\Untitled-AD.txt" -Value $all_data
