# Retrieve the domain of the current machine
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

# Get the LDAP path for the domain
$ldapPath = "LDAP://" + $domain.Name

# Create a directory searcher object
$searcher = New-Object DirectoryServices.DirectorySearcher([ADSI]$ldapPath)

# Set the filter to retrieve computer objects
$searcher.Filter = "(objectClass=computer)"

# Perform the search
$results = $searcher.FindAll()

# Loop through the results and retrieve computer names and IP addresses
foreach ($result in $results) {
    $computer = $result.GetDirectoryEntry()
    $computerName = $computer.Name
    $ipAddress = [System.Net.Dns]::GetHostAddresses($computerName) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }
    
    if ($ipAddress.Count -gt 0) {
        $ip = $ipAddress[0].IPAddressToString
    } else {
        $ip = "N/A"
    }
    
    Write-Host "Computer Name: $computerName | IP Address: $ip"
}
