#############################################
#      Step 1 in a single line command:
#      $schtasksOutput = schtasks /query /fo LIST /v | Out-String; $filteredTasks = $schtasksOutput -split "`r`n`r`n" | Where-Object { ($_ -notlike "*Microsoft\Windows*") -and ($_ -notlike "*\System32\*") }; $filteredTasks

#      Step 2 in a single line command:
#      $taskName = "YourTaskNameHere"; $task = Get-ScheduledTask -TaskName $taskName; $task.Triggers | Where-Object { $_.Repetition } | ForEach-Object { [PSCustomObject]@{ 'TaskName' = $taskName; 'Duration' = $_.Repetition.Duration; 'Interval' = $_.Repetition.Interval; 'StopAtDurationEnd'= $_.Repetition.StopAtDurationEnd; } } | Format-Table


############################################


# Step 1 of 2
# Get detailed output from schtasks
$schtasksOutput = schtasks /query /fo LIST /v | Out-String

# Split the output into individual task details and filter
$filteredTasks = $schtasksOutput -split "`r`n`r`n" | Where-Object {
    ($_ -notlike "*Task To Run: C:\Windows\System32\*") -and 
    ($_ -notlike "*Task To Run: %windir%\System32\*")
}

# Output the filtered tasks
$filteredTasks



##############
#Step 2 of 2
#Once you find the TaskName to inspect for the schedule, plug into below "YourTaskNameHere"

$taskName = "YourTaskNameHere"  # replace with your task name
$task = Get-ScheduledTask -TaskName $taskName
$task.Triggers | Where-Object { $_.Repetition } | ForEach-Object {
    [PSCustomObject]@{
        'TaskName'         = $taskName;
        'Duration'         = $_.Repetition.Duration;
        'Interval'         = $_.Repetition.Interval;
        'StopAtDurationEnd'= $_.Repetition.StopAtDurationEnd;
    }
} | Format-Table


