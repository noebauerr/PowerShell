# Computer (VMs) direkt in die passende OU joinen
Add-Computer -DomainName "test.local" -OUPath "OU=Notebooks,DC=test,DC=local"
