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

# optionale Parameter fuer spaeter
# $vhdxpath = "Windows_InsiderPreview_ServerStandard_en-us_VHDX_20339.vhdx"

New-VM -Name $vmname -MemoryStartupBytes $RAM -Path $pfad\$vmname -Generation 2
Set-VM -Name $vmname -ProcessorCount $cpu -Notes $notes
Set-VM -Name $vmname -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -AutomaticCheckpointsEnabled $false
