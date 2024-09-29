# Up und Downloadspeed messen

$lokal  = "c:\temp\loeschen.zip"
$server = "\\v-server\iso\loeschen.zip"

write-Host "Start Uploadtest"
$uploaddauer = Measure-Command {copy-item $lokal $server -Force}
$uploaddauer.TotalSeconds
Write-host "Upload fertig`n"

write-host "Start Downloadtest"
$downloaddauer = Measure-Command {copy-item $server c:\temp\download.loeschen -Force}
$downloaddauer.TotalSeconds
Remove-Item c:\temp\download.loeschen
Write-Host "Downloadtest fertig`n"

Write-Host "Uploaddauer in Sekunden:   " $uploaddauer.TotalSeconds
Write-Host "Downloaddauer in Sekunden: " $downloaddauer.TotalSeconds
