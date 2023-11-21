$ComputerIPs = "172.16.97.6", "172.16.97.5", "172.16.97.254", "172.16.97.14", "172.16.97.15", "172.16.97.7", "172.16.97.21", "172.16.97.30"
$Credential = Get-Credential -UserName "RELIA\Administrator" -Message "Enter your password"

foreach ($ComputerIP in $ComputerIPs) {
    Write-Host "Running command on $ComputerIP"
    
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
        Get-ChildItem -Path C:\Users\ -Recurse -Filter "proof.txt" -ErrorAction SilentlyContinue
    }
    
    Write-Host "Command completed on $ComputerIP"
}
