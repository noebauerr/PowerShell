# schnell eine neue VM von einer ISO Datei erstellen (ohne Hyper-V Schnellerstellung)

# eine Unattend Installation koennte man mit dem Tool ntlite erstellen
# Start-Process www.ntlite.com # kann die ISO Datei bearbeiten
# mit dem kostenlosen Tool anyburn kann man in die ISO Datei zB eine Unattend.xml kopieren

# Dieses Skript muss als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

$VMPfad  = "d:\vms"
$vmname  = "v-2025-01-de"
$Notes   = "Server 2025 Test-VM"
$cpu     = 4
$RAM     = 2048MB # dynamischer RAM
$Storage = 40GB
$isopath = "d:\iso\Server 2025 Preview\Windows_InsiderPreview_Server_vNext_de-de_26296.iso"
$Nested  = 0 # mit 1 wird eine NESTED VM erstellt


IF (Test-Path $isopath -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Green "ISO Datei existiert."}
 else {Write-Host -ForegroundColor Yellow "ACHTUNG ISO Datei wurde nicht gefunden!"}

IF (Get-VM $vmname -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Yellow "Diese VM existiert schon!"; Start-Sleep 15; exit}
 else {Write-Host -ForegroundColor Green "VM-Name existiert noch nicht - weiter gehts"}

New-VM -Name $vmname -MemoryStartupBytes $RAM -Path $VMPfad\$vmname -Generation 2 -NewVHDPath $VMPfad\$vmname\vhdx\$vmname.vhdx -NewVHDSizeBytes $Storage
Set-VM -Name $vmname -ProcessorCount $cpu -Notes $notes
Set-VM -Name $vmname -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -AutomaticCheckpointsEnabled $false

Add-VMDvdDrive -VMName $vmname -Path $isopath
$dvd = Get-VMDvdDrive -VMName $vmname
Set-VMFirmware $vmname -FirstBootDevice $dvd


# die NIC koennte man auch noch umbenennen
$NicName = (Get-VMNetworkAdapter -VMName $vmname).Name
# Rename-VMNetworkAdapter -Name $NicName -VMName $vmname -NewName Management
Connect-VMNetworkAdapter -Name $NicName -SwitchName "Default Switch" -VMName $vmname

if ($Nested) {
    # nested VM aktivieren
    Set-VMNetworkAdapter -VMName $vmname -Name $NicName -MacAddressSpoofing On
    Set-VMProcessor -VMName $vmname -ExposeVirtualizationExtensions $true
    }

Start-VM -VMName $vmname

# VM Console verbinden
VMconnect.exe localhost $vmname