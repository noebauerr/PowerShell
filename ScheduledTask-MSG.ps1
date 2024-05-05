# Eine Erinnerung zeitgesteuert am Bildschirm anzeigen

$message = "Testnachricht"
$Time    = "8/15/2023 8:44 AM"


$Task = New-ScheduledTaskAction -Execute msg -Argument "* $Message"
$Trigger = New-ScheduledTaskTrigger -Once -At $Time
$Random = (Get-Random)
Register-ScheduledTask -Action $Task -Trigger $Trigger -TaskName "Reminder_$Random" -Description "Reminder"
