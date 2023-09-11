# PowerShell script to gather Mounted Filesystems and attached drives information
# The results will be saved periodically to a file named "Untitled-FileSysInfo.txt" in the %USERNAME% directory

# Ensuring the script continues even if an error occurs
$ErrorActionPreference = "SilentlyContinue"

# File to save results
$output_file = "$env:USERPROFILE\Untitled-FileSysInfo.txt"

# Function to append output to the file
function Save-Output($command) {
    # Execute the command and append the output to the file
    Invoke-Expression $command | Out-File -Append $output_file
    # Add a separator for clarity between command outputs
    "`n---`n" | Out-File -Append $output_file
}

# Get all logical drives
Save-Output "Get-WmiObject -Class Win32_LogicalDisk | Format-List DeviceID, DriveType, ProviderName, VolumeName, Size, FreeSpace"

# Get all physical drives
Save-Output "Get-WmiObject -Class Win32_DiskDrive | Format-List DeviceID, MediaType, Model, InterfaceType, Size"

# Get all partitions
Save-Output "Get-WmiObject -Class Win32_DiskPartition | Format-List DeviceID, BootPartition, PrimaryPartition, Size, Type"

# Get all volumes
Save-Output "Get-WmiObject -Class Win32_Volume | Format-List Name, Label, DriveType, FileSystem, Capacity, FreeSpace"

# Complete
"Information gathering complete." | Out-File -Append $output_file
