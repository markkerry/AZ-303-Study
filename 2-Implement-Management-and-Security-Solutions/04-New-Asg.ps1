$rgName = "rg-eu-vms"
$asgName = "vm-asg"
$location = "westeurope"

# Create the ASG
New-AzApplicationSecurityGroup -ResourceGroupName $rgName -Name -$asgName -Location $location