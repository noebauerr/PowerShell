# Windows Admin Center - WAC - herunterladen
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"

# winget install Microsoft.WindowsAdminCenter
winget install "Windows Admin Center"
Start-Process https://localhost:6516

# Release History
Start-Process https://learn.microsoft.com/de-de/windows-server/manage/windows-admin-center/support/release-history

# Silent Install is now available (2025.11)
# A command line can now be used to silently install Windows Admin Center!
# The following arguments are supported: /Silent /VerySilent /HTTPSPortNumber /CertificateThumbprint