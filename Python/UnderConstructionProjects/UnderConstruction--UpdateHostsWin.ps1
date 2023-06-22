function Prompt-User($prompt) {
    Write-Host $prompt -NoNewline
    return Read-Host
}

function Search-HostsFile($hostname) {
    $results = @()
    $lines = Get-Content 'C:\Windows\System32\drivers\etc\hosts'
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "\b$([regex]::Escape($hostname))\b" -or $lines[$i] -match "^#.*\b$([regex]::Escape($hostname))\b") {
            $match = [PSCustomObject]@{
                LineNumber = $i + 1
                Line = $lines[$i]
            }
            $results += $match
        }
    }
    return $results
}




function Display-Matches($matches) {
    foreach ($match in $matches) {
        Write-Host "$($match.LineNumber): $($match.Line)"
    }
}


function Change-IP($matches) {
    $lineNumber = Prompt-User 'Enter the line number to change the IP: '
    $newIP = Prompt-User 'Enter the new IP: '
    $matches[$lineNumber - 1] = @($matches[$lineNumber - 1][0], $matches[$lineNumber - 1][1] -replace '\b(?:\d{1,3}\.){3}\d{1,3}\b', $newIP)
    Write-Host 'IP changed successfully!'
}

function Add-Hostname($matches) {
    $newHostname = Prompt-User 'Enter the new hostname: '
    $newIP = Prompt-User 'Enter the IP for the new hostname: '
    $matches += @($matches.Count + 1, "$newIP`t$newHostname")
    Write-Host 'New hostname added successfully!'
}

function Remove-Line($matches) {
    $lineNumber = Prompt-User 'Enter the line number to remove: '
    if ($lineNumber -ge 1 -and $lineNumber -le $matches.Count) {
        $matches.RemoveAt($lineNumber - 1)
        Write-Host 'Line removed successfully!'
    } else {
        Write-Host 'Invalid line number. Please try again.'
    }
}

function Main {
    $hostname = Prompt-User 'Enter the hostname to search: '
    $matches = Search-HostsFile $hostname
    if ($matches) {
        Display-Matches $matches
        while ($true) {
            $choice = Prompt-User 'Options:`n(1) Change IP`n(2) Add new hostname`n(3) Remove line`n(4) Search for a new hostname`n(5) Exit`n'
            switch ($choice) {
                '1' {
                    Change-IP $matches
                }
                '2' {
                    Add-Hostname $matches
                }
                '3' {
                    Remove-Line $matches
                }
                '4' {
                    Main
                }
                '5' {
                    break
                }
                default {
                    Write-Host 'Invalid choice. Try again.'
                }
            }
        }
    } else {
        Write-Host 'No matches found.'
    }
}

Main
