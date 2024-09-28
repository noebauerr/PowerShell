# Version vom September 2024

# Auflistung der Betriebssystem Builds aller AD Computer Objekte
# um alte nicht supportete Versionen zu identifizieren
# am einfachsten auf einem Domain Controller starten, da sind die passenden PS Module schon installiert

# damit es auch von einer Windows 10 Workstation geht muessen zuerst die RSAT Tools installiert werden (als Admin)
Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State
# Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Get-WindowsCapability -Name "RSat.ActiveDirectory*" -Online | Add-WindowsCapability -Online


# Windows 10 Build - start-process https://support.microsoft.com/de-at/help/13853/windows-lifecycle-fact-sheet
# 19044 - 21H2 - EOS Juni 2023,    Enterprise 11. Juni 2024
# 19045 - 22H2 - EOS Oktober 2025, Enterprise 14.Oktober 2025


# Windows 11 Build (Pro 24 Monate, Enterprise 36 Monate)
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-11-home-and-pro             # Win 11 Pro
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-11-enterprise-and-education # Win 11 Enterprise
# 22000 - 21H2 - EOS Oktober 2023,  Enterprise Oktober 2024 
# 22621 - 22H2 - EOS Oktober 2024,  Enterprise Oktober 2025
# 22631 - 23H2 - EOS November 2025, Enterprise November 2026
# 26100?? - 24H2 - EOS


# Server OS Supportende
# 2016      12.01.2027
# 2019       9.01.2029
# 2022      14.10.2031
# 2025


# Office End of Support
# 2013  14.April 2023
# 2016  14.Oktober 2025
# 2019  14.Oktober 2025
# 2021  13.Oktober 2026 (Mainstream End Date = Extended End Date)
# 2024


# Betriebssystem Versionen auflisten
Get-ADComputer -Filter * -Property * | sort operatingsystemversion, operatingsystem | Format-Table Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion -Wrap –Auto # You can replace [-Filter *] by [-Filter {OperatingSystem -Like "Windows Server*"}

# Betriebssystem Versionen auflisten und als "Gridview" ausgeben, hier kann man besser filtern und sortieren
Get-ADComputer -Filter * -Property * | sort operatingsystem, operatingsystemversion | select Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion | Out-GridView
# Get-ADComputer -Filter * -Property * | sort operatingsystem, operatingsystemversion | select Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion | Out-File c:\PS\OS-Liste.txt

# dieses Script liegt auf Github und kann mit folgendem Befehl heruntergeladen werden
# Invoke-WebRequest "https://raw.githubusercontent.com/noebauerr/PowerShell/master/AD-OS-Versionen.ps1" -OutFile "AD-OS-Versionen.ps1"