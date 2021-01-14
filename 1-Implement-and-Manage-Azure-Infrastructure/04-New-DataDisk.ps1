# Define the following parameters for the Azure resources.
$azureLocation = "westeurope"
$azureResourceGroup = "rg-eu-vms"
$azureVmName = "vm1"

# Define the following parameters for the Azure resources. Add this to the "#Define the following parameters for the Azure resources." code section.
$azureVmDataDisk01Name  = "vm1-data1-disk"

# Optionally, add an additional data disk. Add this to the "#Define the parameters for the new virtual machine." code section.
$vmDataDisk01Config = New-AzDiskConfig -SkuName Standard_LRS -Location $azureLocation -CreateOption Empty -DiskSizeGB 8
$vmDataDisk01 = New-AzDisk -DiskName $azureVmDataDisk01Name -Disk $vmDataDisk01Config -ResourceGroupName $azureResourceGroup
Add-AzVMDataDisk -VM $azureVmName  -Name $azureVmDataDisk01Name -CreateOption Attach -ManagedDiskId $vmDataDisk01.Id -Lun 0