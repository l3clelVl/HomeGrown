# PowerShell Script to gather User Information on Windows

# Get current username and domain
whoami | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Extended User Information
net user $env:USERNAME | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Groups the current user belongs to
whoami /groups | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Groups a specific user belongs to
net user $env:USERNAME /domain | findstr /B /C:"Local Group Memberships" /C:"Global Group Memberships" | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Basic list of local users
net user | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Detailed information for each user
foreach ($user in (net user)) {
    net user $user | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII
}

# Basic list of domain users
net user /domain | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Detailed information for a domain user
net user $env:USERNAME /domain | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Listing User Profiles
wmic useraccount get name,sid | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Local User's Last Login Time
net user $env:USERNAME | findstr /B /C:"Last logon" | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Domain User's Last Login Time
net user $env:USERNAME /domain | findstr /B /C:"Last logon" | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Local Administrators
net localgroup Administrators | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Domain Administrators
net group "Domain Admins" /domain | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Current User's Home Directory
echo $env:USERPROFILE | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# Specific User's Home Directory
Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false } | Select-Object LocalPath | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII

# User's Account Status
wmic useraccount where name='$env:USERNAME' get disabled | Out-File -Append "$env:USERPROFILE\Untitled.txt" -Encoding ASCII
