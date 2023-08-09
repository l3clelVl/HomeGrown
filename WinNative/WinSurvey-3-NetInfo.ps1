# PowerShell script to gather key Network Information

# Get the username for the directory path
$username = $env:USERNAME

# Set the path for the output file
$output_file = "C:\Users\$username\Untitled-NetInfo.txt"

# Function to save output to the file
function Save-Output($content) {
    Add-Content -Path $output_file -Value $content
}

# Gather IP Configuration
$content = ipconfig /all
Save-Output "`n`n[+] IP Configuration:`n$content"

# Get Active Network Connections
$content = netstat -ano
Save-Output "`n`n[+] Active Network Connections:`n$content"

# Retrieve the Routing Table
$content = route print
Save-Output "`n`n[+] Routing Table:`n$content"

# Get Firewall Status for all profiles
$content = netsh advfirewall show allprofiles
Save-Output "`n`n[+] Firewall Status:`n$content"

# Script execution completed
Write-Host "Network Information saved to $output_file"
