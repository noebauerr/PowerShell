#Requires -RunAsAdministrator
Install-Module -Name Microsoft.WinGet.Client


get-command *winget*

Get-WinGetPackage

Update-WinGetPackage

Find-WinGetPackage simulator