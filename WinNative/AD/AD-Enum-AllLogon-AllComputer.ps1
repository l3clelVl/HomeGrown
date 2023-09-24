######################################################################################
#
# Intent: 
#   1) Find and pipe all AD domain computers into Computers.txt
#   2) Next, attempts to PS-remote into each computer in the list to find the:
#       a) Users logged in
#       b) Interactive users
#       c) User's last login date
#   3) Generate a report file named C:\LoggedOnResults.txt, in a tabled format.
# Date: Sep23
# Author: DeMzDaRulez
#
######################################################################################


# Deletes the current file C:\Computers.txt (if it exists)
$FileName = "C:\Computers.txt"
if (Test-Path $FileName) {
    Remove-Item $FileName
    write-host "$FileName has been deleted"
}

else {
    Write-host "$FileName doesn't exist"
}


# 0. Capture all AD computers into a text file named Computers.txt
# importing dependancy, assuming it's already installed.
# Install RSAT for Windows workstation, AD DS role for Windows Server if missing
Import-Module "ActiveDirectory"

Get-ADComputer -Filter {(OperatingSystem -like "*windows*") -and (Enabled -eq "True")} | Select -Expand Name | Out-File "C:\Computers.txt"

# 1. Create scriptblock to target computer will execute
$SB = {
    
    $explorerprocesses = @(Get-WmiObject -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue)
    if ($explorerprocesses.Count -eq 0)    {
            New-Object -TypeName PSObject -Property @{
                ComputerName = $env:COMPUTERNAME;
                Username = [string]::Empty
                LoggedOnSince = [string]::Empty
            }
    } else {
        foreach ($i in $explorerprocesses)    {
            $Username = $i.GetOwner().User
            $Domain = $i.GetOwner().Domain
            New-Object -TypeName PSObject -Property @{
                ComputerName = $env:COMPUTERNAME ;
                Username = '{0}\{1}' -f $Domain,$Username ;
                LoggedOnSince  = ($i.ConvertToDateTime($i.CreationDate)) ;
            }
        }
    }
} # endof scriptblock
    
# 2. Create an empty array to store results
$results = @()
    
# 3. Query target computers using PSRemoting
Get-content "C:\Computers.txt" | ForEach-Object -Process {
    $computer = $_
    try {
        $results += Invoke-Command -ComputerName $Computer -ScriptBlock $SB -ErrorAction Stop
    } catch {
        Write-Warning -Message "Faild to use PSremoting on $Computer because $($_.Exception.Message)"
    }
}
    
# 4. Display the results
$results | Select ComputerName,Username,LoggedOnSince | ft -AutoSize

# 5. Send results to a text file

$results | Select ComputerName,Username,LoggedOnSince | ft -AutoSize | Out-File -FilePath "C:\LoggedOnResults.txt"
