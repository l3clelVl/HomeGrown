# PowerShell script to gather information about Scheduled Tasks

# Create or append to the result file in the %USERNAME% directory
$output_file = "$env:USERPROFILE\Untitled-SchTask.txt"

# Add a timestamp to the output file
Get-Date | Out-File $output_file -Append

# Get a list of all scheduled tasks
"### List of All Scheduled Tasks ###" | Out-File $output_file -Append
schtasks /query /fo LIST | Out-File $output_file -Append

# Get details of each task including actions, triggers, and conditions
"### Detailed Information for Each Task ###" | Out-File $output_file -Append
$tasks = schtasks /query /fo CSV | ConvertFrom-Csv
foreach ($task in $tasks) {
    "Task Name: " + $task."TaskName" | Out-File $output_file -Append
    schtasks /query /tn $task."TaskName" /v /fo LIST | Out-File $output_file -Append
}

# Add a separator for the next execution
"#####################################################" | Out-File $output_file -Append
