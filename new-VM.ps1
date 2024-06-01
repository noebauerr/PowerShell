# schnell eine neue VM erstellen (ohne Hyper-V Schnellerstellung)

# muss als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

$Pfad    = "d:\vms"
$vmname  = "v-2025-01-de"
$cpu     = 4
$RAM     = 2048MB # dynamischer RAM
$Storage = 40GB
$Notes   = "Server 2025 Test-VM"

$isopath = "d:\iso\Server 2025 Preview\Windows_InsiderPreview_Server_vNext_de-de_26212.iso"

IF (Test-Path $isopath) {Write-Host -ForegroundColor Green "ISO Datei existiert."}
 else {Write-Host -ForegroundColor Yellow "ACHTUNG ISO Datei wurde nicht gefunden!"}

# optionale Parameter fuer spaeter
# $vhdxpath = "Windows_InsiderPreview_ServerStandard_en-us_VHDX_20339.vhdx"

IF (Get-VM $vmname) {Write-Host -ForegroundColor Yellow "Diese VM existiert schon!"; Start-Sleep 15; exit}
 else {Write-Host -ForegroundColor Green "VM-Name existiert noch nicht - weiter gehts"}

New-VM -Name $vmname -MemoryStartupBytes $RAM -Path $pfad\$vmname -Generation 2 -NewVHDPath $Pfad\$vmname\vhdx\$vmname.vhdx -NewVHDSizeBytes $Storage
Set-VM -Name $vmname -ProcessorCount $cpu -Notes $notes
Set-VM -Name $vmname -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -AutomaticCheckpointsEnabled $false

# DVD Laufwerk einhängen und Startreihenfolge ändern

# VM starten

# VM Console verbinden