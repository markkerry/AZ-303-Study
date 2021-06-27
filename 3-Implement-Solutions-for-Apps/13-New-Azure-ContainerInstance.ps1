# Azure PowerShell
# default port is 80 unless specified

New-AzContainerGroup -ResourceGroupName "rg-eu-ci" -Name "ContainerName" -Image "<path to image>" -OsType "Windows" -DnsNameLable "name-container"