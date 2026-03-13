# Windows Admin Center - WAC - herunterladen (aMode)
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"

# Windows Admin Center v2 (aMode)
winget install Microsoft.WindowsAdminCenter
Start-Process https://localhost:6516

# Release History
Start-Process https://learn.microsoft.com/de-de/windows-server/manage/windows-admin-center/support/release-history

# Silent Install is now available (2025.11)
# A command line can now be used to silently install Windows Admin Center!
# The following arguments are supported: /Silent /VerySilent /HTTPSPortNumber /CertificateThumbprint



# momentan sind Administration Mode (aMode) und virtualization Mode (vMode) noch getrennt.
# Die finale Installer Version wird aber beide Versionen beinhalten

# Windows Admin Center vMode
Start-Process https://4sysops.com/members/michael-pietroforte/activity/73605/
Start-Process https://techcommunity.microsoft.com/blog/windows-admin-center-blog/windows-admin-center-architectural-changes/4488583
Start-Process https://techcommunity.microsoft.com/blog/windows-admin-center-blog/installing-windows-admin-center-virtualization-mode/4496405
Start-Process https://techcommunity.microsoft.com/blog/windows-admin-center-blog/resource-onboarding-using-windows-admin-center-virtualization-mode/4500281

# Voraussetzungen fuer WAC vMode
# VM mit 4 CPUs und 8 GB RaM
# vMode nutzt Network ATC

winget install "Microsoft.VCRedist.2015+.x64" --silent

# Dokumentation
Start-Process https://aka.ms/WACvModeDocs
# Praesentation bei der Ignite
Start-Process https://youtu.be/YK_MNYAmpVA?si=IzNR9HQHY516avix&t=1118

# Public Preview Download
Start-Process https://aka.ms/WACDownloadvMode

# es wird eine PostgreSQL Datenbank installiert.
# Benutzername und Kennwort unbedingt merken (notieren)
# Default Port: 5432 für Datenbank? wird vermutlich nicht benoetigt

