# Exchange HealthChecker.ps1 von Microsoft
Start-Process https://microsoft.github.io/CSS-Exchange/Diagnostics/HealthChecker/
Start-Process https://github.com/microsoft/CSS-Exchange/releases/latest/download/HealthChecker.ps1

# Exchange Server build numbers and release dates
start-process https://learn.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates

# Exchange Infos und Tools
Start-Process https://www.frankysweb.de/
Start-Process https://www.frankysweb.de/exchange-reporter-2013/ # Exchange Reporter
Start-Process https://www.frankysweb.de/message-tracking-gui/   # Exchange Message Tracking GUI
Start-Process https://www.frankysweb.de/exchange-monitor/       # Exchange Monitor


# folgende Zeile als Admin ausfuehren, ist fuer die ISE Integration notwendig
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$servername = "v-exchange"  # Hostname vom Exchange Server

# EventID 15004 - Healthstatus erhöht
# EventID 15005 - Status normalisiert
# EventID 15006 - Speicherplatz wird knapp
# EventID 15007 - RAMauslastung zu HOCH

Get-EventLog -LogName system | ? eventid -EQ 15007


Get-OwaVirtualDirectory -Server $servername | fl *
get-clientaccessservice * | fl *

Get-OwaVirtualDirectory -Server $servername
Get-EcpVirtualDirectory -server $servername
Get-WebServicesVirtualDirectory -server $servername
Get-ActiveSyncVirtualDirectory -Server $servername
Get-OabVirtualDirectory -Server $servername
Get-MapiVirtualDirectory -Server $servername
Get-OutlookAnywhere -Server $servername

get-mailbox | Get-Member

Get-Mailbox | sort servername | ft name, servername, haspicture


# die wichtigsten Abfragen zu den Usermailboxen am Server

# Name und Größe und Anzahl wird angezeigt, sortiert nach Größe (über 1 GB)
Get-MailboxStatistics -Server v-exchange |sort totalitemsize -descending |? totalitemsize -gt 1000MB | ft displayname, totalitemsize, itemcount

# der Spitzenreiter nach Anzahl der Mails (über 9999 Stück)
Get-MailboxStatistics -Server v-exchange |sort itemcount -descending | ? itemcount -gt 9999 | ft displayname, itemcount, totalitemsize

# storagelimitstatus erreicht
get-mailboxstatistics -server v-exchange | sort storagelimitstatus -descending | ft displayname, storagelimitstatus

#E-Mail Adressen aller Mailbox Datenbanken auslesen:
#Get-MailboxDatabase | Get-Mailbox | fl DisplayName, EmailAddresses > c:\Mailbox.csv
Get-MailboxDatabase | Get-Mailbox | ft DisplayName, EmailAddresses

#E-Mail Adressen aus einer öffentlichen Ordner Datenbank auslesen:
#Get-MailPublicFolder | fl Displayname, EmailAddresses > c:\PublicFolder.csv
Get-MailPublicFolder | ft Displayname, EmailAddresses
