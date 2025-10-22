# Leeren des aktuellen Hintergrundbilds
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value ""

# Den Farbwert für Grau setzen (hier: 128 128 128 als Beispiel)
Set-ItemProperty "HKCU:\Control Panel\Colors" -Name Background -Value "128 128 128"
