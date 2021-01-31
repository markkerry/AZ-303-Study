$nsgName = 'nsg-eu'
$resourceGroup = 'rg-eu-vnet'

$newNSGParams = @{
    'Name'              = $nsgName
    'ResourceGroupName' = $resourceGroup 
    'Location'          = 'westeurope'
}

# Create the NSG
$nsg = New-AzNetworkSecurityGroup @newNSGParams

# Add a rule for RDP to NSG
$nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup

$params = @{
    'Name'                     = 'allowRDP'
    'NetworkSecurityGroup'     = $nsg
    'Protocol'                 = 'TCP'
    'Direction'                = 'Inbound'
    'Priority'                 = 200
    'SourceAddressPrefix'      = '*'
    'SourcePortRange'          = '*'
    'DestinationAddressPrefix' = '*'
    'DestinationPortRange'     = 3389
    'Access'                   = 'Allow'
}

Add-AzNetworkSecurityRuleConfig @params | Set-AzNetworkSecurityGroup

# Retrieve an existing Virtual Network
$vNet = Get-AzVirtualNetwork -Name 'vnet1' -ResourceGroupName $resourceGroup

# Select the first subnet using array notation and the first record located at the 0 index
$vnetParams = @{
    'VirtualNetwork'       = $vNet
    'Name'                 = ($vNet.Subnets[0]).Name
    'AddressPrefix'        = ($vNet.Subnets[0]).AddressPrefix
    'NetworkSecurityGroup' = $nsg
}

# Apply the updated configuration to the subnet configuration and then apply the change to the VNet
Set-AzVirtualNetworkSubnetConfig @vnetParams
Set-AzVirtualNetwork -VirtualNetwork $vNet