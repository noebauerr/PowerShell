# Windows Admin Center herunterladen
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"

# winget install Microsoft.WindowsAdminCenter
winget install "Windows Admin Center"
Start-Process https://localhost:6516
