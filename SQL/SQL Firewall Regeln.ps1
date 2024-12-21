
# SQL 2022 Firewall Regeln erstellen
New-NetFirewallRule -DisplayName "Meine-Regel SQL-Server"  -Profile Any -Program "C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Binn\sqlservr.exe" -Direction Inbound -Action Allow -Enabled True -Description "Damit man auch von der Ferne mit dem SSMS zugreifen kann."
New-NetFirewallRule -DisplayName "Meine-Regel SQL-Browser" -Profile Any -Program "C:\Program Files (x86)\Microsoft SQL Server\90\Shared\sqlbrowser.exe" -Direction Inbound -Action Allow -Enabled True -Description "Damit die benannte Instanz gefunden wird."

# die 2 nachfolgenden Regeln nur anwenden wenn eine Default Instanz (MSSQLSERVER) verwendet wird
New-NetFirewallRule -DisplayName "Meine-SQL-1433-TCP" -Profile Any -Protocol TCP -LocalPort 1433 -Direction Inbound -Action Allow -Enabled True -Description "Meine SQL Regel 1433 TCP"
New-NetFirewallRule -DisplayName "Meine-SQL-1434-UDP" -Profile Any -Protocol UDP -LocalPort 1434 -Direction Inbound -Action Allow -Enabled True -Description "Meine SQL Regel 1434 UDP"