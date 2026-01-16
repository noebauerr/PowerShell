# Version vom September 2024

# Auflistung der Betriebssystem Builds aller AD Computer Objekte
# um alte nicht supportete Versionen zu identifizieren
# am einfachsten auf einem Domain Controller starten, da sind die passenden PS Module schon installiert

# damit es auch von einer Windows 10 Workstation geht muessen zuerst die RSAT Tools installiert werden (als Admin)
Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State
# Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Get-WindowsCapability -Name "RSat.ActiveDirectory*" -Online | Add-WindowsCapability -Online


# Windows 10 Build - start-process https://support.microsoft.com/de-at/help/13853/windows-lifecycle-fact-sheet
# Microsoft PC Integritätsprüfung: https://aka.ms/GetPCHealthCheckApp, WindowsPCHealthCheckSetup.msi
Start-Process https://www.microsoft.com/de-de/windows/extended-security-updates
# 19044 - 21H2 - EOS Juni 2023,    Enterprise 11. Juni 2024
# 19045 - 22H2 - EOS Oktober 2025, Enterprise 14.Oktober 2025


# Windows 11 Build (Pro 24 Monate, Enterprise 36 Monate)
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-11-home-and-pro             # Win 11 Pro
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-11-enterprise-and-education # Win 11 Enterprise
# 22621 - 22H2 - EOS Oktober 2024,  Enterprise Oktober 2025
# 22631 - 23H2 - EOS November 2025, Enterprise November 2026
# 26100 - 24H2 - EOS Oktober 2026,  Enterprise Oktober 2027
# 26200 - 25H2 - EOS Oktober 2027,  Enterprise Oktober 2028


# Windows Server OS Supportende
# 2016      12.01.2027 - Mainstream End Date 11.1.2022
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-server-2016

# 2019       9.01.2029 - Mainstream End Date 9.1.2024
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-server-2019

# 2022      14.10.2031 - Mainstream End Date 13.10.2026
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-server-2022

# 2025      10.10.2034 - Mainstream End Date 13.11.2029
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/windows-server-2025


# Office End of Support
# 2016  14.Oktober 2025
# 2019  14.Oktober 2025
# 2021  13.Oktober 2026 (Mainstream End Date = Extended End Date)
# 2024   9.Oktober 2029


# SQL Server End of Support
# 2016  14.Juli 2026
Start-Process https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2016

# 2019   8.1.2030 - Mainstream End Date 28.2.2025)


# Betriebssystem Versionen auflisten
Get-ADComputer -Filter * -Property * | sort operatingsystemversion, operatingsystem | Format-Table Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion -Wrap â€“Auto # You can replace [-Filter *] by [-Filter {OperatingSystem -Like "Windows Server*"}

# Betriebssystem Versionen auflisten und als "Gridview" ausgeben, hier kann man besser filtern und sortieren
Get-ADComputer -Filter * -Property * | sort operatingsystem, operatingsystemversion | select Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion | Out-GridView
# Get-ADComputer -Filter * -Property * | sort operatingsystem, operatingsystemversion | select Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion | Out-File c:\PS\OS-Liste.txt

# dieses Script liegt auf Github und kann mit folgendem Befehl heruntergeladen werden
# Invoke-WebRequest "https://raw.githubusercontent.com/noebauerr/PowerShell/master/AD-OS-Versionen.ps1" -OutFile "AD-OS-Versionen.ps1"