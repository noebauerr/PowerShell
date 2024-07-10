# ein VM erstellen wo nur wenig abgefragt wird

# muss als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

$VMPfad  = "d:\vms"
$vmname  = "v-2025-05-en"
$Notes   = "Server 2025 Test-VM"
$cpu     = 4
$RAM     = 2048MB # dynamischer RAM
$Storage = 40GB
$isopath = "d:\iso\Server 2025 Preview\Windows_InsiderPreview_Server_vNext_en-us_26244.iso"
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


$mount      = Mount-DiskImage -ImagePath $isopath  # welcher Laufwerksbuchstabe ?
$mountLW    = ($mount | get-volume).DriveLetter
$sourcePath = $mountLW+":"+"\sources\install.wim"

Convert-WindowsImage -SourcePath $sourcePath -Edition 2 -VHDPath "$VMPfad\$vmname\vhdx\$vmname.vhdx" -SizeBytes $Storage -VHDFormat VHDX -DiskLayout UEFI

Dismount-DiskImage -ImagePath $isopath

New-VM -Name $vmname -MemoryStartupBytes $RAM -Path $VMpfad -Generation 2 -VHDPath $VMPfad\$vmname\vhdx\$vmname.vhdx
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

#region - unattend.xml Datei implementieren

# die Datei unattend.xml in den Ordner c:\windows\panther kopieren

# der Mount-VHD Befehl hat den Nachteil dass kein Laufwerksbuchstabe angegeben werden kann - wie kann man den "Mountpoint" rausfinden?
# Mount-VHD -Path $VMPfad\$vmname\vhdx\$vmname.vhdx

New-Item -Path "$vmpfad\$vmname\loeschen" -ItemType Directory
dism /mount-image /ImageFile:$VMPfad\$vmname\vhdx\$vmname.vhdx /MountDir:"$vmpfad\$vmname\loeschen" /index:1

Write-Host "die VHDX wurde gemountet - "$vmpfad\$vmname\loeschen" "
Write-Host "event kann man jetzt einen Tools Ordner anlegen und zB ein winget.ps1 skript reinkopieren"

# hier den Kopierbefehl reinschreiben
Write-Host -ForegroundColor Yellow "jetzt die unattend.xml nach c:\ oder c:\windows\panther kopieren."

pause

dism /unmount-image /mountdir:"$vmpfad\$vmname\loeschen" /commit
Remove-Item -Path "$vmpfad\$vmname\loeschen"

# Dismount-VHD -Path $VMPfad\$vmname\vhdx\$vmname.vhdx

#endregion

Start-Sleep 5  # diese Zeitverzoegerung ist event nicht unbedingt notwendig. ausser der dismount dauert zu lange und blockiert die vhdx Datei

Start-VM -VMName $vmname

# VM Console verbinden
VMconnect.exe localhost $vmname