# installierte Windows Features erfassen

Get-WindowsFeature | where {$_.InstallState -eq 'Installed'} 
