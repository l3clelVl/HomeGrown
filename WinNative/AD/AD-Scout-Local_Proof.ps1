$ComputerNames = "DC02", "MAIL", "LOGIN", "WK01", "WK02", "INTRANET", "FILES", "WEBBY"

foreach ($ComputerName in $ComputerNames) {
    Write-Host "Running command on $ComputerName"
    
    $Session = New-PSSession -ComputerName $ComputerName
    Invoke-Command -Session $Session -ScriptBlock {
        Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'local.txt|proof.txt' } | ForEach-Object {
            $FilePath = $_.FullName
            $Content = Get-Content -Path $FilePath -Raw
            Write-Host "Contents of $($FilePath):"
            Write-Host $ComputerName 
            Write-Host $Content
        }
    }
    
    Remove-PSSession $Session
    Write-Host "Command completed on $ComputerName"
}
