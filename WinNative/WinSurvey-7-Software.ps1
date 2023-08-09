# PowerShell script to gather installed software information

# Ensure the script is running with administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

# Initialize output file
$output_file = "$env:USERPROFILE\Untitled-Software.txt"
if (Test-Path $output_file) {
    Remove-Item $output_file -Force
}

# Function to append data to output file
function AppendToOutput {
    param (
        [Parameter(Mandatory=$true)]
        [string]$data
    )

    Add-Content -Path $output_file -Value $data
}

# 1. List all installed software using WMIC
AppendToOutput "=== Installed Software using WMIC ==="
$wmic_output = wmic product get name
AppendToOutput $wmic_output
Start-Sleep -Seconds 2

# 2. List installed software from registry (common locations for 32-bit and 64-bit applications)
AppendToOutput "`n=== Installed Software from Registry (HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall) ==="
$registry_32bit = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object {Get-ItemProperty $_.PSPath} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$registry_32bit | ForEach-Object {AppendToOutput "$($_.DisplayName) - Version: $($_.DisplayVersion) - Publisher: $($_.Publisher) - Install Date: $($_.InstallDate)"}
Start-Sleep -Seconds 2

AppendToOutput "`n=== Installed Software from Registry (HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall) ==="
$registry_64bit = Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object {Get-ItemProperty $_.PSPath} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$registry_64bit | ForEach-Object {AppendToOutput "$($_.DisplayName) - Version: $($_.DisplayVersion) - Publisher: $($_.Publisher) - Install Date: $($_.InstallDate)"}
Start-Sleep -Seconds 2

# 3. List installed software from Program Files directories
AppendToOutput "`n=== Installed Software from Program Files Directories ==="
$program_files = Get-ChildItem "C:\Program Files" -Directory
$program_files | ForEach-Object {AppendToOutput $_.Name}
Start-Sleep -Seconds 2

$program_files_x86 = Get-ChildItem "C:\Program Files (x86)" -Directory
$program_files_x86 | ForEach-Object {AppendToOutput $_.Name}
Start-Sleep -Seconds 2

AppendToOutput "`n=== Script Execution Completed ==="
