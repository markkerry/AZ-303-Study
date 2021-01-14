$resourceGroup = "rg-eu-vms"
$vmName = "vm1"
$newSize = "Standard_DS3_V2"

# List the VM sizes that are available on the hardware cluster where the VM is hosted.
Get-AzVMSize -ResourceGroupName $resourceGroup -VMName $vmName

# if the size you want is listed, run the following commands to resize the VM
$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName
$vm.HardwareProfile.VmSize = $newSize
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup

# If the size you want is not listed, run the following commands to deallocate the VM, resize it, and restart the VM. Replace <newVMsize> with the size you want.
Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName
$vm.HardwareProfile.VmSize = $newSize
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
Start-AzVM -ResourceGroupName $resourceGroup -Name $vmName