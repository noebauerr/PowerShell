# PRTG Hyper-V Replikas werden abgefragt
# RSAT für Hyper-v muss installiert sein

$rep = Get-VMReplication -ComputerName HyperV1,HyperV2 | Select-Object VMname, state, health

if (($rep | ? health -ne 'Normal' | Select-Object VMname, state, health).count -eq 0) {
$x =[string]$rep.count+":OK"
Write-Output $x
exit 0
}
else {
$x =[string]$rep.count+":Fehler"
Write-Output $x
exit 2
}
