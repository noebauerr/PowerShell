

If ( Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "ActiveDirectory PS-Modul ist vorhanden." -ForegroundColor Green
}
    Else { Write-Host "ActiveDirectory PS-Modul ist NICHT vorhanden. Bitte nachinstallieren!" -ForegroundColor Yellow
    exit    
}

cls

do{


Write-Host '---------------------------------------------'
Write-Host '1 - List Domain Admins'
Write-Host '0 - Quit'
Write-Host ''

$input = Read-Host 'Select'

  Switch ($input) {
  1 {
    Write-Host "Domänen Admins auflisten:"`n
    $sid=(Get-ADDomain).DomainSid.Value + '-512'
    Get-ADGroupMember -identity $sid | Format-Table Name,SamAccountName,SID -AutoSize -Wrap
    ''
    Read-Host 'Press Enter to continue'
  
  }

  }


} while ($input -ne '0')