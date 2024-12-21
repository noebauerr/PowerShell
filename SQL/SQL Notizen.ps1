# SQL Server Notizen

#Requires -Modules SqlServer 
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force 
Install-Module -Name SqlServer -AllowClobber -Force

get-command -Module sqlserver
start-process https://learn.microsoft.com/en-us/powershell/module/sqlserver/?view=sqlserver-ps



# einen SQL SPN setzen damit auch die Kerberos Authentifizierung benutzt werden kann
# funktioniert aber mit benannten Instanzen nicht sooo gut
Setspn -S MSSQLSvc/v-SQL.Domaene.at:SQLEXPRESS v-sql
Setspn -S MSSQLSvc/v-SQL.Domaene.at v-sql #registriert den dynamischen Port

# im SSMS kann man mit folgender Abfrage kontrollieren ob Kerberos verwendet wird
# SELECT auth_scheme 
# FROM sys.dm_exec_connections 
# WHERE session_id = @@SPID