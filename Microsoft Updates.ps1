# Microsoft Updates abfragen (geht als User) bzw aktivieren (geht nur als Admin)
# hier sind wirklich die Microsoft Updates (auch Office,...) und nicht die Windows Updates gemeint


# zuerst die Update-Methode "initialisieren"
$mu = New-Object -ComObject Microsoft.Update.ServiceManager -Strict

# Abfrage ob Microsoft Updates aktiviert (true) ist
$mu.services | ? name -eq "Microsoft Update" | select IsRegisteredWithAU

# die Aktivierung benoetigt lokale Administrator Rechte
$mu.RegisterServiceWithAU("7971f918-a847-4430-9279-4a52d1efe18d")



# folgendes funktioniert mit Server 2025 en derzeit leider nicht

# Den Schalter fuer Microsoft Updates in der GUI auf ON stellen
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'AllowMUUpdateService' -Value 1

# Abfragen ob der Microsoft Update Dienst der DefaultAUService ist
(New-Object -ComObject Microsoft.Update.ServiceManager).Services | Select-Object Name, IsDefaultAUService

# als Default setzen (als Admin)
(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")

