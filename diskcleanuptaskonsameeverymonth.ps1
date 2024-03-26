# Define the PowerShell script to run disk cleanup silently
$scriptBlock = {
    # Perform disk cleanup silently
    $cleanupResult = Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1" -PassThru -NoNewWindow -Wait

    # Check if disk cleanup completed successfully
    if ($cleanupResult.ExitCode -eq 0) {
        Write-Host "Disk cleanup completed successfully."
    } else {
        Write-Host "Disk cleanup encountered an error. Exit code: $($cleanupResult.ExitCode)"
    }
}

# Get the current date
$currentDate = Get-Date

# Calculate the next run date as the same date next month
$nextRunDate = $currentDate.AddMonths(1)

# Calculate the time of day to run the task
$runTime = "23:00"

# Combine the date and time
$nextRunDateTime = [datetime]::ParseExact("$($nextRunDate.ToString('yyyy-MM-dd')) $runTime", "yyyy-MM-dd HH:mm", $null)

# Create a new scheduled task trigger to run once on the calculated date and time
$trigger = New-ScheduledTaskTrigger -Once -At $nextRunDateTime

# Create a new scheduled task action to run the PowerShell script
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -Command &{ $scriptBlock }"

# Specify the task name and description
$taskName = "DiskCleanupTask"
$taskDescription = "Run Disk Cleanup monthly"

# Register the task with Task Scheduler
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest -Force

Write-Host "Task '$taskName' added to run Disk Cleanup monthly."
