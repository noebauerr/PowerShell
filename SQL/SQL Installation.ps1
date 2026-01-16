
# SQL Server Installation, bei der deutschen OS Version muss vorher die Region auf en-us gestellt werden
Set-Culture -CultureInfo en-us
winget install Microsoft.SQLServer.2025.Express --silent --accept-source-agreements
Set-Culture -CultureInfo de-de

# SSMS Installation (Zugriff mit SSMS über das Netzwerk auch moeglich wenn die FW Regeln gesetzt sind)
Winget install Microsoft.SQLServerManagementStudio.22

# jetzt nochmals Microsoft Updates starten damit auch die SQL Sicherheitsupdates eingespielt werden
# Sicherheitsupdate für SQL Server 2022(25) RTM GDR wird installiert
# CU 22 (oder neuer) von Hand installieren ?