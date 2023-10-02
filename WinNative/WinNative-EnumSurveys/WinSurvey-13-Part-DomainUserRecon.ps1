Write-Host "===== Domain Users that aren't locked out ====="
([adsisearcher]"(&(samAccountType=805306368)(!(admincount=1))(!(lockoutTime>=1))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))").FindAll() | ForEach-Object { $_.Properties["samaccountname"][0] }

Write-Host "===== Domain Admins that aren't locked out ====="
([adsisearcher]"(&(samAccountType=805306368)(admincount=1)(!(lockoutTime>=1)))").FindAll() | ForEach-Object { $_.Properties["samaccountname"][0] }

Write-Host "===== Domain accounts that are locked out ====="
([adsisearcher]"(&(samAccountType=805306368)(lockoutTime>=1))").FindAll() | ForEach-Object { $_.Properties["samaccountname"][0] }
