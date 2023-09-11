# Set the destination directory to the current interactive user's profile
$destDir = $env:USERPROFILE

# Get the list of user directories from C:\Users
$userDirs = Get-ChildItem -Path "C:\Users" -Directory

# Iterate through each user directory
foreach ($userDir in $userDirs) {
    $historyPath = Join-Path $userDir.FullName "AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    
    # Check if the history file exists for the user
    if (Test-Path $historyPath) {
        # Copy the file to the destination directory and rename it
        $destPath = Join-Path $destDir ($userDir.Name + "_ConsoleHost_history.txt")
        Copy-Item -Path $historyPath -Destination $destPath
    }
}
