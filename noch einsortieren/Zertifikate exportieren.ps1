# Zertifikta exportieren

certmgr.msc # aktueller Benutzer
certlm.msc  # lokaler Computer (als Admin)

Get-ChildItem Cert:\LocalMachine\my

Get-ChildItem Cert:\LocalMachine\my | where HasPrivateKey -eq $true

Export-Certificate -Type CERT -FilePath mycert.crt -Cert Cert:\LocalMachine\my\<Thumbprint>

$pw = Read-Host -Prompt "Enter Password" -AsSecureString
Export-PfxCertificate -Password $pw -FilePath 9B.pfx -Cert Cert:\LocalMachine\my\9B0F26A07C8052A9FD98BD9C1EEA1F5AE80127B


Regedit
HKLM: \Software\Microsoft\SystemCertificates\My\Certificates
Export als .reg und import als .reg am zielsystem

Start-Process https://4sysops.com/archives/export-certificate-as-cer-der-p7b-or-pfx/
