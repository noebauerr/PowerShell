# www.sysinternals.com
# Tools direkt ueber das Web starten
# auf Server Betriebssystemen muss erste das Feature Webdav-Client installiert werden

# WebDAV-Client muss laufen
Get-Service WebClient
Start-Service webclient # als Admin starten


Start-Process \\live.sysinternals.com\tools\procexp64.exe

Start-Process \\live.sysinternals.com\tools\autoruns64.exe

Start-Process \\live.sysinternals.com\tools\bginfo64.exe


# besser die Programme der Sysinternals Suite direkt installieren

winget install --id Microsoft.Sysinternals --accept-package-agreements

winget install --id Microsoft.Sysinternals.ProcessExplorer
winget install --id Microsoft.Sysinternals.Autoruns

winget install --id Microsoft.Sysinternals.BGInfo
start-process bginfo "/timer:0 /all /accepteula"