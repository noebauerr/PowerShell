start-process https://github.com/noebauerr/PowerShell

winget upgrade --all --accept-source-agreements # accept-source-agreements ist wichtig da winget sonst nicht startet

# UniGetUI (war vorher wingetUI)
winget search UniGetUI
winget install --id MartiCliment.UniGetUI

# DefenderUI
winget search DefenderUI
winget install --id XP8JZNXWS6FB30 --accept-package-agreements

# Remotezeugs (RDP...)
winget install mRemoteNG
winget install --id Microsoft.Sysinternals.RDCMan       # sysinternals rdcman, wohin wird diese Software installiert?
winget install 9PNMNF92JNFP --accept-package-agreements # 1Remote (PRemoteM) - mstsc remote desktop
winget install "royal ts" --source msstore --accept-package-agreements # benutzt Carsten Rachfahl

winget install "Microsoft .NET Windows Desktop Runtime 8.0" # wird von devolutions benoetigt
winget install "devolutions remote desktop manager" --accept-package-agreements


# ISO bearbeiten und unattend Zeugs
winget search anyBurn   # zB Unattend.xml direkt auf die ISO schreiben
winget search "ntlite"  # Win Installationsmedium anpassen und Service-Packs, Treiber und Systemkomponenten anpassen

# Benchmark
winget install cinebench --accept-package-agreements # CPU Benchmark
winget install CrystalDiskMark

# treesize free wird auf Servern nicht mehr unterstuetzt
winget install "Treesize Free" --source msstore --accept-package-agreements
# welches alternative Tool ist gut?
winget install windirstat
winget install wiztree
winget install SpaceSniffer

# Github Desktop
winget install "Github Desktop"

# Netzwerk IP-Scanner und Sniffer
winget install Famatech.AdvancedIPScanner
winget install Wireshark

# bootfaehige Windows USB Sticks erstellen
winget install --id Rufus.Rufus
winget install Ventoy

# Microsoft Zeugs
winget install "Microsoft Loop"  --accept-package-agreements
winget install "Microsoft Teams" --id Microsoft.Teams --source winget
winget install onenote --accept-package-agreements
winget install Microsoft.PowerShell  # powershell 7.x

# Sysinternals Suite
winget install --id Microsoft.Sysinternals --accept-package-agreements

winget install --id Microsoft.Sysinternals.ProcessExplorer
winget install --id Microsoft.Sysinternals.Autoruns
winget install --id Microsoft.Sysinternals.BGInfo
start-process bginfo "/timer:0 /all /accepteula"

# Windows Admin Center
winget install "Windows Admin Center"

# Lockoutstatus.exe von Microsoft
Start-Process https://www.microsoft.com/en-gb/download/details.aspx?id=15201
Start-Process https://download.microsoft.com/download/c/0/4/c0472410-b4c2-4aef-89d2-e7c708dfc225/lockoutstatus.msi

# Signal Messenger fuer Windows funktioniert auf Server 2025 Preview nicht
winget install --id OpenWhisperSystems.Signal

# Winget Parameter --silent --accept-source-agreements damit nicht immer nachgefragt wird



# PowerShell Modul fuer Winget
#Requires -RunAsAdministrator
Install-Module -Name Microsoft.WinGet.Client # -conform? -force? # laedt zuerst NuGet Provider nach

get-command *winget*

Get-WinGetPackage

Update-WinGetPackage

Find-WinGetPackage PRTG
