#===============================================================================================================
#region PowerShell als Admin neu starten
# diese Zeilen funktionieren nicht in der PowerShell_ISE
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{ Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
#endregion
#================================================================================================================

$startzeit2 = get-date

write-host "zuerst in den richtigen Ordner wechseln?"
cd "C:\Users\reinh\Desktop\mehrere VMs"

.\new-VM-unattend.ps1 v-server1.ps1
.\new-VM-unattend.ps1 v-server2.ps1
.\new-VM-unattend.ps1 v-server3.ps1
.\new-VM-unattend.ps1 v-server4.ps1
.\new-VM-unattend.ps1 v-server5.ps1

$Scriptdauer = (get-date) - $startzeit2
Write-Host -ForegroundColor Cyan "`nDas Skript ist "($Scriptdauer).TotalSeconds" Sekunden gelaufen."
pause