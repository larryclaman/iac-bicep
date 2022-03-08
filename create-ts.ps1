$RG="tsresources"
$LOCATION="EastUs2"

az group create --name $RG --location $LOCATION

az ts create --name VmWithDisks -g $RG --location $LOCATION `
    --display-name "VM with two data disks" `
    --description "Create a VM with two data disks and a Vnet to go with it" `
    --version 1.0 `
    --template-file .\main.bicep


