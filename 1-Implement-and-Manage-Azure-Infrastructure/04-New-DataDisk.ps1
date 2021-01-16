# Define the following parameters for the Azure resources.
$rgName = 'rg-eu-vms'
$vmName = 'vm2'
$location = 'westeurope'
$storageType = 'Premium_LRS'
$dataDiskName  = "vm2-data1-disk"

$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB 10
$datadisk1 = New-AzDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $datadisk1.Id -Lun 1

Update-AzVM -VM $vm -ResourceGroupName $rgName