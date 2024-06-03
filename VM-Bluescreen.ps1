# boesen VM-BlueScreen erzeugen
# dieser Befehl erzeugt in den ausgewaehlten VMs einen Bluescreen
# Der folgende Befehl muss am Hyper-V Host als Administrator ausgefuehrt werden
#Requires -RunAsAdministrator

get-vm | Out-GridView -PassThru | debug-vm -InjectNonMaskableInterrupt
