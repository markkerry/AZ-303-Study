# VNet address space: 10.1.0.0/16
# Subnet address space: 10.1.1.0/24

$resourceGroupName = "rg-eu-vnet"
$location = "West Europe"
$vnetName - "VNet1"
$subnetName = "Subnet1"

# Create the VNet
$vnet1 = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.1.0.0/16"

# Create the subnet and add to VNet
Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.1.1.0/24" -VirtualNetwork $vnet1

Set-AzVirtualNetwork -VirtualNetwork $vnet1