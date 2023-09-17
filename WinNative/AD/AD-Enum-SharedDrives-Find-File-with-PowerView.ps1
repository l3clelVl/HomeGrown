######################################################################################
#
# Intent: User Powerview to enumerate Shared Drives for a specific file (default value = "proof.txt")
# Todo: Donno
# Date: Sep23
# Author: DeMzDaRulez
#
######################################################################################


# Import PowerView module or ask for its location
if (-Not (Get-Command Find-DomainShare -ErrorAction SilentlyContinue)) {
    $modulePath = Read-Host "Please provide the full path to the PowerView.ps1 file"
    Import-Module $modulePath
    if (-Not (Get-Command Find-DomainShare -ErrorAction SilentlyContinue)) {
        Write-Host "Failed to import PowerView. Exiting."
        Exit
    }
}
Write-Host "Successfully imported PowerView."

# Declare target filename as a variable for modularity
$targetFile = "proof.txt"

# Initialize shares array
$shares = @()

# Get or read domain shares
$useFile = Read-Host "Would you like to use a file with previously acquired output from 'Find-DomainShare'? (y/n)"
if ($useFile -eq 'y') {
    $filePath = Read-Host "Provide the full path to the CSV file"
    $shares = Import-Csv $filePath
} else {
    Write-Host "Searching for domain shares..."
    $shares = Find-DomainShare -Verbose
    if ($null -eq $shares) {
        Write-Host "No domain shares found. Exiting."
        Exit
    }
    Write-Host "Successfully found domain shares. Shares found: $($shares.Count)"
}

# Enumerate through each share to find the target file
$totalShares = $shares.Count
$counter = 0
foreach ($share in $shares) {
    $counter++
    $sharePath = "\\$($share.ComputerName)\$($share.Name)"
    Write-Host "`n`n`nChecking share $counter of $($totalShares): $sharePath"
    
    # Find the target file
    $foundFiles = Get-ChildItem -Path $sharePath -Recurse -File -Filter $targetFile -ErrorAction SilentlyContinue
    if ($foundFiles -ne $null) {
        Write-Host "Found target file(s) at the following location(s):"
        $foundFiles | ForEach-Object { Write-Host $_.FullName }
    } else {
        Write-Host "Target file not found in this share."
    }
}
