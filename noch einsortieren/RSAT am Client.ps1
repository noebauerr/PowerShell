# RSAT Tools am Windows Client mit der PowerShell installieren

#Requires -RunAsAdministrator

# Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

Get-WindowsCapability -Name RSAT.Active* -Online

Get-WindowsCapability -Name RSAT.Active* -Online | Add-WindowsCapability -Online