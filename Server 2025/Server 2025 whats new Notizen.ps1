# Notizen zu den Windows Server 2025 Neuerungen (Stand November 2024)

Start-Process https://learn.microsoft.com/en-us/windows-server/get-started/whats-new-windows-server-2025

# hier noch mal eine schoene Zusammenfassung der neuen Funktionen
Start-Process https://www.virtualizationhowto.com/2024/03/windows-server-2025-vs-windows-server-2022/

# What's new in Windows Server 2025 - Zusammenfassung in einem 30 min Video
Start-Process https://www.youtube.com/watch?v=j470Tp4b6es

#region Hotpatching

# kleinere Patches, daher sind sie schneller installiert
# kein Neustart notwendig (ausser alle 3 Monate und bei zB .net Updates) 

# bisher nur mit Windows Server 2022 Azure Edition moeglich
# ab Server 2025 fuer physische und virtuelle System, egal wo sie betrieben werden moeglich
# nur im Azure Portal mit ARC Anbindung moeglich
# nur fuer einen noch unbekannten monatlichen Betrag (ausser bei Azure und Azure Stack HCI)

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


# jetzt werden alle Prozessorgruppen angesprochen, nicht nur NUMA 0,
# daher koennen jetzt mehrere Sockel benutzt werden (> 64 Cores moeglich)


# Delegated Managed Service Account dMSA als Nachfolger vom gMSA
# Maschinengebundene service accounts, kein Passwort sondern randomized key der an die Maschine gebunden ist

Start-Process https://learn.microsoft.com/en-us/Windows-server/security/delegated-managed-service-accounts/delegated-managed-service-accounts-overview

# Anleitung zum Setup eines dMSA
Start-Process https://learn.microsoft.com/en-us/Windows-server/security/delegated-managed-service-accounts/delegated-managed-service-accounts-set-up-dmsa
Start-Process https://4sysops.com/archives/delegated-managed-service-accounts-in-windows-server-2025/


# neue Performance Counters im perfmon
# LSA Lookups
# DC Locator
# LDAP Client


# Database Page Size wurde von 8k auf 32k erweitert
# c:\Windows\NTDS
esentutl /mh ntds.dit /vss
# cbDbPage: 32768 
# 32k nur bei neuen Forests, bei bestehenden Forests muss von Hand upgedated werden

$Parameter = @{
Identity = 'Database 32k Pages Feature'
Scope  = 'ForestOrConfigurationSet'
Target = 'myDomain.at'
Server = 'v-dc1'}  # fuer jeden Server

Enable-ADOptionalFeature @Parameter # wird auch fuer den Recycle Bin verwendet


# DC-location Algorithmus wurde verbessert
# WINS und Mailslots sind "depricated"
Start-Process https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/dc-locator-changes


# AD Security
# LDAP support fuer TLS 1.3
# LDAP encryption by default
# LDAP channel binding audit support, events 3074 und 3075 (gibts schon seit Server 2022 KB4520412)
# LDAP add, search, modify sind nur noch erlaubt wenn die Verbindung verschluesselt ist
# Kerberos Supported AES SHA256/384 (RC4 depricated)
# Kerberos auch auf Workgroup Server (lt. Webinar am 19.4.2024 Base-IT)
# erweitere Sicherheit bei den default machine account passwords

# zusaetzlich soll Kerberos das alte NTLM in naher Zukunft ueberall ersetzen
# NTLM Kennwoerter werden unsalted im RAM gehalten, MD4 ...
# SMB Clients koennen konfiguriert werden dass sie NTLM fuer outbound connections blockieren
# local KDC nicht nur in DCs

#endregion

#region Azure Arc

# das Azure Arc setup Feature-on-Demand ist vorinstalliert
# Menuepunkt im Servermanager

Start-Process https://learn.microsoft.com/en-us/azure/azure-arc/servers/onboard-windows-server

# Deinstallation des AzureArcSetup mit der PowerShell
Disable-WindowsOptionalFeature -Online -FeatureName AzureArcSetup

# Deinstallation mit DISM
DISM /online /Remove-Capability /CapabilityName:AzureArcSetup~~~~
 
#endregion

# Bluetooth Devices werden jetzt unterstuetzt

# WLAN Service
net start wlansvc # service per default auf manual start

# Windows 11 Optik und neuen Task Manager
# Das Setup wurde an die Windows 11 Optik und Funktionen angepasst

# folgende Accounts koennen im Server 2025 hinzugefuegt werden
# Settings > Accounts > Email & accoounts
# - Microsoft Entra ID
# - Microsoft account
# - Work od school account 

# Credential Guard ist standardmaessig aktiviert, bei einer Cluster-VM wird aber fuer vTPM eine Guarded Facric benoetigt

# File Compression unterstuetzt jetzt ZIP, 7z und TAR (RAR kann nur entkomprimiert werden?)

# SSH kann als zusaetzliches Managementprotokoll genutzt werden 

#region SMB
# SMB over Quick UDP Internet Connection (QUIC) in allen Editionen enthalten
# TLS Verschluesselung und daher kein VPN noetig
# weniger Latenz
# Die Konfiguration ist aber "anspruchsvoll"
Start-Process https://learn.microsoft.com/en-us/Windows-server/storage/file-server/smb-over-quic
Start-Process https://techcommunity.microsoft.com/t5/storage-at-microsoft/smb-over-quic-now-available-in-windows-server-insider-datacenter/ba-p/3975242
# event im WAC doch nicht sooo kompliziert!?


# SMB Mindestversion zB 3.x und encryption kann konfiguriert werden
# SMB authentication Rate Limiter (default auf 2 Sekunden)
Get-SmbServerConfiguration
Set-SmbServerConfiguration -InvalidAuthenticationDelayTimeInMs 2000 # in Millisekunden, 0 = disabled
Start-Process https://www.youtube.com/watch?v=3YT18BiNOKM

# SMB NTLM blocking
Start-Process https://techcommunity.microsoft.com/t5/storage-at-microsoft/smb-ntlm-blocking-now-supported-in-windows-insider/ba-p/3916206

# SMB Firewall Rule Hardening (NetBIOS Ports werden nicht geoeffnet)

#endregion SMB


# LAPS wurde optimiert
# Passphrasen mit 3 bis 10 Woertern statt komplexe Kennwoerter
# die automatischen Kennwoerter koennen konfiguriert werden dass sie keine 1,i,I,l o,O,0 usw enthalten
# LAPS AD Attribute msLAPS-CurrentPasswordVersion um beim Rollback keine Probleme zu verursachen
 

# Winget Support (juhuuuu)
winget install Microsoft.Sysinternals.ProcessMonitor

# bei der deutschen OS Version muss vorher die Region auf en-us gestellt werden bei einer SQL 2022 Installation
Set-Culture -CultureInfo en-us
winget install Microsoft.SQLServer.2022.Express --silent --accept-source-agreements
Set-Culture -CultureInfo de-de


#region Storage

# viele Verbesserungen im Storage Bereich
Start-Process https://www.virtualizationhowto.com/2024/04/windows-server-2025-new-storage-features/

# NVMe Treiber mit bis zu 70% mehr IOPS und weniger Latenz
# diskspd.exe -r4k -b4k -t8 -o64 -d60 -Suw #0
# NVMe-of (over Fabrics) mit TCP/RDMA Support

# REFS Deduplication and Compression (anscheinend total neu geschrieben), Dedup wird jetzt auch auf VM Workload unterstuetzt

# Thin Provisioning jetzt auch im S2D nicht nur im HCI

#endregion Storage


#region Hyper-V

# Hyper-V erhaelt GPU Partitioning mit Live Migration und Failover Clustering (Nvidia GPU A- und L-Klasse)
# Hyper-V ermoeglicht einen Workgroup Cluster mit Zertifikaten gesichert
# Hyper-V unterstuetzt 2048 virtuelle CPUs und 240 TB RAM in der VM, am Host 4 Petabyte RAM
Start-Process https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-hyper-v-scalability-in-windows-server?pivots=windows-server-2025
# Dynamic Processor Compatibility im Cluster

#endregion


#region Network ATC
# Network ATC - one-click deployment across the cluster and drift remediation (vorher nur im Azure Stack HCI)
# 3 verschiedene Network intents
# -Management
# -Compute    (VM Traffic)
# -Storage    (Storage only)
Install-WindowsFeature -Name NetworkATC -IncludeManagementTools

# jede NIC darf nur in einem einzigen Network Intent vorkommen, jeder Intent kann mehrere NICs haben
Get-NetIntent | select IntentName, IntentType, NetAdapterNameCsv
Add-NetIntent -Name Mgmt -Management -AdapterName NIC1, NIC2
Add-NetIntent -Name CompMgmt -Management -Compute -AdapterName NIC1, NIC2 # Management und Compute auf die 2 NICs
Get-NetIntentStatus -Name Mgmt

# jeder Adapter muss auf jedem Knoten den selben Namen haben und auf Status UP sein
Get-NetAdapter -CimSession (Get-ClusterNode).Name

# in virtuellen Umgebungen muss zuvor der "RDMA-Zwang" deaktiviert werden
$override = New-NetIntentAdapterPropertyOverrides
$override.NetworkDirect = 0

Add-NetIntent -Name Storage -Storage -AdapterName NIC2 -AdapterPropertyOverrides $override

Get-Command -Noun NetIntent*Over* -Module NetworkATC

# Um die Bandbreite fuer SMB auf 25 Prozent zu beschraenken, definiert man einen Override folgendermassen:
$QosOverride = New-NetIntentQosPolicyOverrides
$QosOverride.BandwidthPercentage_SMB = 25

# Wenn man den Intent bereits angelegt hat, ohne den Override anzugeben, kann man diesen nachtraeglich anwenden:
Set-NetIntent -Name ComputeStorage -QosPolicyOverrides $QosOverride

# Zusatzinfo zu Network ATC
Start-Process https://www.windowspro.de/wolfgang-sommergut/windows-server-2025-netzwerke-cluster-automatisch-konfigurieren-network-atc
Start-Process https://learn.microsoft.com/en-us/azure-stack/hci/deploy/network-atc?tabs=22H2#default-network-atc-values

#endregion


# Feature Update (= In-Place Update) von Server 2022 koennen wie die Feature updates in Windows 11 installiert werden
# funktioniert derzeit (Stand Sept. 2024) bei 96% der Systeme, bei einem Error rollback (zumindest meistens)
# es gibt kein zurueck
# S2D Cluster koennen auch im laufenden Betrieb aktualisiert werden
# Microsofts strong recommendation: BACKUP !
# Update geht auf N-4 Media-Based Feature Update (Setup.exe) - also ab Server 2012 R2
# pro Serverupdate kann man mit ca. 1 Stunde rechnen


# Windows Server 2025 security baseline schon jetzt verfuegbar (nicht erst Monate nach erscheinen des OS)
# arbeitet wie DSC und stellt den urspruenglichen Zustand immer wieder her
Start-Process https://techcommunity.microsoft.com/t5/windows-server-insiders/announcing-windows-server-2025-security-baseline-preview/m-p/4257686
Start-Process https://www.powershellgallery.com/packages/Microsoft.OSConfig

# muss PowerShellGet noch extra installiert werden?
Find-Module -Name PowerShellGet | Install-Module
# jetzt die PowerShell schliessen und neu oeffnen

Install-Module -Name Microsoft.OSConfig # -Force

Set-OSConfigDesiredConfiguration -Scenario SecurityBaseline\WS2025\MemberServer -Default # -Force
Set-OSConfigDesiredConfiguration -Scenario SecurityBaseline\WS2025\WorkgroupMember -Default

Set-OSConfigDesiredConfiguration -Scenario SecurityBaseline\WS2025\WorkgroupMember -Name FirewallPublicProfileState -Value 1 -Force

Get-OsConfigDesiredConfiguration -Scenario SecurityBaseline\WS2025\WorkgroupMember | Ft Name


# PowerShell - neue Module:
# - DefenderPerformance
# - Microsoft.ReFsDedup.Commands
# - Microsoft.Windows.BCD.Cmdlets
# - Provisioning - zum Managen von provisioning packages 


# Application control - enabled in Audit mode
# Azure Monitor workbook wird dazu benoetigt


# Removed Features in Server 2025
Start-Process https://learn.microsoft.com/en-us/Windows-server/get-started/removed-deprecated-features-windows-server-2025
# Wordpad
# Windows PowerShell 2.0
# Peer Name Resolution Protocol (PNRP) wurde entfernt wegen DDos Gefahr
# SMTP-Server (alternativ kann man folgendes OpenSource SMTPrelay verwenden https://emailrelay.sourceforge.net/)
# IIS 6 Management Console

# Windows Server Features die veraltet sind
Start-Process https://learn.microsoft.com/de-de/windows-server/get-started/removed-deprecated-features-windows-server-2022
# LBFO Team im Hyper-V
# WINS
# TLS 1.0 und 1.1
# WEBdav Redirector Service


# Windows-Client Funktionen lifecycle
Start-Process https://learn.microsoft.com/de-de/windows/whats-new/feature-lifecycle

# Liste der veralteten Windows-Client features
Start-Process https://learn.microsoft.com/de-de/windows/whats-new/deprecated-features
# WebDAV ist veraltet (November 2023)

# Windows-Client Funktionen die entfernt wurden nachdem sie auf der veraltet-Liste standen
Start-Process https://learn.microsoft.com/de-de/windows/whats-new/removed-features


# Windows Server 2025 AVMA-Keys
# Server 2025 Standard:   WWVGQ-PNHV9-B89P4-8GGM9-9HPQ4
# Server 2025 Datacenter: YQB4H-NKHHJ-Q6K4R-4VMY6-VCH67
# slmgr /ipk <AVMA-Key>