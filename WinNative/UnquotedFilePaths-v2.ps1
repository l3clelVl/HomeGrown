# Define the output file path
# This will create a text file named 'UnquotedFilePathResults.txt' in the current user's profile directory
$outputFile = "$env:USERPROFILE\UnquotedFilePathResults.txt"

# Fetch the services
# 1. Get-WmiObject Win32_Service fetches all services on the system
# 2. The Where-Object cmdlet filters these services based on their PathName:
#    - It should not be enclosed in quotes (`-notmatch '^".*"$'`)
#    - It must match the pattern of drive letter, colon, backslash, followed by characters without double quotes, a space, more characters without double quotes, a dot, and then 3 word characters (`-match '^[A-Z]:\\[^"]*\s[^"]*\.\w{3}$'`)
# 3. Select-Object then picks only the DisplayName, PathName, and StartMode properties from the filtered services
$services = Get-WmiObject Win32_Service | Where-Object { $_.PathName -notmatch '^".*"$' -and $_.PathName -match '^[A-Z]:\\[^"]*\s[^"]*\.\w{3}$' } | Select-Object DisplayName, PathName, StartMode

# Regular expression pattern
# This regex pattern matches file paths that start with a drive letter, followed by a colon, any characters, a dot, and 3 word characters. It captures most common file paths.
$pattern = '[a-zA-Z]:\\.*?\.\w{3}'

# Loop through each service's PathName and extract the file paths
foreach ($service in $services) {
    # Skip processing the service if its PathName is empty or null
    if (-not [string]::IsNullOrWhiteSpace($service.PathName)) {
        # Display and write the DisplayName of the service to the output file
        "DisplayName: $($service.DisplayName)" | Tee-Object -Append -FilePath $outputFile

        # Display and write the PathName of the service to the output file
        "PathName: $($service.PathName)" | Tee-Object -Append -FilePath $outputFile

        # Display and write the StartMode of the service to the output file
        "StartMode: $($service.StartMode)" | Tee-Object -Append -FilePath $outputFile
        
        # Extract all file paths from the service's PathName that match the regex pattern
        $matches = [regex]::Matches($service.PathName, $pattern)

        # Loop through each matched file path
        foreach ($match in $matches) {
            # Display and write the matched file path to the output file
            "FilePath: $($match.Value)" | Tee-Object -Append -FilePath $outputFile

            # Execute the 'icacls' command against the matched file path to retrieve its access control lists (permissions)
            # The output is displayed on the screen and also written to the output file
            icacls $match.Value | Tee-Object -Append -FilePath $outputFile
        }

        # Add a separator line for clarity between different services in the output file
        "----------------------------------" | Tee-Object -Append -FilePath $outputFile
    }
}
