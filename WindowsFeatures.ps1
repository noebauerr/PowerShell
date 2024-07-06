# installierte Windows Server Features erfassen

Get-WindowsFeature | where {$_.InstallState -eq 'Installed'} 
