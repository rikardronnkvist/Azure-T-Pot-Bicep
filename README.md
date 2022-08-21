# T-Pot Honeypot in Azure

Will create a [T-Pot Honeypot](https://github.com/telekom-security/tpotce#installation) based on Debian


# Run with Powershell
The script will lookup a DNS-name of your choice and allow that IP to use the T-Pot administration

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

Restart-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $Deployment.Outputs.vmName.value -NoWait | Out-Null

$PublicIP = (Get-AzPublicIpAddress -ResourceGroupName $rg.ResourceGroupName -Name $Deployment.Outputs.publicIpName.value).IpAddress

Write-Host "T-Pot is soon available at"
Write-Host "  Web:   https://$($PublicIP):64297"
Write-Host "  SSH:   ssh://$($TemplateParams.vmAdminUsername)@$($PublicIP):64295"


``` 
