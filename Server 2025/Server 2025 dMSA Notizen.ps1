# Achtung das ist nur eine Notiz und wurde noch nicht getestest

# DMSA - delegated managed service account

# https://4sysops.com/archives/delegated-managed-service-accounts-in-windows-server-2025/
# https://4sysops.com/archives/osconfig-manage-security-settings-in-windows-server-2025-and-revert-configuration-drift/
# https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/delegated-managed-service-accounts/delegated-managed-service-accounts-overview
# https://www.windowspro.de/wolfgang-sommergut/delegated-managed-service-account-dmsa-neuer-kontotyp-fuer-windows-dienste-server

# umwandeln eines alten Service Accounts in einen dMSA

# dMSA kann genutzt werden sobald ein beschreibbarer Domaenen-Controller auf Server 2025 umgestellt wurde.

$DMSA = "DMSA-Test"
$DMSAdns = $DMSA + ".mydom.local"
$LegacyAccount = "CN=Legacy-SVC,OU=MyServiceAccounts,OU=MyOU,DC=mydom,DC=local"


# Erstellen einer DMSA-Kennung
New-ADServiceAccount -CreateDelegatedServiceAccount -KerberosEncryptionType AES256 -Name $DMSA -DNSHostName $DMSAdns


# Verlinken der DMSA-Kennung zum Legacy-Service-Account
Start-ADServiceAccountMigration -Identity $DMSA -SupersededAccount $LegacyAccount


# Status der DSMA-Kennung periodisch pruefen, z.B. nach Starten der relevanten Services, um die selbstregistrierten Server einzusehen
Get-ADServiceAccount -Identity $DMSA -Properties PrincipalsAllowedToRetrieveManagedPassword
# hier muss beim PrincipalsAllowedToRetrieveManagedPassword ein oder mehrere Systeme aufgelistet sein


# Finalisierung der Service-Account-Migration und Uebernahme des SPN
Complete-ADServiceAccountMigration -Identity $DMSA -SupersededAccount $LegacyAccount
