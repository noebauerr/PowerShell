# Notizen zu den Windows Server 2025 preview Neuerungen (Stand April 2025)

Start-Process https://learn.microsoft.com/en-us/Windows-server/get-started/whats-new-windows-server-insiders-preview

# hier noch mal eine schöne Zusammenfassung der neuen Funktionen
Start-Process https://www.virtualizationhowto.com/2024/03/windows-server-2025-vs-windows-server-2022/

# What's new in Windows Server 2025 - Zusammenfassung in einem 30 min Video
Start-Process https://www.youtube.com/watch?v=j470Tp4b6es

#region Hotpatching

# kleinere Patches, daher sind sie schneller installiert
# kein Neustart notwendig (ausser alle 3 Monate und bei zB .net Updates) 

# bisher nur mit Windows Server 2022 Azure Edition möglich
# ab Server 2025 für physische und virtuelle System, egal so sie betrieben werden möglich
# nur im Azure Portal mit ARC Anbindung möglich
# nur für einen noch unbekannten monatlichen Betrag (ausser bei Azure und Azure Stack HCI)

#endregion

#region Active Directory

# Video von Manfred Helber ca. 27 min
Start-Process https://www.youtube.com/watch?v=udXNagC43ow

# Allgemeine Zusammenfassung was neu ist im AD
Start-Process https://www.virtualizationhowto.com/2024/03/windows-server-2025-active-directory-new-features/

# Neuer Domain und Forest functional level
# von functional level 7 (Windows Server 2016) auf level 10 (Windows Server 2025)

# Neue Schema Version
# c:\Windows\System32\adprep
# sch89.ldf, sch90.ldf, sch91.ldf


# jetzt werden alle Prozessorgruppen angsprochen, nicht nur NUMA 0,
# daher können jetzt mehrere Sockel benutzt werden (> 64 Cores möglich)


# Delegated Managed Service Account dMSA als Nachfolger vom gMSA
# Maschinengebundene service accounts, kein Passwort sondern randomized key der an die Maschine gebunden ist

Start-Process https://learn.microsoft.com/en-us/Windows-server/security/delegated-managed-service-accounts/delegated-managed-service-accounts-overview

# Anleitung zum Setup eines dMSA
Start-Process https://learn.microsoft.com/en-us/Windows-server/security/delegated-managed-service-accounts/delegated-managed-service-accounts-set-up-dmsa



# neue Performance Counters im perfmon
# LSA Lookups
# DC Locator
# LDAP Client


# Database Page Size wurde von 8k auf 32k erweitert
# c:\Windows\NTDS
esentutl /mh ntds.dit /vss
# cbDbPage: 32768 
# 32k nur bei neuen Forests, bei bestehenden Forests muss von Hand updated werden.

$Parameter = @{
Identity = 'Database 32k Pages Feature'
Scope  = 'ForestOrConfigurationSet'
Target = 'myDomain.at'
Server = 'v-dc1'}  # für jeden Server

Enable-ADOptionalFeature @Parameter #wird auch für den Recycle Bin verwendet


# DC-location Algorythmus wurde verbessert
# WINS und Mailslots sind "depricated"
Start-Process https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/dc-locator-changes


# AD Security
# LDAP support für TLS 1.3
# LDAP encryption by default
# LDAP channel binding audit support, events 3074 und 3075 (gibts schon seit Server 2022 KB4520412)
# LDAP add, search, modify sind nur noch erlaubt wenn die Verbindung verschlüsselt ist
# Kerberos Supported AES SHA256/384 (RC4 depricated)
# Kerberos auch auf Workgroup Server (lt. Webinar am 19.4.2024 Base-IT)
# erweitere Sicherheit bei den default machine account passwords

# zusätzlich soll Kerberos das alte NTLM in naher Zukunft überall ersetzen
# NTLM Kennwörter werden unsalted im RAM gehalten, MD4 ...
# SMB Clients können konfiguriert werden dass sie NTLM für outbound connections blockieren
# local KDC nicht nur in DCs

#endregion

#region Azure Arc

# das Azure Arc setup Feature-on-Demand ist vorinstalliert
# Menüpunkt im Servermanager

Start-Process https://learn.microsoft.com/en-us/azure/azure-arc/servers/onboard-windows-server

#endregion

# Bluetooth Devices werden jetzt unterstützt

# WLAN Service
net start wlansvc # service per default auf manual

# Windows 11 Optik und auch neuen Task Manager
# Das Setup wurde an die Windows 11 Optik und Funktionen angepasst

# folgende Accounts können im Server 2025 hinzugefügt werden
# Settings > Accounts > Email & accoounts
# - Microsoft Entra ID
# - Microsoft account
# - Work od school account 

# File Compression unterstützt jetzt ZIP, 7z und TAR

#region SMB
# SMB over Quick UDP Internet Connection (QUIC) in allen Editionen enthalten
# TLS Verschlüsselung und daher kein VPN nötig
# weniger Latenz
# Die Konfiguration ist aber schon "anspruchsvoll"
Start-Process https://learn.microsoft.com/en-us/Windows-server/storage/file-server/smb-over-quic
Start-Process https://techcommunity.microsoft.com/t5/storage-at-microsoft/smb-over-quic-now-available-in-windows-server-insider-datacenter/ba-p/3975242
# event im WAC doch nicht sooo kompliziert!?


# SMB Mindestversion zB 3.x und encryption kann konfiguriert werden
# SMB authentication Rate Limiter (default auf 2 Sekunden)
Get-SmbServerConfiguration
Set-SmbServerConfiguration -InvalidAuthenticationDelayTimeInMs 2000 # in Millisekunden, 0 = disabled
Start-Process https://www.youtube.com/watch?v=3YT18BiNOKM&t=5s

# SMB NTLM blocking
Start-Process https://techcommunity.microsoft.com/t5/storage-at-microsoft/smb-ntlm-blocking-now-supported-in-windows-insider/ba-p/3916206

# SMB Firewall Rule Hardening (NetBIOS Ports werden nicht geöffnet)

#endregion SMB


# LAPS wurde optimiert
# Passphrasen statt grauslige komplex Kennwörter
# die automatischen Kennwörter können konfiguriert werden dass sie keine 1,i,I,l o,O,0 usw enthalten
# LAPS AD attribute msLAPS-CurrentPasswordVersion um beim Rollback keine Probleme zu verursachen
 

# Winget Support juhuuuu
winget install Microsoft.SQLServer.2022.Express # auch SQL kann installiert werden
winget install Microsoft.Sysinternals.ProcessMonitor


#region Storage

# viele Verbesserungen im Storage Bereich
Start-Process https://www.virtualizationhowto.com/2024/04/windows-server-2025-new-storage-features/

# NVMe Treiber mit bis zu 70% mehr IOPS und weniger Latenz
# diskspd.exe -r4k -b4k -t8 -o64 -d60 -Suw #0
# NVMe-of (over Fabrics) mit TCP/RDMA Support

# REFS Deduplication and Compression (anscheinend total neu geschrieben)

# Thin Provisioning jetzt auch im S2D nicht nur im HCI

#endregion Storage


# Hyper-V erhält GPU Partitioning mit Live Migration und Failover Clustering
# Hyper-V ermöglicht einen Workgroup Cluster mit Zertifikaten gesichert
# Hyper-V unterstützt 2048 virtuelle CPUs und 240 TB RAM in der VM, am Host 4 Petabyte RAM
Start-Process https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-hyper-v-scalability-in-windows-server?pivots=windows-server-2025
# Dynamic Processor Compatibility im Cluster


# Network ATC - one-click deployment across the cluster and drift remediation (vorher nur im Azure Stack HCI)
# 3 verschiedene Network intents
# Storage-only, VM traffic, shared management


# Feature Update (= In-Place Update) von Server 2022 können wie die Feature updates in Windows 11 installiert werden
# funktioniert derzeit bei 96% der Systeme, bei einem Error rollback (zumindest meistens)
# es gibt kein zurück
# S2D Cluster können auch im laufenden Betrieb aktualisiert werden
# Microsofts strong recommendation: BACKUP !
# Update geht auf N-4 Media-Based Feature Update (Setup.exe) - also ab Server 2012 R2
# pro Serverupdate kann man mit ca. 1 Stunde rechnen


# Windows Server 2025 security baseline schon jetzt verfügbar (nicht erst Monate nach erscheinen des OS)
# arbeitet wie DSC und stellt den urspünglichen Zustand immer wieder her
# start-process https://www.powershellgallery.com/packages/Microsoft.OSConfig/0.1.19-preview
Find-Module -Name PowerShellGet | Install-Module
Install-Module -Name Microsoft.OSConfig -AllowPrerelease -Force
Set-OSConfigDesiredConfiguration -Scenario SecurityBaseline/WindowsServer2025/MemberServer -Default -Force
Set-OSConfigDesiredConfiguration -Scenario SecurityBaseline/WindowsServer2025/MemberServer -Name WindowsFirewallPublicFirewallState -Value 1 -Force
Get-OSConfigDesiredConfiguration -Scenario SecurityBaseline/WindowsServer2025/MemberServer | ft name


# PowerShell
# neue Module: DefenderPerformance, ReFSDedup ...


# Application control
# enabled in Audit mode
# Azure Monitor workbook wird dazu benötigt


# Removed Features
# Peer Name Resolution Protocol (PNRP) wurde entfernt wegen DDos Gefahr
# SMTP-Server und Supporting Tools (SMTP IIS 6 console)



# Windows Funktionen lifecycle
Start-Process https://learn.microsoft.com/de-de/windows/whats-new/feature-lifecycle

# Liste der veralteten Windows features
Start-Process https://learn.microsoft.com/de-de/windows/whats-new/deprecated-features
# WebDAV ist veraltet (November 2023)

# Windows Funktionen die entfernt wurden nachdem sie auf der veraltet Liste standen
Start-Process https://learn.microsoft.com/de-de/windows/whats-new/removed-features

# Windows Server Features die veraltet sind
Start-Process https://learn.microsoft.com/de-de/windows-server/get-started/removed-deprecated-features-windows-server-2022
# LBFO Team im Hyper-V
# WINS
# TLS 1.0 und 1.1


# Test Keys fuer Server Preview
# Server 2025 Standard:   MFY9F-XBN2F-TYFMP-CCV49-RMYVH
# Server 2025 Datacenter: 2KNJJ-33Y9H-2GXGX-KMQWH-G6H67