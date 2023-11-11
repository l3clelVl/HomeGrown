# Requires -Module ActiveDirectory
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# The files to search for
$files = @(
    "C:\Users\Administrator\Desktop\proof.txt",
    "C:\Users\joe\Desktop\local.txt"
)

# Loop through each computer
foreach ($computer in $computers) {
    # Use Invoke-Command to check files on the remote computer
    Invoke-Command -ComputerName $computer -ScriptBlock {
        param($files)

        foreach ($file in $files) {
            if (Test-Path $file) {
                # If the file exists, display its content
                $content = Get-Content $file
                [PSCustomObject]@{
                    ComputerName = $env:COMPUTERNAME
                    FilePath     = $file
                    Content      = $content
                }
            }
        }
    } -ArgumentList $files -Credential (Get-Credential) -ErrorAction SilentlyContinue
}
