# Example PowerShell runbook to start a VM

$connectionName = "AzureRunAsConnection"

try {
    $spConnection = Get-AzAutomationConnection -Name $connectionName

    Write-Host "Logging into Azure"
    $connectionResult = Connect-AzAccount -Tenant $spConnection.TenantID -ApplicationId $spConnection.ApplicationId -CertificateThumbprint $spConnection.CertificateThumbprint -ServicePrincipal
    Write-Host "Logged in"
}
catch {
    if (!$connectionResult) {
        $err = "Connection $connectionName not found"
        throw $err
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

Start-AzVM -Name "vm1" -ResourceGroupName "rg-eu-vms"