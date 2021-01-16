$stgName = "stgmk64645353282"
$rgName = "rg-eu-stg"

# Check storage account name is available
if ((Get-AzStorageAccountNameAvailability -Name $stgName).NameAvailable) {
    # Create storage account
    New-AzStorageAccount -Name $stgName -ResourceGroupName $rgName -Location "West Europe" -SkuName Standard_LRS -Kind StorageV2 -AccessTier Hot
}
else {
    Write-Host "Storage account name $stgName is unavailable"
}