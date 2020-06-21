# Test your Antivirus
# ein paar Notizen zum Windows Defender

# Download Eicar Testvirus from www.eicar.com
# http://2016.eicar.org/85-0-Download.html
# 
invoke-webrequest https://2016.eicar.org/download/eicar.com -outfile .\Virenscannertest-einfache-com-Datei
invoke-webrequest https://secure.eicar.org/eicarcom2.zip -outfile .\Virenscannertest-gezippter-Testvirus

Get-MpThreat

Get-MpThreatDetection

Get-MpComputerStatus

Start-MpScan -ScanType FullScan

Set-MpPreference -PUAProtection $true #als administrator

# Testvirus auf einem entfernten Rechner herunterladen
#
# $rechner = "rechner01"
# $cred = get-credential $rechner\admin
# Invoke-command -hostname $rechner -credentials $rechner\admin {invoke-webrequest http://2016.eicar.org/download/eicar.com -outfile c:\Virenscannertest}