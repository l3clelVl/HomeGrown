$ErrorActionPreference = "SilentlyContinue"

$hostname = "example.com"  # Replace with the target hostname or IP address
$ports = 1..65535  # Range of ports to scan

$openPorts = @()
foreach ($port in $ports) {
    $socket = New-Object System.Net.Sockets.TcpClient
    $result = $socket.BeginConnect($hostname, $port, $null, $null)
    $wait = $result.AsyncWaitHandle.WaitOne(100, $false)
    
    if ($wait -and $socket.Connected) {
        Write-Host "Port $port is open"
        $openPorts += $port
        $socket.Close()
    }
    else {
        Write-Host "Port $port is closed"
    }
}

if ($openPorts) {
    Write-Host "Summary: There are $($openPorts.Count) open ports:"
    $openPorts | ForEach-Object { Write-Host $_ }
}
else {
    Write-Host "No open ports found."
}
