# Windows Admin Center herunterladen
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"

# winget install Microsoft.WindowsAdminCenter
winget install "Windows Admin Center"
Start-Process https://localhost:6516

# hier findet man den Versionsverlauf und auch den Link zum "alten" v2311 wo die HPE Extensions noch funktioniert haben
Start-Process https://learn.microsoft.com/de-de/windows-server/manage/windows-admin-center/support/release-history
