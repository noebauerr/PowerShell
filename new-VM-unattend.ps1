# ein VM erstellen wo nur wenig abgefragt wird

# muss als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

$VMPfad  = "d:\vms"
$vmname  = "v-2025-01-de"
$Notes   = "Server 2025 Test-VM"
$cpu     = 4
$RAM     = 2048MB # dynamischer RAM
$Storage = 40GB
$isopath = "d:\iso\Server 2025 Preview\Windows_InsiderPreview_Server_vNext_de-de_26244.iso"
$Nested  = 0 # mit 1 wird eine NESTED VM erstellt

#region 
# Download convert-windowsimage from MSLAB
    Write-host "Testing Convert-windowsimage presence"
    $convertWindowsImagePath = "$VMPfad\Convert-WindowsImage.ps1"
    
    If (Test-Path -Path $convertWindowsImagePath) {
        Write-Host -ForegroundColor Green "`t Convert-windowsimage.ps1 is present, skipping download"
    } else {
        Write-Host "`t Downloading Convert-WindowsImage"
        try {
            Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/microsoft/MSLab/releases/download/$mslabVersion/Convert-WindowsImage.ps1" -OutFile $convertWindowsImagePath
        } catch {
            try {
                Write-Host "Download Convert-windowsimage.ps1 failed with $($_.Exception.Message), trying master branch now"
                Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/microsoft/MSLab/master/Tools/Convert-WindowsImage.ps1" -OutFile $convertWindowsImagePath
            } catch {
                Write-Host -ForegroundColor Red "`t Failed to download Convert-WindowsImage.ps1!"
            }
        }
    }
. $VMPfad\Convert-WindowsImage.ps1
#endregion

IF (Test-Path $isopath -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Green "ISO Datei existiert."}
 else {Write-Host -ForegroundColor Yellow "ACHTUNG ISO Datei wurde nicht gefunden!"}

IF (Get-VM $vmname -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Yellow "Diese VM existiert schon!"; Start-Sleep 15; exit}
 else {Write-Host -ForegroundColor Green "VM-Name existiert noch nicht - weiter gehts"}


# hier muss vorher die ISO Datei gemounted werden
# https://www.winhelponline.com/blog/mount-iso-using-powershell/?utm_content=cmp-true

$mount   = Mount-DiskImage -ImagePath $isopath  # welcher Laufwerksbuchstabe ?
$mountLW = ($mount | get-volume).DriveLetter
$sourcePath = $mountLW+":"+"\sources\install.wim"

Convert-WindowsImage -SourcePath $sourcePath -Edition 2 -VHDPath "$VMPfad\$vmname\vhdx\$vmname.vhdx" -SizeBytes $Storage -VHDFormat VHDX -DiskLayout UEFI

Dismount-DiskImage -ImagePath $isopath


New-VM -Name $vmname -MemoryStartupBytes $RAM -Path $VMpfad\$vmname -Generation 2 -VHDPath $VMPfad\$vmname\vhdx\$vmname.vhdx
Set-VM -Name $vmname -ProcessorCount $cpu -Notes $notes
Set-VM -Name $vmname -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -AutomaticCheckpointsEnabled $false


# die NIC koennte man auch noch umbenennen
$NicName = (Get-VMNetworkAdapter -VMName $vmname).Name
# Rename-VMNetworkAdapter -Name $NicName -VMName $vmname -NewName Management
Connect-VMNetworkAdapter -Name $NicName -SwitchName "Default Switch" -VMName $vmname

if ($Nested) {
    # nested VM aktivieren
    Set-VMNetworkAdapter -VMName $vmname -Name $NicName -MacAddressSpoofing On
    Set-VMProcessor -VMName $vmname -ExposeVirtualizationExtensions $true
    }



# jetzt noch autounattend.xml in die vhdx Datei implementieren
Write-Host -ForegroundColor Yellow "jetzt noch autounattend.xml in die vhdx Datei implementieren"


Start-VM -VMName $vmname

# VM Console verbinden
VMconnect.exe localhost $vmname