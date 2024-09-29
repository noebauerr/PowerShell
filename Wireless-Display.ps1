# WirelessDisplay auf Windows 11 installieren

#Requires -RunAsAdministrator

# Um die Funktion "Auf diesen PC projizieren" auf Windows 11 zu aktivieren
# mit Windows + K kann man sich dann mit dem Display verbinden

Add-WindowsCapability -Online -Name App.WirelessDisplay.Connect~~~~0.0.1.0

Get-WindowsCapability -Online | ? Name -Like "App.WirelessDisplay*"

Get-WindowsCapability -Online | ft -AutoSize