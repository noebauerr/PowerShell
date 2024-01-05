# Windows 11 Widgets deinstallieren bzw wieder installieren

# In der PowerShell als Admin
Get-AppxPackage *WebExperience* | Remove-AppxPackage
# event mit Y bestaetigen
# es geht auch ohne PowerShell
# winget uninstall --id 9MSSGKG348SP


# zum Installieren folgenden Befehl auf der Kommandozeile starten
winget install --id 9MSSGKG348SP
