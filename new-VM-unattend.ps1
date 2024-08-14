# eine VM automatisch erstellen wo nur wenig abgefragt wird

# muss als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

$VMPfad     = "d:\vms"
$vmname     = "v-2025-02-en"
$Notes      = "Server 2025 Test-VM"
$cpu        = 4
$RAM        = 2048MB # dynamischer RAM
$Storage    = 40GB
$isopath    = "d:\iso\Server 2025 Preview\Windows_InsiderPreview_Server_vNext_en-us_26257.iso"
$SwitchName = "Default Switch"
$Nested     = 0 # mit 1 wird eine NESTED VM erstellt

$AdminPassword  = "asdf1234!" # fuer die unattend.xml, unbedingt nachher das Password aendern


#region Convert-WindowsImage download
# Download Convert-WindowsImage from MSLAB
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


# ISO Datei mounten damit diese in eine vhdx Datei konvertiert werden kann
$mount      = Mount-DiskImage -ImagePath $isopath
$mountLW    = ($mount | get-volume).DriveLetter    # Mount Laufwerk in Variable speichern
$sourcePath = $mountLW+":"+"\sources\install.wim"

Convert-WindowsImage -SourcePath $sourcePath -Edition 2 -VHDPath "$VMPfad\$vmname\vhdx\$vmname.vhdx" -SizeBytes $Storage -VHDFormat VHDX -DiskLayout UEFI

Dismount-DiskImage -ImagePath $isopath

New-VM -Name $vmname -MemoryStartupBytes $RAM -Path $VMpfad -Generation 2 -VHDPath $VMPfad\$vmname\vhdx\$vmname.vhdx
Set-VM -Name $vmname -ProcessorCount $cpu -Notes $notes
Set-VM -Name $vmname -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -AutomaticCheckpointsEnabled $false

# die NIC koennte man auch noch umbenennen
$NicName = (Get-VMNetworkAdapter -VMName $vmname).Name
# Rename-VMNetworkAdapter -Name $NicName -VMName $vmname -NewName Management
Connect-VMNetworkAdapter -Name $NicName -SwitchName $SwitchName -VMName $vmname


# Nested macht fast nur Sinn wenn in der VM ein Hyper-V installiert wird, daher sollte diese Rolle hier auch gleich eingefuegt werden
if ($Nested) {
    # nested VM aktivieren
    Set-VMNetworkAdapter -VMName $vmname -Name $NicName -MacAddressSpoofing On
    Set-VMProcessor -VMName $vmname -ExposeVirtualizationExtensions $true
    }


#region - unattend.xml Inhalt erstellen

$TimeZone       = "W. Europe Standard Time"

$fileContent =  @"
<?xml version='1.0' encoding='utf-8'?>
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <settings pass="offlineServicing">
   <component
        xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        language="neutral"
        name="Microsoft-Windows-PartitionManager"
        processorArchitecture="amd64"
        publicKeyToken="31bf3856ad364e35"
        versionScope="nonSxS"
        >
      <SanPolicy>1</SanPolicy>
    </component>
 </settings>
 <settings pass="specialize">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <ComputerName>$vmname</ComputerName>
        <RegisteredOwner>TestOwner</RegisteredOwner>
        <RegisteredOrganization>TestOrganisation</RegisteredOrganization>
        <ProductKey>MFY9F-XBN2F-TYFMP-CCV49-RMYVH</ProductKey>
    </component>
 </settings>
 <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <UserAccounts>
        <AdministratorPassword>
           <Value>$AdminPassword</Value>
           <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <SkipMachineOOBE>true</SkipMachineOOBE>
        <SkipUserOOBE>true</SkipUserOOBE>
      </OOBE>
      <TimeZone>$TimeZone</TimeZone>
      <ProductKey>MFY9F-XBN2F-TYFMP-CCV49-RMYVH</ProductKey>
    </component>
  </settings>
</unattend>

"@

#endregion

#region - unattend.xml Datei implementieren

# die Datei unattend.xml in den Ordner c:\windows\panther oder ins root kopieren

# der Mount-VHD Befehl hat den Nachteil dass kein Laufwerksbuchstabe angegeben werden kann - wie kann man den "Mountpoint" rausfinden?
# Mount-VHD -Path $VMPfad\$vmname\vhdx\$vmname.vhdx

New-Item -Path "$vmpfad\$vmname\loeschen" -ItemType Directory
dism /mount-image /ImageFile:$VMPfad\$vmname\vhdx\$vmname.vhdx /MountDir:"$vmpfad\$vmname\loeschen" /index:1

# unattend.xml jetzt schreiben

$unattendFile = New-Item "$vmpfad\$vmname\loeschen\Unattend.xml" -type File
Set-Content -path $unattendFile -value $fileContent

Write-Host -ForegroundColor Green "Die UNATTEND.XML wurde jetzt erzeugt."

dism /unmount-image /mountdir:"$vmpfad\$vmname\loeschen" /commit
Remove-Item -Path "$vmpfad\$vmname\loeschen"

# Dismount-VHD -Path $VMPfad\$vmname\vhdx\$vmname.vhdx

#endregion

Start-Sleep 5  # diese Zeitverzoegerung ist event nicht unbedingt notwendig. ausser der Dismount dauert zu lange und blockiert die vhdx Datei

Start-VM -VMName $vmname
Start-Sleep 30

# VM Console verbinden
VMconnect.exe localhost $vmname

# noch ein wenig Audio damit man merkt dass die VM schon laeuft
[Console]::Beep(900,1000) # Hoehe, Laenge