Connect-AzAccount

$rg = New-AzResourceGroup -Name "rg-honeypot-test" -Location "West Europe"

$HomeCurrentIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content.Trim()
$TemplateParams = @{
    tpotAdminUsername = "riro"
    tpotAdminPassword = "SuperSecretPassword123"
    nsgAllowedIP = $HomeCurrentIP
    vmSize = "Standard_B4ms"
}

$deploymentName = "T-Pot_$( Get-Date -Format 'yyyy-MM-dd' )"
$Deployment = New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -Name $deploymentName -TemplateFile .\main.bicep -TemplateParameterObject $TemplateParams -Verbose

Restart-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $Deployment.Outputs.vmName.value -NoWait | Out-Null

$PublicIP = (Get-AzPublicIpAddress -ResourceGroupName $rg.ResourceGroupName -Name $Deployment.Outputs.publicIpName.value).IpAddress

Write-Host "T-Pot is soon available at"
Write-Host "  Web:   https://$($TemplateParams.tpotAdminUsername):$($TemplateParams.tpotAdminPassword)@$($PublicIP):64297"
Write-Host "  SSH:   ssh://$($TemplateParams.tpotAdminUsername)@$($PublicIP):64295"
