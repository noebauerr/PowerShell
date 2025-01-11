# Abfragen ob es Benutzerkonten ohne Kennwort gibt
Get-ADUser -Filter {PasswordNotRequired -eq $true}

# Account deaktiviert aber kein Passwort erzwungen
Get-ADUser -Property userAccountControl -LDAPFilter "(userAccountControl=66082)"

# Server 2025 - Credential Guard im Ueberwachungsmodus konfigurieren

# Computer­konfiguration => Richtlinien => Administrative Vorlagen => System => Device Guard.
# Im Ueberwachungsmodus aktiviert

Start-Process "https://www.windowspro.de/wolfgang-sommergut/anmeldedaten-computer-konten-credential-guard-schuetzen"
Start-Process "https://4sysops.com/archives/enable-credential-guard-on-windows-server-2025/"
