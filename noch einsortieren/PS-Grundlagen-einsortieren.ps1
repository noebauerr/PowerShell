
get-filehash

# Hilfe
update-help        # Administratorrechte notwendig
get-help -online   # keine Adminrechte notwendig
get-help -Detailed

about_
help about_*

<# Mehrzeiliger Kommentar

ein mehrzeiliger Kommentar
Test

#>


# Vergleichsoperatoren
about_Comparison_Operators


get-process chrome | measure WS -sum  # es geht auch -Average, -Maximum, -Minimum


# Datum
$1Woche  = (get-date) - (New-timespan -Days 7)
$kannweg = dir *.log | ? LastWriteDate -lt $1Woche
$Platz = $kannweg | measure Length -sum


# Laufwerke - PSDrives
cd "HKCU:\Control Panel\Desktop\"
# Registry Werte werden in Item Properties gespeichert
get-Itemproperty
remove-Itemproperty

$env:path # greift auf die Umgebungsvariable Path zu

set-executionpolicy RemoteSigned
about_Execution_Policies
