# Microsoft Updates abfragen (geht als User) bzw aktivieren (geht nur als Admin)
# hier sind wirklich die Microsoft Updates (auch Office,...) und nicht die Windows Updates gemeint


# zuerst die Update-Methode "initialisieren"
$mu = New-Object -ComObject Microsoft.Update.ServiceManager -Strict

# Abfrage ob Microsoft Updates aktiviert (true) ist
$mu.services | ? name -eq "Microsoft Update" | select IsRegisteredWithAU


# die Aktivierung benoetigt lokale Administrator Rechte
$mu.RegisterServiceWithAU("7971f918-a847-4430-9279-4a52d1efe18d")

# funktioniert mit Server 2025 en derzeit leider nicht