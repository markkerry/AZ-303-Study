# Deploy and ARM template to a Resource Group

## Az PowerShell

```powershell
$resourceGroupName = "rg-eu-vnet"
$location = "West Europe"

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location
# Deploy the ARM Template
New-AzResourceGroupDeployment -Name "Deploy VNet" -ResourceGroupName $resourceGroupName -TemplateParameterFile .\01-New-VNet.parameters.json -TemplateFile .\01-New-VNet.json
```

## Az CLI

```python
# Create a resource group
az group create --name "rg-eu-vnet" --location "West Europe"
# Deploy the ARM Template
az deployment group create --name "Deploy VNet" --resource-group "rg-eu-vnet" --template-file 01-New-VNet.json --paramters @01-New-VNet.parameters.json
```
