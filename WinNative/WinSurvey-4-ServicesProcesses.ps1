# PowerShell script to gather Service and Process Information

# Get the username for the path
$username = $env:USERNAME

# Specify the path for the output file
$output_file = "C:\Users\$username\Untitled-ProcServices.txt"

# Function to append data to the output file
function WriteOutput($data) {
    Add-Content -Path $output_file -Value $data
}

# Gather and save currently running processes
$processes = tasklist
WriteOutput "`n--- Running Processes ---`n"
WriteOutput $processes

# Pause for a short period to space out the data collection
Start-Sleep -Seconds 2

# Gather and save a list of startup programs
$startup_programs = wmic startup list full
WriteOutput "`n--- Startup Programs ---`n"
WriteOutput $startup_programs

# Pause for a short period to space out the data collection
Start-Sleep -Seconds 2

# Gather and save a list of running services
$services = net start
WriteOutput "`n--- Running Services ---`n"
WriteOutput $services

# Pause for a short period to space out the data collection
Start-Sleep -Seconds 2

# Gather and save detailed service information using PowerShell's Get-Service
$ps_services = Get-Service | Format-Table -AutoSize | Out-String
WriteOutput "`n--- Detailed Service Information ---`n"
WriteOutput $ps_services
