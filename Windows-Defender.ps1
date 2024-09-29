# Microsoft Defender Notizen

# grafisches Tool zur Konfiguration vom Defender
winget install DefenderUI

# Abfrage ob der Defender etwas gefunden hat
Get-MpThreat
Get-MpThreatDetection

Get-MpComputerStatus


# Offline Scan, Rechner wird gleich neu gestartet ohne Warnung
Start-MpWDOScan


Start-MpScan -ScanType FullScan # -asjob startet den Scan als Hintergrundjob

# Abbrechen des Scans als Administrator
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -Cancel



# um den Parameter ThrottleLimit auch bei manuellen Scans zu verwenden muss vorher folgender Befehl ausgefuehrt werden
# muss als Admin ausgefuehrt werden
Set-MpPreference -ThrottleForScheduledScanOnly $false
Start-MpScan -ScanType FullScan -ThrottleLimit 3


# CPU Drosselung im Leerlaufscan deaktivieren
Set-MpPreference -DisableCpuThrottleOnIdleScans $true

Get-MpPreference



Set-MpPreference -UILockdown:$true -ScanAvgCPULoadFactor 10 -RemediationScheduleDay Wednesday -RemediationScheduleTime 180
# ScanAvgCPULoadFactor in Prozent
# RemediationScheduleDay regelmaessiger Start an diesem Tag
# RemediationScheduleTime - Startzeit in Minuten ab Mitternacht, 180 = 3h00


# PUA Protection aktivieren (als Administrator)
Set-MpPreference -PUAProtection $true



# Antivirus testen
# Download Eicar Testvirus from www.eicar.com

Invoke-WebRequest https://secure.eicar.org/eicar.com -outfile .\Virenscannertest-einfache-com-Datei
Invoke-WebRequest https://secure.eicar.org/eicarcom2.zip -outfile .\Virenscannertest-gezippter-Testvirus

# Testvirus auf einem entfernten Rechner herunterladen
# $rechner = "rechner01"
# $cred = get-credential $rechner\admin
# Invoke-command -hostname $rechner -credentials $cred {invoke-webrequest https://secure.eicar.org/eicar.com -outfile c:\Virenscannertest}