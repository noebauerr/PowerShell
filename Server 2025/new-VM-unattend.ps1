# eine Server 2025 VM ohne Benutzerinteraktion installieren

# Hier liegt die aktuelle Version des Skripts
# https://github.com/noebauerr/PowerShell

# muss als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

param([string]$Dateiname)

$VMPfad     = "d:\vms"
$vmname     = "v-2025-04-de"
$Notes      = "Server 2025 Test-VM"
$cpu        = 4
$RAM        = 2048MB # statischer RAM
$Storage    = 40GB
$isopath    = "d:\iso\Server 2025\Win_Server_STD_CORE_2025_24H2.2_64Bit_German_December.ISO"
$SwitchName = "Default Switch"
$Nested     = 0 # mit 1 wird eine NESTED VM mit vorinstallierter Hyper-V Rolle erstellt

# $ip  = 192.168.1.10
# $snm = 255.255.255.0

# App die gleich mit Winget installiert werden soll - sinnvoll ?

Clear-Host
Write-Host -ForegroundColor Green "Skriptversion vom 22.12.2024`n"

$startzeit = get-date # fuer die Zeitmessung wie lange das Skript laeuft

# falls ein Dateiname uebergeben wurde dann die Variablen aus dieser Datei laden
if ($dateiname) {
    Write-Host -ForegroundColor Green "Dateiname wurde uebergeben: $Dateiname"
    . "$PSScriptRoot\$dateiname" # Datei ausfuehren und dadurch die default Variablen ueberschreiben
} else {
    Write-Host "Es wurde kein Dateiname an dieses Skript uebergeben, es werden die Variablen dieser Datei verwendet."
}

#region Passwort setzen
# unbedingt nachher das Passwort aendern da es im Klartext in der unattend.xml steht
$AdminPassword  = "asdf1234!"

# SecureString fuer das PW erstellen
$securePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
# jetzt noch ein PSCredential-Objekt mit Benutzername und SecureString-Passwort erstellen
$cred = New-Object System.Management.Automation.PSCredential ("Administrator", $securePassword)
#endregion


#region Voraussetzungen pruefen

# ob ISO Datei vorhanden ist
IF (Test-Path $isopath -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Green "ISO Datei existiert."}
 else {Write-Host -ForegroundColor Yellow "ACHTUNG ISO Datei wurde nicht gefunden!"; Start-Sleep 5; exit}

# sicher stellen dass der VM-Name noch nicht vorhanden ist
IF (Get-VM $vmname -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Yellow "Diese VM existiert schon! Bitte anderen VM Namen verwenden."; Start-Sleep 5; exit}
 else {Write-Host -ForegroundColor Green "VM-Name existiert noch nicht - weiter gehts."}

# ob VM DateiPfad existiert, denn sonst gab es schon mal eine VM mit diesem Namen und es bestehen noch Reste davon
IF (Test-Path "$VMPfad\$vmname\") {
    Write-Host -ForegroundColor Yellow "`nDer Pfad '$VMPfad\$vmname\' existiert schon und muss vorher bereinigt werden."; exit}

# testen ob der Switch auf diesem System existiert
IF (get-vmswitch $SwitchName) {
    Write-Host -ForegroundColor Green "Switch $Switchname existiert."
}
else {
    Write-Host -ForegroundColor Red "Switch $Switchname existiert auf diesem System nicht."; Start-Sleep 5; exit
}

#endregion


#region Convert-WindowsImage download

# vhdx Template Pfad anlegen, hier werden die *.vhdx Dateien als Template abgelegt
# Der Name x-vhdx-Template wurde gewaehlt damit der Ordner am Ende der VM Liste angelegt wird
If (Test-Path "$VMPfad\x-vhdx-Template\") {
    Write-Host "VHDX Template Pfad ist bereits vorhanden und muss nicht angelegt werden."
}
else { # Ordner wird jetzt angelegt
    New-Item "$VMPfad\x-vhdx-Template\" -ItemType Directory
}

# Download Convert-WindowsImage from MSLAB
    Write-host "Testing Convert-windowsimage presence"
    
    $convertWindowsImagePath = "$VMPfad\x-vhdx-Template\Convert-WindowsImage.ps1"
    
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
. "$VMPfad\x-vhdx-Template\Convert-WindowsImage.ps1"
#endregion 


# ISO Dateiname fuer Template Erzeugung "extrahieren"
$isoname = Split-Path $isopath -Leaf # LeafBase wuerde auch noch die .iso Endung entfernen, gibt es aber in PS 5.1 nicht
$isoname = $isoname.Split(".")       # Dateinamename teilen Name und .iso Endung
$isoname = $isoname[0]

# x-vhdx Template erzeugen
IF (Test-Path "$VMPfad\x-vhdx-Template\$IsoName.vhdx" -ErrorAction SilentlyContinue) {Write-Host -ForegroundColor Green "x-VHDX-Template $IsoName.vhdx existiert... und weiter gehts."}
 else {Write-Host -ForegroundColor Yellow "x-VHDX-Template $IsoName.vhdx existiert noch nicht und wird jetzt erzeugt."
  # ISO Datei mounten damit diese in eine vhdx Datei konvertiert werden kann
    $mount      = Mount-DiskImage -ImagePath $isopath
    $mountLW    = ($mount | get-volume).DriveLetter    # Mount Laufwerk in Variable speichern
    $sourcePath = $mountLW+":"+"\sources\install.wim"

    # SizeByte $storage ist fuer das Template nicht optimal, Groesse sollte ja erst spaeter pro VM definiert werden
    Convert-WindowsImage -SourcePath $sourcePath -Edition 2 -VHDPath "$VMPfad\x-vhdx-Template\$isoname.vhdx" -SizeBytes $Storage -VHDFormat VHDX -DiskLayout UEFI

    Dismount-DiskImage -ImagePath $isopath 
 }

# VM Ordner anlegen
New-Item "$VMPfad\$vmname\vhdx\" -ItemType Directory

# vorhandene vhdx Template Datei in den VM-Ordner\vhdx kopieren
Copy-Item "$VMPfad\x-vhdx-Template\$isoname.vhdx" -Destination "$VMPfad\$vmname\vhdx\$vmname.vhdx"

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
        <ProductKey>WWVGQ-PNHV9-B89P4-8GGM9-9HPQ4</ProductKey>
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
Start-Sleep 40

# VM Console verbinden
VMconnect.exe localhost $vmname


# warten bis die VM Online ist
do {
Write-Host -ForegroundColor Yellow "$vmname ist ueber WINRM noch nicht erreichbar."
Start-Sleep 4
} while (!(Test-WSMan -ComputerName $vmname -ErrorAction SilentlyContinue))


# noch ein wenig Audio damit man merkt dass die VM schon laeuft und bereit ist
[Console]::Beep(900,1000) # Hoehe, Laenge
# msg.exe * "VM laeuft."
Add-Type -AssemblyName System.Speech
$speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speaker.Speak("Die virtuelle Maschine ist jetzt installiert und du kannst dich anmelden.")


# RDP Zugriff aktivieren (dadurch funktioniert auch die "Erweitere Sitzung" in der Hyper-V Console
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Set-ItemProperty -Path 'HKLM:System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0}
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-UDP"}
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-TCP"}
Write-Host -ForegroundColor green "RDP Zugriff wurde aktiviert."


# Microsoft Updates aktivieren
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'AllowMUUpdateService' -Value 1}
Write-Host -ForegroundColor Green "Microsoft Updates wurden aktiviert."


# statische IP konfigurieren falls Variable gesetzt, damit die VM ueber RDP sofort erreicht werden kann.
if ($ip) {
    write-Host -ForegroundColor Yellow "es wird eine statische IP Adresse konfiguriert"
    }


# den Microsoft Edge Assistenten beim erstmaligen Start deaktivieren
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {New-Item -Path 'HKLM:Software\Policies\Microsoft\Edge\'}
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Set-ItemProperty -Path 'HKLM:Software\Policies\Microsoft\Edge' -Name "HideFirstRunExperience" -Value 1}
Write-Host -ForegroundColor Green "der nervige Microsoft Edge Assistent beim ersten Start wurde deaktiviert"


# die UNATTEND.XML aus dem Root loeschen da dort das urspruengliche Passwort steht
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Remove-Item -Path 'c:\unattend.xml' -force} 


# Laufwerk c umbenennen ($using wurde verwendet damit die lokale Variable im Skriptblock benutzt wird
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Set-Volume -DriveLetter C -NewFileSystemLabel $using:vmname}

# unnoetige Features deinstallieren
Write-Host -ForegroundColor Green "unnoetige Windows Features werden deinstalliert"
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Remove-WindowsFeature "XPS-Viewer","Wireless-Networking","WindowsAdminCenterSetup","System-DataArchiver"}

# und SNMP-WMI Feature installieren
Write-Host -ForegroundColor Green "Der SNMP Dienst wird installiert."
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Install-WindowsFeature SNMP-WMI-Provider}

if ($Nested){
Write-Host -ForegroundColor Yellow "RSAT-Tools fuer Hyper-V installieren bzw noch testen. Hyper-V wurde schon ins Offline Image eingebaut um die Neustarts zu sparen."
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Add-WindowsCapability -Online -Name Rsat.HyperV.Tools~~~~0.0.1.0}
}


# vorinstallierte Programme bereinigen - funktioniert aber nicht wenn der Admin noch nicht angemeldet war
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {mstsc /uninstall} # Remote Desktop Connection
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {Get-AppxPackage -AllUsers *feedback*|  Remove-AppxPackage}
# Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {DISM /Online /Remove-Capability /CapabilityName:Microsoft.Windows.MSPaint~~~~0.0.1.0}
# DISM moechte immer einen Neustart nach der Paint Deinstallation und da bleibt das Skript stehen !!!
# ich kenne derzeit aber keine andere Moeglichkeite Paint zu entfernen


# Microsoft BGInfo mit winget installieren
# C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\winget.exe - zu diesem Zeitpunkt leer - wieso ? Admin muss sich einmal anmelden
# Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {winget upgrade --all --accept-source-agreements}
# Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {winget.exe install --id Microsoft.Sysinternals.BGInfo}
# Write-Host -ForegroundColor Yellow "BGinfo sollte noch in den Autostart."

# Microsoft BGInfo mit winget installieren
Write-Host "Hier beginnt der BGinfo Teil der vom Github Copilot erzeugt wurde."
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {
    winget upgrade --all --accept-source-agreements
    winget.exe install --id Microsoft.Sysinternals.BGInfo

    # Pfad zur BGInfo-Anwendung
    $bginfoPath = "C:\Program Files\BGInfo\BGInfo.exe"
    # Pfad zum Autostart-Ordner des Administrators
    $startupFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup")
    # Pfad zur Verknuepfung
    $shortcutPath = [System.IO.Path]::Combine($startupFolder, "BGInfo.lnk")

    # Verknuepfung erstellen
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $bginfoPath
    $shortcut.Save()

    Write-Host -ForegroundColor Yellow "BGInfo wurde zum Autostart hinzugefuegt."
}

# Nachricht an den gerade angemeldeten Admin
Invoke-Command -VMName $vmname -Credential $cred -ScriptBlock {msg * "Der Server muss noch neu gestartet werden. und BGInfo in den Autostart."}
# Restart-Computer

# Neustart hier gleich automatisch durchfuehren falls kein Benutzer angemeldet ist?

# event noch das PS WIndows Update Modul installieren und Updates gleich durchfuehren.


# zusaetzliche lokale Benutzer zur Gruppe der lokalen Administratoren hinzufuegen (auf Sprachneutralitaet achten)
# wenn Domaenenbenutzer in zu den Admins hinzugefuegt werden sollen, dann wird zuerst ein Domainjoin benoetigt.


$Scriptdauer = (get-date) - $startzeit
Write-Host -ForegroundColor Cyan "`nDas Skript ist "($Scriptdauer).TotalSeconds" Sekunden gelaufen."