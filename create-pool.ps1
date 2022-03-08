#  per https://blog.coeo.com/make-the-most-out-of-your-azure-disks-using-storage-pools
# run the following on the server itself
### CREATE STORAGE STORAGE POOL
$StripeSize = 65536
$allocationUnit = 65536
  
[array]$PhysicalDisks = Get-StorageSubSystem -FriendlyName "Windows Storage*" | Get-PhysicalDisk -CanPool $True
#[array]$PhysicalDisks = Get-PhysicalDisk -FriendlyName "Msft Virtual Disk"

$DiskCount = $PhysicalDisks.count
  
$POOL = New-StoragePool -FriendlyName "NEWDATAPOOL"  -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks 
$DISK =  New-VirtualDisk -FriendlyName "DATA01" -StoragePoolFriendlyName "NEWDATAPOOL" -Interleave $StripeSize -NumberOfColumns $DiskCount -ResiliencySettingName simple -UseMaximumSize
$DISK |Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter "G" -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA01" -AllocationUnitSize $allocationUnit -Confirm:$false -UseLargeFRS
