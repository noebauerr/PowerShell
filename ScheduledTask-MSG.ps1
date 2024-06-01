# Eine Erinnerung zeitgesteuert am Bildschirm anzeigen

$message = "Testnachricht"
$Time    = "5/28/2024 8:48 PM"

$Task = New-ScheduledTaskAction -Execute msg -Argument "* $Message"
$Trigger = New-ScheduledTaskTrigger -Once -At $Time
$Random = (Get-Random)

Register-ScheduledTask -Action $Task -Trigger $Trigger -TaskName "Reminder_$Random" -Description "Reminder"
