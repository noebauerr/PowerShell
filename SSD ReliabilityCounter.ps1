# ReliabilityCounter von SSDs bzw NVMEs auslesen
# muss als Admin ausgeführt werden
#Requires -RunAsAdministrator

Get-PhysicalDisk |Get-StorageReliabilityCounter