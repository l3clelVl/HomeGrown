# Prompt the user to enter the IP range to scan
$ipRange = Read-Host "Enter the IP range to scan (e.g., 192.168.1.1-192.168.1.255):"

# Split the IP range into start and end values
$ipStart, $ipEnd = $ipRange -split '-'

# Split the start and end IP addresses into parts
$ipStartParts = $ipStart.Split('.')
$ipEndParts = $ipEnd.Split('.')

# Iterate over the range of IP addresses
for ($i = [int]$ipStartParts[3]; $i -le [int]$ipEndParts[3]; $i++) {
    # Assemble the IP address by combining the first three parts and the current iteration value
    $ip = "$($ipStartParts[0]).$($ipStartParts[1]).$($ipStartParts[2]).$i"

    # Test the reachability of the IP address using the `Test-Connection` cmdlet
    $result = Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue

    # Check if the IP address is reachable (host found)
    if ($result) {
        Write-Host "Host found: $ip"
    }
}
