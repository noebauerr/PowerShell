# Microsoft SQL Server Notizen

# der SQL Server Browser Dienst ist fuer die Namensaufloesung (benannte Instanz) zustaendig
# eine benannte Instanz hat einen dynamischen Port

# Installation mit Winget ab Server 2025 moeglich
# bei der deutschen OS Version muss vorher die Region auf en-us gestellt werden bei einer SQL 2022 Installation
Set-Culture -CultureInfo en-us
winget install Microsoft.SQLServer.2022.Express --silent --accept-source-agreements
Set-Culture -CultureInfo de-de

winget install Microsoft.SQLServerManagementStudio

# TCP aktivieren
https://learn.microsoft.com/de-de/powershell/sql-server/how-to-enable-tcp-sqlps?view=sqlserver-ps&viewFallbackFrom=sql-server-ver16&source=recommendations
https://learn.microsoft.com/de-de/sql/database-engine/configure-windows/enable-or-disable-a-server-network-protocol?view=sql-server-ver16

# Firewall Einstellungen

# PowerShell Modul SQLServer installieren
Install-Module sqlserver -AllowClobber -Force

https://mail.brycematheson.io/create-sql-server-user-and-add-role-via-powershell/
https://www.mssqltips.com/sqlservertip/4697/add-remove-and-get-sql-logins-new-sql-powershell-2016-cmdlets/

# Benutzer Login mit PS SQLServer Modul anlegen
Add-SQLLogin -
