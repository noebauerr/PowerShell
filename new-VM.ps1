# schnell eine neue VM erstellen (ohne Hyper-V Schnellerstellung)

# muss als Administrator ausgefuehrt werden

$vmname  = "v-2022-01-de"
$cpu     = 4
$RAM     = 2048
$Storage = 40GB

$isopath = "c:\iso\server 2022 preview\Windows_InsiderPreview_Server_vNext_en-us_20339.iso"

# optionale Parameter fuer spaeter
# $vhdxpath = "Windows_InsiderPreview_ServerStandard_en-us_VHDX_20339.vhdx"
# $nested = $true   # nested Hyper-v aktivieren

New-VM -Name $vmname