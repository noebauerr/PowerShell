# PowerShell Module zum Installieren von Microsoft Updates

# zur Installation des PackageProviders und PS-Module sind lokale Adminrechte notwendig
Install-PackageProvider -Name nuget -Force
Install-Module -Name pswindowsupdate -force

# als Admin
Get-WindowsUpdate -MicrosoftUpdate
Install-WindowsUpdate -Install # mit neustart
Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot
Install-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File c:\updatelog.txt -Force
Install-WindowsUpdate -MicrosoftUpdate

# auch als User moeglich
get-command -Module pswindowsupdate
Get-WindowsUpdateLog
Get-Help Get-WindowsUpdate -Detailed

# Zusatzinfos:
Start-Process https://www.windowspro.de/wolfgang-sommergut/windows-updates-powershell-pswindowsupdate-auflisten-herunterladen-installieren
Start-Process https://github.com/mgajda83/PSWindowsUpdate


#region REMOTE (macht Probleme)

# hier muss ich noch eine Loesung finden, da das Modul remote nicht funktioniert.

$Server = "v-server"
Invoke-Command -ComputerName $Server {get-command -Module pswindowsupdate}
Invoke-Command -ComputerName $Server {Get-WindowsUpdate -MicrosoftUpdate}
# funktioniert folgender Befehl remote?
Invoke-Command -ComputerName $Server {Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot}
Get-WindowsUpdate -verbose -computer $Server -AcceptAll -Install -AutoReboot

Enable-WURemoting # koennte die Loesung sein

$cred = Get-Credential -UserName Domaene\Administrator
Invoke-Command -ComputerName $Server -Credential $cred {
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot
}

#endregion