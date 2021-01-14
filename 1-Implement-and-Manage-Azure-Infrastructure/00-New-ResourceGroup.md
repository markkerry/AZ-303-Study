# New Resource Group

## Az PowerShell

```powershell
New-AzResourceGroup -Name "rg-eu-vnet" -Location "westeurope"
```

## Az CLI

```python
az group create --name "rg-eu-vnet" --location "westeurope"
```

## Arm Template

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "rgName": {
            "type": "string",
            "metadata": {
                "description": "Name of the Resource Group"
            }
        },
        "rgLocation": {
            "type": "string",
            "metadata": {
                "description": "Location of the Resource Group"
            }
        }
    },
    "functions": [],
    "variables": {},
    "resources": [
        {
            "name": "[parameters('rgName')]",
            "type": "Microsoft.Resources/resourceGroups",
            "apiVersion": "2019-10-01",
            "location": "[parameters('rgLocation')]",
            "dependsOn": [
            ],
            "tags": {
            }
        }
    ],
    "outputs": {}
}
```
