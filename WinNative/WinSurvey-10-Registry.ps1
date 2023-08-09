# PowerShell Script to Extract Key Registry Information
# Save results to %USERNAME% directory in a file named Untitled-Registry.txt

# Define the output file path
$output_file = Join-Path $env:USERPROFILE "Untitled-Registry.txt"

# Function to write output to the file
function Write-OutputToFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$content
    )

    Add-Content -Path $output_file -Value $content
}

# Extract Autostart Entries
Write-OutputToFile "`n### Autostart Entries ###"
$autostart_entries = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
Write-OutputToFile $autostart_entries

# Extract Recently Accessed Documents
Write-OutputToFile "`n### Recently Accessed Documents ###"
$recent_docs = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs'
Write-OutputToFile $recent_docs

# Extract Other Relevant Registry Paths As Needed...

# End of script
