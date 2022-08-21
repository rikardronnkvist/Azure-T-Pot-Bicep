# Azure-T-Pot-Testing"


# Run
Create RG and go...

```powershell

Connect-AzAccount

$homeDnsNamne = "xyz.abcd.nu"
$rg = New-AzResourceGroup -Name "rg-honeypot-test" -Location "West Europe"


[string]$HomeCurrentIP = ([System.Net.Dns]::GetHostaddresses($homeDnsNamne) ).IPAddressToString
$TemplateParams = @{
    vmAdminUsername = "riro"
    vmAdminPassword = "SuperSecretPassword123!"
    nsgAllowedIP = $HomeCurrentIP
    vmSize = "Standard_B4ms"
}

$deploymentName = "T-Pot_$( Get-Date -Format 'yyyy-MM-dd' )"
$Deployment = New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -Name $deploymentName -TemplateFile .\main.bicep -TemplateParameterObject $TemplateParams -Verbose


Restart-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $Deployment.Outputs.VMName.value -NoWait

Write-Host "T-Pot is soon available at"
Write-Host "  Web:   https://$($Deployment.Outputs.PublicIP.value):64297"
Write-Host "  SSH:   ssh://$($vmAdminUsername)@$($Deployment.Outputs.PublicIP.value):64295"



``` 
