#Requires -RunAsAdministrator
#Requires -Modules Microsoft.OSConfig

Install-PackageProvider -Name nuget -force
Install-Module -Name Microsoft.OSConfig -Scope AllUsers -Force

Get-Command -Module Microsoft.OSConfig

Get-OSConfigMetadata | ft Name, Description -Wrap


Set-OSConfigDesiredConfiguration -Scenario Defender\Antivirus -Default


Get-OSConfigDesiredConfiguration -Scenario Defender\Antivirus |
select name, Description, @{n="Reason"; e={$_.Compliance.Reason}}, `
@{n="Status"; e={$_.Compliance.Status}} | Format-List


# Name, Description, Reason, Status
$aufgesplittet = Get-OSConfigDesiredConfiguration -Scenario Defender\Antivirus |
    Select-Object Name, Description, @{Name="Reason";Expression={$_.Compliance.Reason}}, @{Name="Status";Expression={$_.Compliance.Status}}

$compliant = $aufgesplittet | ? Status -eq Compliant
$compliant

$notcompliant = $aufgesplittet | ? status -NE Compliant
$notcompliant


# Aenderungen durchfuehren
Set-OSConfigDesiredConfiguration -Scenario Defender\Antivirus -Setting SubmitSamplesConsent -Value 1
Get-OSConfigDesiredConfiguration -Scenario Defender\Antivirus -Setting SubmitSamplesConsent

Set-OSConfigDesiredConfiguration -Scenario Defender\Antivirus -Setting ASRBlockUntrustedAndUnsignedProcessesRunningFromUSB -Value 1
Get-OSConfigDesiredConfiguration -Scenario Defender\Antivirus -Setting ASRBlockUntrustedAndUnsignedProcessesRunningFromUSB

Remove-OSConfigDesiredConfiguration -Scenario Defender\Antivirus


# ueber WAC (Windows Admin Center) Security kann man auch noch Aenderungen vornehmen und ist uebersichtlicher

# eine vollstaendige Liste der Security Baselines findet man auf Github
Start-Process https://github.com/microsoft/osconfig/tree/main/security

# in der PowerShell Gallery
Start-Process https://www.powershellgallery.com/packages/Microsoft.OSConfig

Start-Process https://www.windowspro.de/wolfgang-sommergut/osconfig-security-einstellungen-windows-server-2025-konfigurieren-abweichungen

Start-Process https://learn.microsoft.com/de-de/windows-server/security/osconfig/osconfig-overview

Start-Process https://learn.microsoft.com/de-de/windows-server/security/osconfig/osconfig-how-to-configure-security-baselines?tabs=configure

# alte Ankuendigung der Preview
Start-Process https://techcommunity.microsoft.com/t5/windows-server-insiders/announcing-windows-server-2025-security-baseline-preview/m-p/4257686