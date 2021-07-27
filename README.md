# PowerShell Notizen
hier versuche ich mein persönlichen Powershell Notizen an einem zentralen Ort zu sammeln


Diese Powershell Skripte können auch direkt heruntergeladen und ausgeführt werden (auf eigenes Risiko)

```sh
Invoke-WebRequest "https://raw.githubusercontent.com/noebauerr/PowerShell/master/Sound-Beep.ps1" -OutFile "Beep.ps1"
```
(Download ins aktuelle Verzeichnis.)

```sh
.\Beep.ps1
```
(starten des Skripts.)


```sh
$ScriptOnGithub = Invoke-WebRequest "https://raw.githubusercontent.com/noebauerr/PowerShell/master/Sound-Beep.ps1"
Invoke-Expression $($ScriptOnGitHub.Content)
```
(oder gleich direkt starten - aber Vorsicht mit diesem Befehl)

```sh
Invoke-WebRequest "https://raw.githubusercontent.com/noebauerr/PowerShell/master/Sound-Beep.ps1" -OutFile "Sound-Beep.ps1"; .\Sound-Beep.ps1
```
(oder gleich direkt starten - aber Vorsicht mit diesem Befehl)
