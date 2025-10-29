# AuditTAP PowerShell Modul installieren
Install-Module -Name ATAPAuditor

# nuget-Provider wird benoetigt

# in einem Offline System
# von Github oder FB-Pro-Website herunterladen
https://www.fb-pro.com/audit-test-automation-package-audit-tap/
https://github.com/fbprogmbh/Hardening-Audit-Tool-AuditTAP


# entpacken (Expand-Archive)
# die Module ATAPAuditor und ATAPHtmlReport in einen Ordner innerhalb von
$env:PSModulePath # kopieren

Import-Module -Name ATAPAuditor
Get-Command -Module ATAPAuditor

# Report erzeugen
Save-ATAPHtmlReport -ReportName "Microsoft Windows 11 Stand-alone" -Path C:\Temp\audit11.html
Save-ATAPHtmlReport -ReportName "Microsoft Windows Server 2025 Stand-alone" -Path C:\Temp\audit2025.html -RiskScore

Get-ATAPReport # Liste welche ReportNames es gibt

# regelmaessig updaten
Update-Module -Name ATAPAuditor
