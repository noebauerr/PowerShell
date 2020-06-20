# bösen VM-BlueScreen erzeugen
# dieser Befehl erzeugt in den VMs einen Bluescreen (Stand Juni 2020)

get-vm | Out-GridView -PassThru | debug-vm -InjectNonMaskableInterrupt
