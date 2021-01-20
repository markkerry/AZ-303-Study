$rgName = "rg-eu-vms"
$kvName = "kvname00001"
$location = "west europe"

# Create the Key Vault
$keyVault = New-AzKeyVault -Name $kvName -ResourceGroupName $rgName -Location $location -EnabledForDiskEncryption

# Enable Azure Disk Encryption
Set-AzVMDiskEncryptionExtension -VMName "vm1" -ResourceGroupName $rgName -DiskEncryptionKeyVaultUrl $keyVault.VaultUri -DiskEncryptionKeyVaultId $keyVault.ResourceId