Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn  # fuer PowerShell ISE notwendig

$jetzt = get-date
$gestern = (Get-Date).AddDays(-1)

Get-MessageTrackingLog -ResultSize Unlimited -start $gestern -end $jetzt -EventId Fail

Get-MessageTrackingLog -ResultSize Unlimited -start $gestern -end $jetzt -Sender administrator@test.at

get-help Get-MessageTrackingLog -full



Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services


# Exchange HelthChecker.ps1 von Microsoft Downloadlink
Start-Process https://github.com/microsoft/CSS-Exchange/releases/latest/download/HealthChecker.ps1
Start-Process https://github.com/microsoft/CSS-Exchange/releases/ # weitere Skripte von MS