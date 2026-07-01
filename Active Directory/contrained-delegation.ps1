# (un)Contrained Delegation

# hier duerfen nur die DCs aufscheinen
Get-ADuser -Filter 'TrustedForDelegation -eq $true' -Properties TrustedForDelegation

Get-ADComputer -LDAPFilter '(msDS-AllowedToDelegateTo=*)' -Properties msDS-AllowedToDelegateTo, TrustedToAuthForDelegation

# Ressource Based Constrained Delegation (das neueste)
Get-ADComputer -LDAPFilter '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' -Properties PrincipalsAllowedToDelegateToAccount | select Name, PrincipalsAllowedToDelegateToAccount


Start-Process https://www.windowspro.de/wolfgang-sommergut/kerberos-delegation-ueberblick-unconstrained-uneingeschraenkt-constrained