# T-Pot Honeypot in Azure

This will create a [T-Pot Honeypot](https://github.com/telekom-security/tpotce) in Azure based on Debian

# Powershell Script Workflow

* Get your extenal IP via [ipify](https://www.ipify.org/)
* Deploy [main.bicep](./main.bicep) (with verbose logging)
  * Create Storage Account
  * Create Public IP
  * Create Network Security Group
    * Allow 64294-64297 from your external IP
    * Allow all execept admin interface
  * Create Virtual Network
  * Create Network Interface
  * Create VM
  * Run script [install_tpot.sh](./install_tpot.sh)
    * Install Docker
    * GIT clone [https://github.com/telekom-security/tpotce](https://github.com/telekom-security/tpotce)
    * Install T-Pot with config from [tpot.conf](./tpot.conf)
* Reboot
* Output information


# Powershell Script

```powershell
Connect-AzAccount

$rg = New-AzResourceGroup -Name "rg-honeypot-test" -Location "West Europe"

$HomeCurrentIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content.Trim()
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
It will take a while for the VM to restart and get all services up and running

Usernames and password for the web interface can be found in the file [tpot.conf](./tpot.conf)
