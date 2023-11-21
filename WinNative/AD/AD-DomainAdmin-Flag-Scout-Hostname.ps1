$ComputerNames = "DC02", "MAIL", "LOGIN", "WK01", "WK02", "INTRANET", "FILES", "WEBBY"

function IsValidIPAddress($ip) {
    $ipRegex = "^\d{1,3}(\.\d{1,3}){3}$"
    return $ip -match $ipRegex
}

foreach ($ComputerName in $ComputerNames) {
    Write-Host "Running command on $ComputerName"
    
    $foundLocal = $false
    $foundProof = $false
    $retry = $true
    
    while ($retry) {
        try {
            $Session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
            Invoke-Command -Session $Session -ScriptBlock {
                Get-ChildItem -Path C:\Users\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'local.txt|proof.txt' } | ForEach-Object {
                    $FilePath = $_.FullName
                    $Content = Get-Content -Path $FilePath -Raw
                    
                    if ($_ -match 'local.txt') {
                        $foundLocal = $true
                    }
                    
                    if ($_ -match 'proof.txt') {
                        $foundProof = $true
                    }
                    
                    if ($foundLocal -and $foundProof) {
                        Write-Host "Both 'proof.txt' and 'local.txt' found on $($env:COMPUTERNAME[0].HostName)"
                        $retry = $false  # Set retry to false to exit the loop
                        return
                    }
                    
                    Write-Host "Contents of $($FilePath):"
                    Write-Host $env:COMPUTERNAME[0].HostName
                    Write-Host $Content
                }
            }
            
            Remove-PSSession $Session
            Write-Host "Command completed on $ComputerName"
            $retry = $false  # Set retry to false to exit the loop
        } catch {
            Write-Host "Failed to connect to $ComputerName using hostname or IP."
            $IP = Read-Host "Please enter an IP address or press Enter to move on:"
            if ([string]::IsNullOrWhiteSpace($IP)) {
                Write-Host "Moving on to the next system."
                $retry = $false  # Set retry to false to exit the loop
            } elseif (IsValidIPAddress $IP) {
                $ComputerName = $IP  # Set the new ComputerName to the provided IP for retry
            } else {
                Write-Host "Invalid IP address format. Please enter a valid IP address."
            }
        }
    }
}
