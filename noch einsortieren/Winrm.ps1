# Notizen fuer WinRM (PowerShell Remote)

# Anzeigen:
winrm e winrm/config/listener

# Loeschen:
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
# winrm delete winrm/config/Listener?Address=*+Transport=HTTP

# Hinzufuegen:
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="*.domaene.at"; CertificateThumbprint="2cf2cbfe4sdfsdf19067s9d7f9as7df97af95b8f"}'
