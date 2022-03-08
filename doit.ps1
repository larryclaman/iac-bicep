$RG="cvlttest"
$LOCATION="UKSouth"

az group create --name $RG --location $LOCATION

az deployment group create -g $RG -n vm -f main.bicep --what-if 

az deployment group create -g $RG -n vm -f main.bicep

###########################
# per https://docs.microsoft.com/en-us/azure/virtual-machines/windows/run-command

az vm run-command invoke  --name VMStorageTest -g $RG  --command-id RunPowerShellScript  `
    --scripts @create-pool.ps1 

######
# now update disk size
az disk list -g $RG `
    --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' `
    --output table

$diskname="disk10"

# live resize
az disk update --resource-group $RG `
    --name $diskname `
    --size-gb 16

#################
# random stuff:
#  to add & move to a new larger disk
# 1 add the disk
# 2. mark the old disk as retired
# 3. run a 'repair' on the disk pool
# 4. remove the old disk

# on VM:
Set-PhysicalDisk -FriendlyName <> -Usage Retired

# to resize existing disk to larger:
# 1. resize in azure control plane (eg p20 -> p30)
# 2. 

