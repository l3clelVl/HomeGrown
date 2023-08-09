# PowerShell Script to Gather Exhaustive Driver Information

# Ensure the script runs with elevated privileges
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    exit
}

# Define the output file path
$output_file = "$env:USERPROFILE\Untitled-DriverInfo.txt"

# Clear any existing content in the file
if (Test-Path $output_file) {
    Clear-Content -Path $output_file
}

# Function to append output to the file
function Write-OutputToFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$content
    )

    Add-Content -Path $output_file -Value $content
}

# Gather a list of all installed device drivers
Write-OutputToFile "===== Installed Device Drivers ====="
driverquery | Out-String | Write-OutputToFile

# Additional driver information with module name and display name
Write-OutputToFile "`n===== Detailed Driver Information with Module Name and Display Name ====="
driverquery /FO list | Out-String | Write-OutputToFile

# Driver signing verification
Write-OutputToFile "`n===== Driver Signing Verification ====="
Get-ChildItem -Path "C:\Windows\System32\drivers" -Recurse -Include *.sys | ForEach-Object {
    $signer = Get-AuthenticodeSignature -FilePath $_.FullName
    Write-Output "File: $($_.FullName) - Signed By: $($signer.SignerCertificate.Subject)"
} | Out-String | Write-OutputToFile

# End of script
Write-OutputToFile "`n===== End of Driver Information ====="
