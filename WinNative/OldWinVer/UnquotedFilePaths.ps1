# Define the output file path
$outputFile = "$env:USERPROFILE\UnquotedFilePathResults.txt"

# Fetch the services
$services = Get-WmiObject Win32_Service | Where-Object { $_.PathName -notmatch '^".*"$' -and $_.PathName -match '^[A-Z]:\\[^"]*\s[^"]*\.\w{3}$' } | Select-Object DisplayName, PathName, StartMode

# Regular expression pattern
$pattern = '[a-zA-Z]:\\.*?\.\w{3}'

# Loop through each service's PathName and extract the file paths
foreach ($service in $services) {
    # Skip if PathName is empty or null
    if (-not [string]::IsNullOrWhiteSpace($service.PathName)) {
        "DisplayName: $($service.DisplayName)" | Tee-Object -Append -FilePath $outputFile
        "PathName: $($service.PathName)" | Tee-Object -Append -FilePath $outputFile
        "StartMode: $($service.StartMode)" | Tee-Object -Append -FilePath $outputFile
        
        $matches = [regex]::Matches($service.PathName, $pattern)
        foreach ($match in $matches) {
            "FilePath: $($match.Value)" | Tee-Object -Append -FilePath $outputFile

            # Execute icacls against the file path and redirect its output to both the screen and the file
            icacls $match.Value | Tee-Object -Append -FilePath $outputFile
        }

        "----------------------------------" | Tee-Object -Append -FilePath $outputFile  # Separator for clarity
    }
}
