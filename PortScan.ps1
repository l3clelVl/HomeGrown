# Compatible with PS 3.0 and <

# Prompt for the port range
$portRange = Read-Host "Enter the port range (e.g., 1-1024):"

# Prompt for the IP address or IP range
$ipRange = Read-Host "Enter the IP address or IP range (e.g., 192.168.50.151 or 192.168.50.1-192.168.50.10)"

# Split the port range into start and end values
$portStart, $portEnd = $portRange -split '-'

# Split the IP range into start and end values
$ipStart, $ipEnd = $ipRange -split '-'

# Generate an array of port numbers from the range
$ports = [int]$portStart..[int]$portEnd

# Iterate over the IP range
1..255 | ForEach-Object {
    # Assemble the IP address by combining the start and current iteration values
    $ip = "$ipStart.$_"

    # Iterate over the port range and test each port on the IP address
    foreach ($port in $ports) {
        try {
            # Create a TCP client object and attempt to connect to the IP address and port
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect($ip, $port)

            # If the connection is successful, print a message indicating the open port
            if ($tcpClient.Connected) {
                Write-Host "TCP port $port is open on $ip"
            }

            # Close the TCP client connection
            $tcpClient.Close()
        }
        catch {
            # Handle any exceptions (port closed or unreachable)
        }
    }
}
