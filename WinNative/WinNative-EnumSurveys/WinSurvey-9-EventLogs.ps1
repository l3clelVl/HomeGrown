# PowerShell script to extract Windows Event Logs

# Get the username for file path
$username = $env:USERNAME
$output_file = "C:\Users\$username\Untitled-EventLogs.txt"

# Function to append output to the file
function Write-OutputToFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$content
    )
    Add-Content -Path $output_file -Value $content
}

# Clear previous content if file exists
if (Test-Path $output_file) {
    Clear-Content -Path $output_file
}

# Fetching Application logs
Write-OutputToFile "===== APPLICATION LOGS ====="
Get-EventLog -LogName Application -Newest 100 | ForEach-Object {
    Write-OutputToFile $_.Message
}

# Fetching System logs
Write-OutputToFile "`n===== SYSTEM LOGS ====="
Get-EventLog -LogName System -Newest 100 | ForEach-Object {
    Write-OutputToFile $_.Message
}

# Fetching Security logs (might require elevated privileges)
Write-OutputToFile "`n===== SECURITY LOGS ====="
Get-EventLog -LogName Security -Newest 100 | ForEach-Object {
    Write-OutputToFile $_.Message
}

# Additional logs can be added as needed

# Confirmation of completion
Write-Output "Event logs extracted and saved to $output_file"
