# PowerShell Script to Gather WMI Information and Save to Untitled-WMI.txt

# Ensure the script is running with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You need to run this script as an Administrator!" -ErrorAction Stop
}

# Define the output file location
$output_file = "C:\Users\$env:USERNAME\Untitled-WMI.txt"

# Function to append data to the output file
function Write-ToFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$content
    )

    Add-Content -Path $output_file -Value $content
}

# Gather basic system information
Write-ToFile "===== Basic System Information ====="
Get-WmiObject -Class Win32_ComputerSystem | Format-List | Out-String | Write-ToFile

# Gather BIOS information
Write-ToFile "`n===== BIOS Information ====="
Get-WmiObject -Class Win32_BIOS | Format-List | Out-String | Write-ToFile

# Gather Operating System information
Write-ToFile "`n===== Operating System Information ====="
Get-WmiObject -Class Win32_OperatingSystem | Format-List | Out-String | Write-ToFile

# Gather Disk Drive information
Write-ToFile "`n===== Disk Drive Information ====="
Get-WmiObject -Class Win32_DiskDrive | Format-List | Out-String | Write-ToFile

# Gather Network Adapter Configuration
Write-ToFile "`n===== Network Adapter Configuration ====="
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Format-List | Out-String | Write-ToFile

# Gather Installed Software
Write-ToFile "`n===== Installed Software ====="
Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Format-List | Out-String | Write-ToFile

# Gather Service Information
Write-ToFile "`n===== Service Information ====="
Get-WmiObject -Class Win32_Service | Where-Object { $_.StartMode -eq "Auto" -and $_.State -eq "Running" } | Select-Object DisplayName, State | Format-List | Out-String | Write-ToFile

# Gather User Account Information
Write-ToFile "`n===== User Account Information ====="
Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.Disabled -eq $false } | Format-List | Out-String | Write-ToFile

# Gather System Process Information
Write-ToFile "`n===== System Process Information ====="
Get-WmiObject -Class Win32_Process | Format-List | Out-String | Write-ToFile

# Gather Startup Command Information
Write-ToFile "`n===== Startup Command Information ====="
Get-WmiObject -Class Win32_StartupCommand | Format-List | Out-String | Write-ToFile

# Wrap up
Write-Output "Data gathering complete. Results saved to $output_file."
