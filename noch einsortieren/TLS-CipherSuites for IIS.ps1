# Welche Ciphersuiten sind aktiv reund wie sind die Eigenschaften?
Get-TlsCipherSuite | Format-Table Name, Exchange, Cipher, Hash, Certificate

# Deaktivieren aller Ciphersuiten
Foreach ($CSU in (Get-TlsCipherSuite -Name 'TLS'))
{Disable-TlsCipherSuite -Name $CSU.Name}

# Aktivieren der einzig sicheren Ciphersuiten (lt. ct Heft 2/2022)
# TLS 1.2
Enable-TlsCipherSuite -Name TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
Enable-TlsCipherSuite -Name TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
Enable-TlsCipherSuite -Name TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
Enable-TlsCipherSuite -Name TLS_DHE_RSA_WITH_AES_128_GCM_SHA256

# Zusatzinfo
# https://www.der-windows-papst.de/wp-content/uploads/2020/02/Ciphersuiten-managen.pdf
# https://www.der-windows-papst.de/2021/11/12/disable-all-insecure-tls-cipher-suites/

# Zeitschrift ct 2/2022 Seite 142-147
# Heise+ https://www.heise.de/hintergrund/Sichere-Cipher-Suites-fuer-TLS-auswaehlen-6317457.html
# https://ct.de/y2yq

# Server 2022 HTTP3 und TLS 1.3 Zusatzinfos
# https://4sysops.com/archives/increase-iis-performance-with-http3-in-windows-server-2022/

# Stand Jaenner 2022