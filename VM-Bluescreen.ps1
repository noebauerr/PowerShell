# boesen VM-BlueScreen erzeugen
# dieser Befehl erzeugt in den VMs einen Bluescreen (Stand Juni 2020)
# Der folgende Befehl muss am Hyper-V Host ausgefuehrt werden

get-vm | Out-GridView -PassThru | debug-vm -InjectNonMaskableInterrupt
