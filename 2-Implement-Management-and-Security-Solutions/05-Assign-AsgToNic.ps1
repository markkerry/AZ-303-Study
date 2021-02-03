$rgName = "rg-eu-vms"
$nicName = "vm1-NIC"
$asgName = "vm-asg"

# NIC of the existing VM
$nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName

# Get the ASG
$asg = Get-AzApplicationSecurityGroup -Name $asgName -ResourceGroupName $rgName

# Add the NIC to the ASG
$nic.IpConfigurations[0].ApplicationSecurityGroups = $asg
Set-AzNetworkInterface -NetworkInterface $nic