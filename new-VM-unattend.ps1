# eine VM automatisch erstellen wo nur wenig abgefragt wird
# hauptsaechlich mit Server 2025 getestet

param([string]$Dateiname)

# muss als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

$VMPfad     = "d:\vms"
$vmname     = "v-2025-01-en"
$Notes      = "Server 2025 Test-VM"
$cpu        = 4
$RAM        = 2048MB # dynamischer RAM
$Storage    = 40GB
$isopath    = "d:\iso\Server 2025 Preview\Windows_InsiderPreview_Server_vNext_en-us_26304.iso"
$SwitchName = "Default Switch"
$Nested     = 0 # mit 1 wird eine NESTED VM mit vorinstallierter Hyper-V Rolle erstellt

# $ip  = 192.168.1.10
# $snm = 255.255.255.0

# App die gleich mit Winget installiert werden soll - sinnvoll ?


# falls ein Dateiname uebergeben wurde dann die Variablen aus dieser Datei laden
if ($dateiname) {
    Write-Host -ForegroundColor Green "Dateiname wurde �bergeben: $Dateiname"
    . "$PSScriptRoot\$dateiname" # Datei ausfuehren und dadurch die default Variablen ueberschreiben
} else {
    Write-Host "Es wurde kein Dateiname uebergeben, es werden die Variablen dieser Datei verwendet."
}


# unbedingt nachher das Passwort aendern da es im Klartext in der unattend.xml steht
$AdminPassword  = "asdf1234!"

# SecureString fuer das PW erstellen
$securePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
# jetzt noch ein PSCredential-Objekt mit Benutzername und SecureString-Passwort erstellen
$cred = New-Object System.Management.Automation.PSCredential ("Administrator", $securePassword)


$startzeit = get-date # fuer die Zeitmessung wie lange das Skript laeuft

IF (Get-VM $vmname -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Yellow "Diese VM existiert schon! Bitte anderen VM Namen verwenden."; Start-Sleep 5; exit}
 else {Write-Host -ForegroundColor Green "VM-Name existiert noch nicht - weiter gehts."}

IF (Test-Path $isopath -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Green "ISO Datei existiert."}
 else {Write-Host -ForegroundColor Yellow "ACHTUNG ISO Datei wurde nicht gefunden!"}


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


# testen ob vhdx Template schon existiert, falls ja dann nicht mehr neu erzeugen
$isoname = Split-Path $isopath -Leaf # LeafBase wuerde auch noch die .iso Endung entfernen, gibt es aber in PS 5.1 nicht
$isoname = $isoname.Split(".")       # Dateinamename teilen Name und .iso Endung
$isoname = $isoname[0]

IF (Test-Path "$VMPfad\vhdx-Template\$IsoName.vhdx" -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Green "VHDX-Template $IsoName.vhdx existiert... und weiter gehts."}
 else {Write-Host -ForegroundColor Yellow "VHDX-Template $IsoName.vhdx existiert noch nicht und wird jetzt erzeugt."
  # ISO Datei mounten damit diese in eine vhdx Datei konvertiert werden kann
    $mount      = Mount-DiskImage -ImagePath $isopath
    $mountLW    = ($mount | get-volume).DriveLetter    # Mount Laufwerk in Variable speichern
    $sourcePath = $mountLW+":"+"\sources\install.wim"

    # SizeByte $storage ist fuer das Template nicht optimal, groesse sollte ja erst spaeter pro vm definiert werden
    Convert-WindowsImage -SourcePath $sourcePath -Edition 2 -VHDPath "$VMPfad\vhdx-Template\$isoname.vhdx" -SizeBytes $Storage -VHDFormat VHDX -DiskLayout UEFI

    Dismount-DiskImage -ImagePath $isopath 
 }


New-Item "$VMPfad\$vmname\vhdx\" -ItemType Directory

Copy-Item "$VMPfad\vhdx-Template\$isoname.vhdx" -Destination "$VMPfad\$vmname\vhdx\$vmname.vhdx"

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
        <ProtectYourPC>3</ProtectYourPC>
      </OOBE>
      <TimeZone>$TimeZone</TimeZone>
      <ProductKey>MFY9F-XBN2F-TYFMP-CCV49-RMYVH</ProductKey>
    </component>
  </settings>
</unattend>

"@

#endregion

#region - unattend.xml Datei implementieren und VHDX bearbeiten

# die Datei unattend.xml in den Ordner c:\windows\panther oder ins root kopieren

# der Mount-VHD Befehl hat den Nachteil dass kein Laufwerksbuchstabe angegeben werden kann - wie kann man den "Mountpoint" rausfinden?
# Mount-VHD -Path $VMPfad\$vmname\vhdx\$vmname.vhdx

New-Item -Path "$vmpfad\$vmname\loeschen" -ItemType Directory
dism /mount-image /ImageFile:$VMPfad\$vmname\vhdx\$vmname.vhdx /MountDir:"$vmpfad\$vmname\loeschen" /index:1

# unattend.xml jetzt schreiben

$unattendFile = New-Item "$vmpfad\$vmname\loeschen\Unattend.xml" -type File
Set-Content -path $unattendFile -value $fileContent

Write-Host -ForegroundColor Green "Die UNATTEND.XML wurde jetzt erzeugt."


# if nested dann gleich die Rolle Hyper-V im DISM installieren um sich Neustarts zu sparen
# event noch abfragen ob auch wirklich alle Voraussetzungen fuer Nested erfuellt sind, zB RAM
If ($nested){
    # dism /image:"$vmpfad\$vmname\loeschen" /enable-feature:Microsoft-Hyper-V /ALL
    Enable-WindowsOptionalFeature -Path "$vmpfad\$vmname\loeschen" -FeatureName Microsoft-Hyper-V
    # RSAT fuer Hyper-V konnte ich mit diesem Befehl nicht installieren
}


Dism /image:"$vmpfad\$vmname\loeschen" /Set-SysLocale:de-de   # fuer Non-Unicode
Dism /image:"$vmpfad\$vmname\loeschen" /Set-UserLocale:de-de  # fuer Zeit, Datum, Waehrungs und Nummernformatierung
Dism /image:"$vmpfad\$vmname\loeschen" /Set-InputLocale:de-de # fuer ein deutsches Tastaturlayout
Dism /image:"$vmpfad\$vmname\loeschen" /Set-TimeZone:"W. Europe Standard Time"

Dism /unmount-image /mountdir:"$vmpfad\$vmname\loeschen" /commit
Remove-Item -Path "$vmpfad\$vmname\loeschen"

# Dismount-VHD -Path $VMPfad\$vmname\vhdx\$vmname.vhdx

#endregion

Start-Sleep 5  # diese Zeitverzoegerung ist event nicht unbedingt notwendig. ausser der Dismount dauert zu lange und blockiert die vhdx Datei

Start-VM -VMName $vmname
Write-Host -ForegroundColor Green "Die VM $vmname wurde gestartet."
Start-Sleep 30

# VM Console verbinden
VMconnect.exe localhost $vmname


# warten bis die VM Online ist
do {
Write-Host -ForegroundColor Yellow "$vmname ist noch nicht erreichbar."
Start-Sleep 3
} while (!(Test-WSMan -ComputerName $vmname -ErrorAction SilentlyContinue))


# noch ein wenig Audio damit man merkt dass die VM schon laeuft und bereit ist
[Console]::Beep(900,1000) # Hoehe, Laenge
# msg.exe * "VM laeuft."
Add-Type -AssemblyName System.Speech
$speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speaker.Speak("Die virtuelle Maschine $vmname ist jetzt installiert und du kannst dich anmelden.")


# RDP Zugriff aktivieren
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Set-ItemProperty -Path 'HKLM:System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0}
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-UDP"}
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-TCP"}
Write-Host -ForegroundColor green "RDP Zugriff wurde aktiviert."


# Microsoft Updates aktivieren
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'AllowMUUpdateService' -Value 1}


# statische IP konfigurieren falls Variable gesetzt, damit die VM ueber RDP sofort erreicht werden kann.
if ($ip) {
    write-Host -ForegroundColor Yellow "es wird eine statische IP Adresse konfiguriert"
    }

# den Microsoft Edge Assistenten beim erstmaligen Start deaktivieren
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {New-Item -Path 'HKLM:Software\Policies\Microsoft\Edge\'}
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Set-ItemProperty -Path 'HKLM:Software\Policies\Microsoft\Edge' -Name "HideFirstRunExperience" -Value 1}
Write-Host -ForegroundColor Green "der nervige Microsoft Edge Assistent beim ersten Start wurde deaktiviert"

# zusaetzliche lokale Benutzer zur Gruppe der lokalen Administratoren hinzufuegen (auf Sprachneutralitaet achten)
# wenn Domaenenbenutzer in zu den Admins hinzugefuegt werden sollen, dann wird zuerst ein Domainjoin benoetigt.


$Scriptdauer = (get-date) - $startzeit
Write-Host -ForegroundColor Cyan "`nDas Skript ist "($Scriptdauer).TotalSeconds" Sekunden gelaufen."