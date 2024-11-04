# Windows Admin Center herunterladen
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"

# winget install Microsoft.WindowsAdminCenter
winget install "Windows Admin Center"
Start-Process https://localhost:6516


# Windows Admin Center Preview 2410
Start-Process https://aka.ms/DownloadWAC2410Preview
Start-Process https://techcommunity.microsoft.com/t5/windows-admin-center-blog/windows-admin-center-version-2410-is-now-in-public-preview/ba-p/4272494