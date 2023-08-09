# PowerShell Script to Gather Authentication-related Information

# Get details on password policies
$net_accounts = net accounts
$net_accounts | Out-File "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Append
Add-Content -Path "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Value "`n`n"

# List users currently logged into the system
$logged_on_users = qwinsta
$logged_on_users | Out-File "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Append
Add-Content -Path "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Value "`n`n"

# Extract SAM & SYSTEM files information (requires admin privileges)
# Note: This might not execute properly without elevated privileges. Ensure you have the necessary permissions.
$SAM_path = "C:\\Windows\\System32\\config\\SAM"
$SYSTEM_path = "C:\\Windows\\System32\\config\\SYSTEM"

if (Test-Path $SAM_path) {
    Add-Content -Path "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Value "SAM File exists at $SAM_path"
} else {
    Add-Content -Path "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Value "SAM File does not exist or access is denied."
}

if (Test-Path $SYSTEM_path) {
    Add-Content -Path "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Value "SYSTEM File exists at $SYSTEM_path"
} else {
    Add-Content -Path "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Value "SYSTEM File does not exist or access is denied."
}
Add-Content -Path "C:\\Users\\$env:USERNAME\\Untitled-AuthPolicy.txt" -Value "`n`n"

# End of script
