Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn  # für PowerShell ISE notwendig

$jetzt = get-date
$gestern = (Get-Date).AddDays(-1)

Get-MessageTrackingLog -ResultSize Unlimited -start $gestern -end $jetzt -EventId Fail

Get-MessageTrackingLog -ResultSize Unlimited -start $gestern -end $jetzt -Sender administrator@test.at

get-help Get-MessageTrackingLog -full
