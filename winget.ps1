start-process https://github.com/noebauerr/PowerShell

winget upgrade --all

# UniGetUI - war vorher wingetui
winget install wingetui --id SomePythonThings.WingetUIStore -s winget


# Remotezeugs
winget search mRemoteNG
winget search rdcman
winget search pRemoteM
winget search "royal ts"
winget search "devolutions remote desktop manager"

winget install mRemoteNG
winget install "Remote Desktop Connection Manager" #sysinternals rdcman
winget install 9PNMNF92JNFP # "1Remote (PRemoteM) - mstsc remote desktop"
winget install "royal ts" --source msstore

winget install "Microsoft .NET Windows Desktop Runtime 8.0"
winget install "devolutions remote desktop manager" --accept-package-agreements


# ISO bearbeiten und unattend Zeugs
winget search anyBurn   # zB Unattend.xml direkt auf die ISO schreiben
winget search "ntlite"  # Win Installationsmedium anpassen und Service-Packs, Treiber und Systemkomponenten anpassen

# Benchmark
winget search cinebench
winget search CrystalDiskMark

# treesize free
winget install "Treesize Free" --source msstore

# Github Desktop
winget install "Github Desktop"

# Apple iPad als Zusatzdisplay
# Spacedesk Windows Driver # von Datronicsoft

# Netzwerk IP Scanner
winget install Famatech.AdvancedIPScanner


# Microsoft Zeugs
winget install "Microsoft Loop"
winget install "Microsoft Teams" --id Microsoft.Teams --source winget
winget install onenote
winget install Microsoft.PowerShell  # powershell 7.x
# sysinternals suite
winget install "Sysinternals Suite"
winget install bginfo
start-process bginfo /accepteula /timer:0

# Windows Admin Center
winget install "Windows Admin Center"

# Parameter --silent --accept-source-agreements damit nicht immer nachgefragt wird

# Lockoutstatus.exe von Microsoft
Start-Process https://www.microsoft.com/en-gb/download/details.aspx?id=15201
Start-Process https://download.microsoft.com/download/c/0/4/c0472410-b4c2-4aef-89d2-e7c708dfc225/lockoutstatus.msi



# PowerShell Modul fuer Winget
#Requires -RunAsAdministrator
Install-Module -Name Microsoft.WinGet.Client

get-command *winget*

Get-WinGetPackage

Update-WinGetPackage

Find-WinGetPackage simulator
