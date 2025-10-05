# www.sysinternals.com

# Autoruns und ProcessExplorer direkt vom Internet aus Powershell starten (Virustotal noch aktivieren)
# Der Parameter /e startet das Programm erneut als Admin

Start-Process \\live.sysinternals.com\tools\autoruns.exe /e

Start-Process \\live.sysinternals.com\tools\procexp64.exe /e

Start-Process \\live.sysinternals.com\tools


# auf Server wird zusaetzlich das Feature WebDAV Redirector benoetigt
Install-WindowsFeature WebDAV-Redirect