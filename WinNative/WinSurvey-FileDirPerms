# PowerShell Script to gather File and Directory Permissions

# Define the output file path
$output_file = "$env:USERPROFILE\Untitled-FileDirPerm.txt"

# Function to append data to the output file
function AppendToFile($data) {
    Add-Content -Path $output_file -Value $data
}

# Get contents of all user directories
$data = Get-ChildItem -Path 'C:\Users' -Recurse
AppendToFile "`nContents of C:\Users:`n$data"

# List all shared directories on the system
$data = net share
AppendToFile "`nShared directories:`n$data"

# Check permissions for all shared directories
$shared_dirs = (net share) | ForEach-Object {
    if ($_ -like "*C:\\*") {
        $dir = $_.Split()[0]
        Get-Acl -Path $dir | Format-List | Out-String
    }
}
AppendToFile "`nPermissions for shared directories:`n$shared_dirs"

# Check permissions for user directories
$user_dirs = Get-ChildItem -Path 'C:\Users' -Directory
foreach ($dir in $user_dirs) {
    $data = Get-Acl -Path $dir.FullName | Format-List | Out-String
    AppendToFile "`nPermissions for directory $($dir.FullName):`n$data"
}

# End of script
